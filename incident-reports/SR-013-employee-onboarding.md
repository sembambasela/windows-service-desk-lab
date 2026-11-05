# SR-013 — Employee Onboarding

| Field | Value |
| --- | --- |
| Type | Simulated IAM service request |
| Environment | `corp.example.test` / `DC01` / `WIN11-CLIENT01` |
| Employee | Jordan Lee (`jordan.lee`) |
| Initial department | IT |
| Requested outcome | Provision domain identity and approved IT resource access |
| Status | Completed and verified in lab |
| Related lab | [Lab 13](../docs/18-lab13-identity-access-management.md) |

## Request summary

Simulate onboarding a new IT employee by creating an enabled Active Directory account, requiring a password change at first logon, and granting access to the IT file share through existing departmental security groups.

## Actions performed

1. Created `CN=Jordan Lee,OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test` with `New-ADUser`.
2. Set `SamAccountName=jordan.lee`, `UPN=jordan.lee@corp.example.test`, and `Department=IT`.
3. Assigned a temporary password using a `SecureString`, enabled the account, and required password change at first logon.
4. Verified initial membership was `Domain Users` only.
5. Added Jordan to `SG-IT-Users`; confirmed that group was nested in `DL-IT-Share-Modify`.
6. Signed in on `WIN11-CLIENT01` as `CORP\jordan.lee` and tested `\\DC01\IT`.

## Verification evidence

| Test | Observed result |
| --- | --- |
| Account enabled | `True` |
| `PasswordNotRequired` | `False` |
| Initial password change required | `PasswordExpired=True`; `PasswordLastSet` blank |
| Initial department/OU | IT / IT OU |
| IT Global group | Jordan Lee and Alex Morgan |
| Nested Domain Local group | `DL-IT-Share-Modify` contained `SG-IT-Users` |
| Client security token | Included both IT groups |
| File access | List, create, write, read, and delete succeeded |
| Cleanup | Test file removed; `Test-Path=False` |

**Outcome:** Provisioning and IT resource access tests passed. The employee was later transferred and offboarded under separate simulated requests.

## Controls demonstrated

Least privilege through group-based authorization, separation of identity creation from resource permissions, mandatory initial password change, and practical client-side access verification.

**Evidence note:** Simulated request; no real approval workflow, password value, or screenshot attachment is included.
