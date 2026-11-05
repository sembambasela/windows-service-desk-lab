# Lab 12 — Active Directory File Sharing and NTFS Permissions

**Status:** Complete  
**Environment:** Windows Server 2025 (DC01), Windows 11 Pro (WIN11-CLIENT01), Active Directory domain `corp.example.test`  
**Related incident:** [INC-012 — IT Shared Folder Access Denied](../incident-reports/INC-012-it-shared-folder-access-denied.md)

## Objective

Configure a departmental SMB share secured through Active Directory groups and NTFS permissions. Validate authorized access, deny unauthorized access, and troubleshoot a deliberately introduced permissions failure.

> **Lab scope:** This isolated training environment hosts the share on domain controller DC01. In production, departmental file shares should normally be hosted on a dedicated file server rather than a domain controller.

## Lab environment

| Component | Configuration |
| --- | --- |
| Domain | `corp.example.test` (NetBIOS `CORP`) |
| File share host | `DC01`, `192.168.100.10` |
| Windows client | `WIN11-CLIENT01`, `192.168.100.20` |
| Client account | `CORP\alex.morgan` |
| Unauthorized test account | `CORP\hr.testuser` |
| Local share path | `C:\CorpShares\IT` |
| UNC path | `\\DC01\IT` |

## 1. Verify Active Directory prerequisites

Confirmed:

- `SG-IT-Users` exists as a **Global Security** group in `OU=Corp-Groups`.
- `alex.morgan` is a member of `SG-IT-Users`.
- Alex Morgan's account is enabled and not locked out.

```powershell
Get-ADGroup -Identity 'SG-IT-Users' |
    Select-Object Name, GroupScope, GroupCategory, DistinguishedName
Get-ADGroupMember -Identity 'SG-IT-Users' |
    Select-Object Name, SamAccountName, ObjectClass
Get-ADUser -Identity 'alex.morgan' -Properties Enabled, LockedOut |
    Select-Object Name, SamAccountName, Enabled, LockedOut
```

## 2. Create departmental folders

Created and verified:

```text
C:\CorpShares\
├── IT\
├── HR\
└── Finance\
```

```powershell
New-Item -Path 'C:\CorpShares' -ItemType Directory -Force
'IT','HR','Finance' | ForEach-Object {
    New-Item -Path "C:\CorpShares\$_" -ItemType Directory -Force
}
Get-ChildItem 'C:\CorpShares' -Directory | Select-Object Name, FullName
```

Only the IT folder was configured as a share during this lab.

## 3. Configure AGDLP security group nesting

Created `DL-IT-Share-Modify` as a **Domain Local Security** group in `OU=Corp-Groups`, and nested `SG-IT-Users` inside it.

```powershell
New-ADGroup -Name 'DL-IT-Share-Modify' `
    -SamAccountName 'DL-IT-Share-Modify' `
    -GroupScope DomainLocal -GroupCategory Security `
    -Path 'OU=Corp-Groups,DC=corp,DC=example,DC=test' `
    -Description 'Modify access to the IT departmental file share'

Add-ADGroupMember -Identity 'DL-IT-Share-Modify' -Members 'SG-IT-Users'
Get-ADGroupMember -Identity 'DL-IT-Share-Modify'
```

**Access model:** `alex.morgan` → `SG-IT-Users` (Global) → `DL-IT-Share-Modify` (Domain Local) → folder permissions.

## 4. Configure NTFS permissions

Initial ACL inspection showed inherited `BUILTIN\Users` permissions, including read/execute and file creation rights. To restrict the IT folder, the existing ACL was backed up, inheritance was disabled with inherited ACEs removed, and permissions were explicitly assigned.

```powershell
New-Item -Path 'C:\LabReports' -ItemType Directory -Force
icacls 'C:\CorpShares\IT' /save 'C:\LabReports\Lab12-IT-ACL-Backup.txt'
icacls 'C:\CorpShares\IT' /inheritance:r
icacls 'C:\CorpShares\IT' /grant:r `
    'CORP\DL-IT-Share-Modify:(OI)(CI)M' `
    'BUILTIN\Administrators:(OI)(CI)F' `
    'NT AUTHORITY\SYSTEM:(OI)(CI)F'
```

**Final verified ACL:**

```text
C:\CorpShares\IT BUILTIN\Administrators:(F)
                 CORP\DL-IT-Share-Modify:(OI)(CI)(M)
                 NT AUTHORITY\SYSTEM:(OI)(CI)(F)
                 BUILTIN\Administrators:(OI)(CI)(F)
