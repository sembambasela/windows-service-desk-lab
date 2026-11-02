# INC-003 — Department Folder Access Denied

**Category:** File Permissions / Access Management  
**Priority:** Medium  
**Status:** Resolved  
**Affected User:** Jordan Doe (`jdoe`)  
**Affected Resource:** `C:\DepartmentFiles`

## Incident Description

A standard Windows user was unable to access a departmental folder due to restrictive NTFS permissions.

## Investigation

1. Inspected folder permissions using Windows Advanced Security Settings.
2. Identified inherited permissions from the C: drive.
3. Disabled inheritance on the test folder and configured restricted access.
4. Reproduced the Access Denied error using the standard user account.
5. Investigated folder and file permissions using `icacls`.
6. Identified that the folder and its contained file had different effective access configurations.

## Resolution

Configured read-only access for `jdoe` while preserving Full Control for Administrators and SYSTEM.

Used the following commands to investigate and configure permissions:

```cmd
icacls "C:\DepartmentFiles"
icacls "C:\DepartmentFiles\DepartmentPolicy.txt"
icacls "C:\DepartmentFiles\DepartmentPolicy.txt" /grant "jdoe:(R)"
```

## Verification

- [x] User can access the department folder.
- [x] User can open and read the department policy.
- [x] User cannot save unauthorized modifications to the original file.
- [x] Administrator and SYSTEM access preserved.

## Root Cause

The simulated incident was caused by intentionally restricting NTFS permissions on the departmental folder. During remediation, the file's access control entries also required investigation and adjustment.

## Resolution Summary

Restored appropriate read-only access to the affected employee account while maintaining least-privilege security.

**Final Status:** Resolved

## Skills Demonstrated

- NTFS access control
- Permission inheritance
- Windows security administration
- Command-line troubleshooting with `icacls`
- Incident resolution and documentation