# Lab 10 — Active Directory User and Group Administration

## Overview

This lab simulates common enterprise Service Desk and Identity and Access Management (IAM) tasks in an isolated Windows Active Directory environment. It covers organizational unit (OU) design, user onboarding, group membership, password resets, account lockout troubleshooting, and account lifecycle administration.

**Status:** Completed — final verification passed on November 4, 2026.

## Lab environment

| Component | Configuration |
|---|---|
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Domain controller | DC01 — Windows Server 2025 Standard Evaluation |
| Client | WIN11-CLIENT01 — Windows 11 Pro |
| Active Directory domain | `corp.example.test` (`CORP`) |
| Internal network | `AD-LAB` |
| DC01 internal IP | `192.168.100.10` |
| Client internal IP | `192.168.100.20` |
| Administrative interface | PowerShell ActiveDirectory module |

The domain and account names are fictional lab identities. No production accounts were modified.

## Objectives

- Organize Active Directory users, groups, and workstations using OUs.
- Provision a domain user and assign role-based security group membership.
- Perform a password reset and require a password change at next sign-in.
- Reproduce and resolve a domain account lockout.
- Disable and re-enable a user account as part of the employee lifecycle.
- Validate account status, OU placement, and security group membership.

## 1. Organizational unit structure

Created the following OUs:

```text
corp.example.test
├── Corp-Users
│   ├── IT
│   ├── HR
│   └── Finance
├── Corp-Groups
└── Corp-Workstations
```

Moved the existing domain-joined client computer object into:

```text
CN=WIN11-CLIENT01,OU=Corp-Workstations,DC=corp,DC=example,DC=test
```

**Result:** OU creation and workstation relocation were verified during the lab.

## 2. User onboarding — SR-006

Created the simulated new employee:

| Attribute | Value |
|---|---|
| Display name | Alex Morgan |
| sAMAccountName | `alex.morgan` |
| UPN | `alex.morgan@corp.example.test` |
| Departmental OU | `OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test` |
| Account status | Enabled |

The user object was verified at:

```text
CN=Alex Morgan,OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test
```

## 3. Security group provisioning

Created the **global security group** `SG-IT-Users` in `OU=Corp-Groups`, then added `alex.morgan`.

Example verification commands:

```powershell
Get-ADGroupMember -Identity 'SG-IT-Users'
Get-ADPrincipalGroupMembership -Identity 'alex.morgan' |
    Select-Object Name, GroupScope, GroupCategory
```

**Verified memberships:**

```text
Name         GroupScope GroupCategory
----         ---------- -------------
Domain Users Global     Security
SG-IT-Users  Global     Security
```

The group membership was also confirmed after the account was disabled and re-enabled.

## 4. Password reset — SR-007

Simulated an administrative password reset using a securely prompted password rather than placing credentials in commands or documentation:

```powershell
Set-ADAccountPassword -Identity 'alex.morgan' -Reset `
    -NewPassword (Read-Host 'Enter temporary password' -AsSecureString)

Set-ADUser -Identity 'alex.morgan' -ChangePasswordAtLogon $true
```

The initial check did not show the required password-change state. The `ChangePasswordAtLogon` setting was applied again, and subsequent verification showed `PasswordLastSet` blank and `PasswordExpired` as `True`, indicating that a password change was required.

A subsequent domain sign-in was verified on WIN11-CLIENT01:

```text
whoami                  -> corp\alex.morgan
$env:USERDNSDOMAIN      -> CORP.EXAMPLE.TEST
```

**Final verification:** `PasswordLastSet` was `11/4/2026 4:41:00 PM`. The exact password-change interaction at the sign-in screen was not independently captured in the lab notes; the final timestamp and domain sign-in are the recorded evidence.

## 5. Account lockout and recovery — INC-008

### Baseline policy

Before the exercise, the default domain policy reported:

```text
LockoutThreshold         0
LockoutDuration          00:10:00
LockoutObservationWindow 00:10:00
```

A threshold of `0` meant automatic account lockout was disabled.

### Temporary lab policy

For the isolated exercise, configured a five-attempt threshold:

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity 'corp.example.test' `
    -LockoutThreshold 5 `
    -LockoutDuration '00:10:00' `
    -LockoutObservationWindow '00:10:00'