```

`(Get-Acl 'C:\CorpShares\IT').AreAccessRulesProtected` returned `True`, confirming inheritance was disabled. `(OI)` and `(CI)` propagate permissions to files and subfolders.

## 5. Configure SMB share permissions

```powershell
New-SmbShare -Name 'IT' -Path 'C:\CorpShares\IT' `
    -ChangeAccess 'CORP\DL-IT-Share-Modify' `
    -FullAccess 'BUILTIN\Administrators' `
    -Description 'IT Department Shared Folder'

Get-SmbShare -Name 'IT' | Select-Object Name, Path, Description
Get-SmbShareAccess -Name 'IT'
```

**Verified share ACL:**

| Principal | Share access |
| --- | --- |
| `BUILTIN\Administrators` | Full |
| `CORP\DL-IT-Share-Modify` | Change |

Effective network access is constrained by both SMB share permissions and NTFS permissions.

## 6. Test authorized access

From `WIN11-CLIENT01`, signed in as `CORP\alex.morgan`:

```powershell
whoami
Test-NetConnection -ComputerName DC01 -Port 445
Test-Path '\\DC01\IT'
```

Observed `TcpTestSucceeded : True`, source `192.168.100.20`, destination `192.168.100.10`, and `Test-Path : True`.

A test file was written, read, and deleted successfully:

```powershell
Set-Content '\\DC01\IT\Lab12-Test.txt' 'Lab 12 - IT file sharing permissions test'
Get-Content '\\DC01\IT\Lab12-Test.txt'
Remove-Item '\\DC01\IT\Lab12-Test.txt'
Test-Path '\\DC01\IT\Lab12-Test.txt'
```

The read returned the expected content, and the final existence check returned `False`.

## 7. Test unauthorized access

The temporary `hr.testuser` account was initially disabled. Attempting to enable it produced an AD password complexity error. After resetting its password to comply with domain policy, the account was enabled and verified as a member of **Domain Users only**—not either IT access group.

An existing SMB connection was removed from the client before connecting with HR credentials:

```powershell
net use \\DC01\IT /delete
net use \\DC01\IT /user:CORP\hr.testuser *
```

The SMB connection itself succeeded; however, file operations were blocked:

| Attempt | Observed result |
| --- | --- |
| `Get-ChildItem '\\DC01\IT'` | Access denied |
| Create `HR-Unauthorized-Test.txt` | Access denied |
| `Test-Path` for unauthorized test file | Access denied and returned `False` (not conclusive evidence of nonexistence) |

**Conclusion:** SMB session establishment alone did not imply filesystem access. The unauthorized account was denied folder listing and file creation.

## 8. Simulate and resolve incident INC-012

After disconnecting the HR session, Alex Morgan's baseline folder access was confirmed. The ACL was backed up and the IT group's Allow ACE was deliberately removed:

```powershell
icacls 'C:\CorpShares\IT' /save 'C:\LabReports\Lab12-IT-ACL-PreIncident.txt'
icacls 'C:\CorpShares\IT' /remove:g 'CORP\DL-IT-Share-Modify'
```

On WIN11-CLIENT01, Alex Morgan received **Access is denied** from `Get-ChildItem '\\DC01\IT'`, while TCP port 445 remained reachable. This isolated the incident to permissions rather than basic network connectivity.

Restoration on DC01:

```powershell
icacls 'C:\CorpShares\IT' /grant:r 'CORP\DL-IT-Share-Modify:(OI)(CI)M'
```

The corrected ACL and disabled inheritance were verified. From the client, Alex Morgan successfully wrote, read, and deleted `INC-012-Resolution-Test.txt`; the final `Test-Path` returned `False`.

## 9. Final validation

Final server-side verification confirmed:

- `DL-IT-Share-Modify` retains NTFS Modify permissions.
- Administrators and SYSTEM retain Full Control.
- SMB share permissions remain Administrators: Full and IT group: Change.
- `SG-IT-Users` remains nested in `DL-IT-Share-Modify`.
- Authorized access is restored; unauthorized HR read and create operations were denied during testing.

```powershell
icacls 'C:\CorpShares\IT'
Get-SmbShareAccess -Name 'IT' |
    Format-Table AccountName, AccessControlType, AccessRight -AutoSize
Get-ADGroupMember -Identity 'DL-IT-Share-Modify' |
    Select-Object Name, SamAccountName, ObjectClass
```

## Skills demonstrated

Active Directory group administration; AGDLP; NTFS inheritance and ACL management; SMB sharing; least-privilege access testing; PowerShell diagnostics; incident reproduction, root-cause analysis, and remediation.

## Outcome

**Lab 12 completed successfully.** The IT share is accessible to the authorized IT group, unauthorized HR file operations were denied, and the simulated INC-012 permission failure was diagnosed and resolved.
