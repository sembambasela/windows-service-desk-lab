# Lab 13 — Identity and Access Management (IAM) Lifecycle

**Project:** Windows Enterprise IT Service Desk Home Lab  
**Environment:** Isolated VirtualBox lab; Windows Server 2025 domain controller `DC01`, Windows 11 workstation `WIN11-CLIENT01`  
**Domain:** `corp.example.test` (`CORP`)  
**Status:** Technical checkpoints completed and verified — November 5, 2026  
**Related simulated service requests:** [SR-013](../service-requests/SR-013-employee-onboarding.md), [SR-014](../service-requests/SR-014-department-transfer.md), [SR-015](../service-requests/SR-015-employee-offboarding.md)

> **Scope:** All users, departments, and requests in this lab are simulated. This is a learning environment, not a production deployment. HR and IT shares are hosted on the domain controller for lab convenience; a dedicated file server is preferable in production.

## Objectives

- Provision a domain user with a temporary password and mandatory first-logon password change.
- Grant departmental access using the **AGDLP** pattern: Accounts → Global groups → Domain Local groups → Permissions.
- Process an IT-to-HR transfer, removing old access before granting new access.
- Disable and deprovision a departing user's account without immediately deleting its directory object.
- Validate authorization with a real Windows client and document the audit trail.

## Starting configuration

| Component | Configuration |
| --- | --- |
| Domain controller / file-share host | `DC01` (`192.168.100.10` on lab internal network) |
| Domain-joined workstation | `WIN11-CLIENT01` (`192.168.100.20` on lab internal network) |
| User OUs | `OU=IT`, `OU=HR`, `OU=Finance` beneath `OU=Corp-Users` |
| Group OU | `OU=Corp-Groups,DC=corp,DC=example,DC=test` |
| Existing IT groups | `SG-IT-Users` (Global), `DL-IT-Share-Modify` (Domain Local) |
| IT share | `\\DC01\IT`, backing folder `C:\CorpShares\IT` |
| Test employee | Jordan Lee, `CORP\jordan.lee` |

## Checkpoint 1 — IAM environment verification

Confirmed the departmental OUs, existing IT security groups, enabled test accounts, and Alex Morgan's membership in `SG-IT-Users`.

## Checkpoint 2 — Employee onboarding (SR-013)

Created `jordan.lee` in the IT OU with `New-ADUser`, including the `IT` department, an administrator-entered secure temporary password, `-Enabled $true`, and `-ChangePasswordAtLogon $true`.

```powershell
$Password = Read-Host "Enter temporary employee password" -AsSecureString
New-ADUser `
    -Name "Jordan Lee" -GivenName "Jordan" -Surname "Lee" `
    -DisplayName "Jordan Lee" -SamAccountName "jordan.lee" `
    -UserPrincipalName "jordan.lee@corp.example.test" `
    -Path "OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test" `
    -Department "IT" -AccountPassword $Password `
    -Enabled $true -ChangePasswordAtLogon $true `
    -Description "Lab 13 - Simulated IT employee onboarding"
```

**Observed verification:** `Enabled=True`, `PasswordExpired=True`, `PasswordNotRequired=False`, blank `PasswordLastSet` consistent with required password change, initial membership `Domain Users` only, and correct IT department/OU. Jordan subsequently signed in on the domain-joined client, consistent with completing the first-logon process; the password itself was not recorded.

## Checkpoint 3 — IT role-based access provisioning

Added Jordan to the IT Global group, which was already nested in the IT Domain Local group:

```powershell
Add-ADGroupMember -Identity "SG-IT-Users" -Members "jordan.lee"
Get-ADGroupMember -Identity "SG-IT-Users"
Get-ADGroupMember -Identity "DL-IT-Share-Modify"
```

**Observed:** `SG-IT-Users` contained Alex Morgan and Jordan Lee; `DL-IT-Share-Modify` contained `SG-IT-Users`. A fresh client sign-in showed both groups in `whoami /groups`. As `CORP\jordan.lee`, the user successfully listed `\\DC01\IT`, created a test file, wrote and read `Lab 13 - Jordan Lee IT access verified`, deleted the file, and confirmed `Test-Path=False`.

## Checkpoint 4 — IT-to-HR transfer (SR-014)

### 4A–4C: Update organizational attributes and revoke IT access

```powershell
Set-ADUser -Identity "jordan.lee" -Department "HR"
Get-ADUser -Identity "jordan.lee" |
    Move-ADObject -TargetPath "OU=HR,OU=Corp-Users,DC=corp,DC=example,DC=test"
Remove-ADGroupMember -Identity "SG-IT-Users" -Members "jordan.lee" -Confirm:$false
```

**Observed:** Jordan was enabled in the HR OU with `Department=HR`. `SG-IT-Users` retained Alex Morgan only; Jordan's direct memberships returned `Domain Users`. After a fresh sign-in, neither IT group appeared in `whoami /groups`, and listing `\\DC01\IT` returned **Access is denied** while `Test-NetConnection DC01 -Port 445` returned `TcpTestSucceeded=True`. This separated permission denial from network failure.

### 4D–4G: Create HR groups and secure HR share

Created `SG-HR-Users` (Global Security) and `DL-HR-Share-Modify` (Domain Local Security) in `OU=Corp-Groups`:

```powershell
New-ADGroup -Name "SG-HR-Users" -SamAccountName "SG-HR-Users" `
    -GroupScope Global -GroupCategory Security `
    -Path "OU=Corp-Groups,DC=corp,DC=example,DC=test" `
    -Description "HR department employee security group"
New-ADGroup -Name "DL-HR-Share-Modify" -SamAccountName "DL-HR-Share-Modify" `
    -GroupScope DomainLocal -GroupCategory Security `
    -Path "OU=Corp-Groups,DC=corp,DC=example,DC=test" `
    -Description "Modify permissions for HR departmental share"