```

Simulated failed sign-ins on WIN11-CLIENT01, then checked the domain account:

```powershell
Get-ADUser -Identity 'alex.morgan' -Properties LockedOut,Enabled |
    Select-Object Name,SamAccountName,LockedOut,Enabled
```

**Observed result before remediation:**

```text
Name        SamAccountName LockedOut Enabled
----        -------------- --------- -------
Alex Morgan alex.morgan         True    True
```

### Resolution

```powershell
Unlock-ADAccount -Identity 'alex.morgan'
```

**Observed result after remediation:**

```text
Name        SamAccountName LockedOut Enabled
----        -------------- --------- -------
Alex Morgan alex.morgan        False    True
```

### Policy restoration

Restored the original threshold:

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity 'corp.example.test' -LockoutThreshold 0
Get-ADDefaultDomainPasswordPolicy |
    Select-Object LockoutThreshold,LockoutDuration,LockoutObservationWindow
```

**Verified final values:**

```text
LockoutThreshold LockoutDuration LockoutObservationWindow
---------------- --------------- ------------------------
               0 00:10:00        00:10:00
```

**Outcome:** Account unlocked, account enabled, and original domain policy restored. The temporary policy change was restricted to the isolated lab; it would require formal authorization and change controls in a production domain.

## 6. Account deactivation — SR-009

Simulated an authorized employee offboarding request:

```powershell
Disable-ADAccount -Identity 'alex.morgan'
Get-ADUser -Identity 'alex.morgan' -Properties Enabled |
    Select-Object Name,SamAccountName,Enabled
```

**Verified result:**

```text
Name        SamAccountName Enabled
----        -------------- -------
Alex Morgan alex.morgan      False
```

Disabling the account prevents new domain sign-ins while preserving the AD object and its memberships. Existing sessions and tokens may require separate revocation during real offboarding.

## 7. Account reactivation — SR-010

Simulated an authorized account restoration:

```powershell
Enable-ADAccount -Identity 'alex.morgan'
Get-ADUser -Identity 'alex.morgan' -Properties Enabled |
    Select-Object Name,SamAccountName,Enabled
```

**Verified result:**

```text
Name        SamAccountName Enabled
----        -------------- -------
Alex Morgan alex.morgan       True
```

## 8. Final verification

Ran:

```powershell
Get-ADUser -Identity 'alex.morgan' `
    -Properties Enabled,LockedOut,PasswordLastSet,UserPrincipalName,DistinguishedName |
    Select-Object Name,SamAccountName,Enabled,LockedOut,PasswordLastSet,UserPrincipalName,DistinguishedName

Get-ADPrincipalGroupMembership -Identity 'alex.morgan' |
    Select-Object Name,GroupScope,GroupCategory
```

**Actual recorded output:**

```text
Name              : Alex Morgan
SamAccountName    : alex.morgan
Enabled           : True
LockedOut         : False
PasswordLastSet   : 11/4/2026 4:41:00 PM
UserPrincipalName : alex.morgan@corp.example.test
DistinguishedName : CN=Alex Morgan,OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test

Name         GroupScope GroupCategory
----         ---------- -------------
Domain Users     Global      Security
SG-IT-Users      Global      Security
```

All final account and membership checks passed.

## Service Desk case references

| ID | Type | Scenario | Outcome |
|---|---|---|---|
| SR-006 | Service request | New employee onboarding | Account created and group assigned |
| SR-007 | Service request | Password reset | Reset performed; change required at next sign-in |
| INC-008 | Incident | Locked domain account | Account unlocked; original policy restored |
| SR-009 | Service request | Account deactivation | Account disabled and verified |
| SR-010 | Service request | Account reactivation | Account enabled and verified |

Detailed case reports are stored separately in [`../incident-reports/`](../incident-reports/).

## Key takeaways

- OUs provide a logical structure for administration and policy targeting; security groups manage access assignments.
- User onboarding and offboarding require validation of account state and group memberships.
- A disabled account and a locked account are different states requiring different administrative actions.
- Password reset workflows should avoid exposing temporary credentials in logs or documentation.
- Domain-wide policy changes should be temporary, controlled, and verified after restoration.
- Final PowerShell verification provides reproducible evidence for Service Desk tickets and audits.

## Completion status

**Lab 10 completed.** All recorded checkpoints were verified. The environment was left with `alex.morgan` enabled and unlocked, retaining `SG-IT-Users` membership, and the domain lockout threshold restored to its original value of `0`.
