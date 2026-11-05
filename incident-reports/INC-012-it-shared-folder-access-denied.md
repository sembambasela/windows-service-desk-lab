# INC-012 — IT Shared Folder Access Denied

**Type:** Simulated incident (training lab)  
**Status:** Resolved — verified  
**Service:** Active Directory-backed SMB file sharing  
**Affected user:** Alex Morgan (`CORP\alex.morgan`)  
**Affected resource:** `\\DC01\IT` (`C:\CorpShares\IT`)  
**Server:** DC01 (`192.168.100.10`)  
**Client:** WIN11-CLIENT01 (`192.168.100.20`)  
**Related lab:** [Lab 12 — Active Directory File Sharing and NTFS Permissions](../docs/17-lab12-active-directory-file-sharing.md)

## Incident summary

An authorized IT employee was unable to list the contents of the IT departmental network share. The issue was reproduced after a controlled removal of the NTFS Allow permission assigned to `CORP\DL-IT-Share-Modify`. Network connectivity remained functional.

> This was a deliberately introduced fault in an isolated home lab, not a production incident.

## Reported symptom

While signed in as `CORP\alex.morgan`, the client command:

```powershell
Get-ChildItem '\\DC01\IT'
```

returned:

```text
Get-ChildItem : Access to the path '\\DC01\IT' is denied.
CategoryInfo : PermissionDenied
FullyQualifiedErrorId : DirUnauthorizedAccessError
```

## Known-good baseline

Prior to the simulated incident:

- `SG-IT-Users` was a Global Security group containing Alex Morgan.
- `DL-IT-Share-Modify` was a Domain Local Security group containing `SG-IT-Users`.
- The Domain Local group had **NTFS Modify** and **SMB Change** permissions.
- Alex Morgan could access the share and perform file write, read, and delete operations.
- An HR test user outside the IT groups was denied folder listing and file creation.

## Timeline and troubleshooting actions

| Sequence | Action | Evidence / finding |
| --- | --- | --- |
| 1 | Disconnect HR test SMB session | `net use` showed no remaining entries |
| 2 | Recheck Alex Morgan's access | `Get-ChildItem '\\DC01\IT'` completed without errors |
| 3 | Back up ACL | `icacls /save` processed one file successfully |
| 4 | Simulate fault | Removed `CORP\DL-IT-Share-Modify` Allow ACE using `icacls /remove:g` |
| 5 | Inspect ACL | IT access group no longer appeared; Administrators and SYSTEM remained |
| 6 | Reproduce symptom on client | `Get-ChildItem` returned `Access is denied` |
| 7 | Test network path | `Test-NetConnection DC01 -Port 445` returned `TcpTestSucceeded : True` |
| 8 | Restore permission | `icacls /grant:r` re-added IT group Modify ACE |
| 9 | Verify ACL and access | Group ACE restored; Alex Morgan successfully wrote, read, and deleted a test file |

## Root cause

**Missing NTFS Allow ACE for `CORP\DL-IT-Share-Modify` on `C:\CorpShares\IT`.** The removal prevented the authorized user's nested security group from granting the necessary filesystem access. SMB connectivity and share-level permissions were not the cause.

## Resolution

On DC01, restored the IT access group's Modify permission:

```powershell
icacls 'C:\CorpShares\IT' /grant:r 'CORP\DL-IT-Share-Modify:(OI)(CI)M'
```

Confirmed the final ACL:

```text
C:\CorpShares\IT BUILTIN\Administrators:(F)
                 CORP\DL-IT-Share-Modify:(OI)(CI)(M)
                 NT AUTHORITY\SYSTEM:(OI)(CI)(F)
                 BUILTIN\Administrators:(OI)(CI)(F)
```

The inheritance protection check returned `True` (`AreAccessRulesProtected`), and the SMB share ACL continued to show `CORP\DL-IT-Share-Modify: Change` and `BUILTIN\Administrators: Full`.

## Post-resolution validation

From WIN11-CLIENT01 as `CORP\alex.morgan`:

```powershell
Set-Content '\\DC01\IT\INC-012-Resolution-Test.txt' `
    'INC-012 resolved - NTFS permissions restored'
Get-Content '\\DC01\IT\INC-012-Resolution-Test.txt'
Remove-Item '\\DC01\IT\INC-012-Resolution-Test.txt'
Test-Path '\\DC01\IT\INC-012-Resolution-Test.txt'
```

Observed the expected content on read and `False` after deleting the test file, without permission errors. Final server-side checks also confirmed the NTFS ACE, SMB share ACL, and AD group nesting.

**Resolution status:** Verified resolved.

## Lessons learned / prevention

- Check **NTFS and share permissions separately** when SMB connectivity succeeds but filesystem access fails.
- Use AD security groups rather than individual user ACEs for scalable access management.
- Preserve Administrators and SYSTEM access when modifying folder permissions.
- Capture an ACL backup before permission changes; the lab backup was stored at `C:\LabReports\Lab12-IT-ACL-PreIncident.txt`.
- Validate remediation from the affected user's client, not only from an administrator session on the server.

## Supporting evidence commands

```powershell
# On DC01
icacls 'C:\CorpShares\IT'
Get-SmbShareAccess -Name 'IT'
Get-ADGroupMember -Identity 'DL-IT-Share-Modify'

# On WIN11-CLIENT01
whoami
Test-NetConnection -ComputerName DC01 -Port 445
Get-ChildItem '\\DC01\IT'
```

**Closure note:** Simulated incident INC-012 closed after restoration of the IT group's NTFS Modify ACE and successful client-side read/write/delete validation.