Add-ADGroupMember -Identity "SG-HR-Users" -Members "jordan.lee"
Add-ADGroupMember -Identity "DL-HR-Share-Modify" -Members "SG-HR-Users"
```

The HR folder existed, but initially had inherited `BUILTIN\Users` permissions and no SMB share. Before modifying its ACL, the lab procedure backed up the ACL using `icacls /save`, removed inheritance, and assigned explicit permissions:

```powershell
icacls "C:\CorpShares\HR" /inheritance:r
icacls "C:\CorpShares\HR" /grant:r "BUILTIN\Administrators:(OI)(CI)(F)"
icacls "C:\CorpShares\HR" /grant:r "NT AUTHORITY\SYSTEM:(OI)(CI)(F)"
icacls "C:\CorpShares\HR" /grant "CORP\DL-HR-Share-Modify:(OI)(CI)(M)"
```

**Verified NTFS ACL:** `BUILTIN\Administrators:(F)` plus inherited-to-children Full Control, `NT AUTHORITY\SYSTEM:(OI)(CI)(F)`, and `CORP\DL-HR-Share-Modify:(OI)(CI)(M)`; `AreAccessRulesProtected=True`. No `BUILTIN\Users` entry remained in the displayed ACL.

```powershell
New-SmbShare -Name "HR" -Path "C:\CorpShares\HR" `
    -Description "HR Department Shared Folder" `
    -FullAccess "BUILTIN\Administrators" `
    -ChangeAccess "CORP\DL-HR-Share-Modify"
```

**Verified SMB access:** Administrators = Full; `CORP\DL-HR-Share-Modify` = Change; no `Everyone` entry.

### 4H: Client authorization test

After a fresh sign-in, `whoami /groups` included `CORP\SG-HR-Users` and `CORP\DL-HR-Share-Modify`, with neither IT group. Jordan successfully listed `\\DC01\HR`, created, wrote, read, and deleted `Jordan-HR-Access-Test.txt`; final `Test-Path=False`. A separate attempt to list `\\DC01\IT` returned **Access is denied**.

## Checkpoint 5 — Offboarding (SR-015)

The pre-offboarding audit showed Jordan enabled in the HR OU, with `Domain Users` and `SG-HR-Users` membership. `LastLogonDate` displayed `11/5/2026 12:48:37 PM` (a directory-reported value, not a complete logon history).

```powershell
Disable-ADAccount -Identity "jordan.lee"
Set-ADUser -Identity "jordan.lee" `
    -Description "Lab 13 - SR-015 - Simulated employee offboarding - Account disabled"
Remove-ADGroupMember -Identity "SG-HR-Users" -Members "jordan.lee" -Confirm:$false
```

**Observed:** `Enabled=False`; account retained in HR OU; HR Global group empty; remaining membership `Domain Users`. The user confirmed that a **fresh Windows sign-in was rejected because the account was disabled**. This validates fresh interactive sign-in rejection, not immediate invalidation of all existing tickets or sessions.

## Checkpoint 6 — Final audit

| Audit item | Verified final result |
| --- | --- |
| `jordan.lee` | Exists, disabled (`Enabled=False`) |
| Department and OU | HR; `CN=Jordan Lee,OU=HR,OU=Corp-Users,DC=corp,DC=example,DC=test` |
| Description | `Lab 13 - SR-015 - Simulated employee offboarding - Account disabled` |
| Direct/primary memberships returned | `Domain Users` only |
| `SG-IT-Users` | Alex Morgan only |
| `SG-HR-Users` | Empty |
| New interactive sign-in | Rejected because account disabled |

### Useful audit commands

```powershell
Get-ADUser -Identity "jordan.lee" -Properties Department,Enabled,Description |
    Select-Object Name,SamAccountName,Department,Enabled,Description,DistinguishedName
Get-ADPrincipalGroupMembership -Identity "jordan.lee" |
    Select-Object Name,GroupScope
Get-ADGroupMember -Identity "SG-IT-Users" |
    Select-Object Name,SamAccountName
Get-ADGroupMember -Identity "SG-HR-Users" |
    Select-Object Name,SamAccountName
```

## Lessons learned

1. Changing an OU or department attribute does **not** automatically revoke group-based permissions.
2. AGDLP makes permissions easier to administer and audit without granting access directly to individual users.
3. Fresh logons are important when testing changes to Windows security tokens.
4. Both NTFS and SMB share permissions influence effective file access.
5. A successful TCP 445 test alongside an access-denied response points toward authorization rather than connectivity.
6. Disabling a user and removing group membership are separate controls; existing sessions and issued tickets may require additional revocation actions in a real offboarding process.

## Evidence and limitations

The results above are based on PowerShell output and Windows sign-in observations provided during the lab. No screenshots, exported event logs, approval records, or production change tickets were supplied. Service requests are simulated and should not be presented as real enterprise tickets. This lab did not test revocation of every previously established SMB session or Kerberos ticket.

**Completion:** All planned Lab 13 technical verification checkpoints passed. Documentation prepared for the GitHub portfolio; repository publication is a separate step.
