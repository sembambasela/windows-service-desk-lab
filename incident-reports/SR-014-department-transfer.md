# SR-014 — Employee Department Transfer (IT → HR)

| Field | Value |
| --- | --- |
| Type | Simulated IAM access modification request |
| Employee | Jordan Lee (`CORP\jordan.lee`) |
| Previous department | IT |
| New department | HR |
| Requested outcome | Remove IT access and provision authorized HR access |
| Status | Completed and verified in lab |
| Related lab | [Lab 13](../docs/18-lab13-identity-access-management.md) |

## Request summary

Simulate a department transfer and validate that old permissions are revoked before new departmental access is assigned.

## Actions performed

1. Set `Department=HR` and moved Jordan's AD object to `OU=HR,OU=Corp-Users,DC=corp,DC=example,DC=test`.
2. Removed Jordan from `SG-IT-Users`; preserved Alex Morgan's membership.
3. Signed out and back in on `WIN11-CLIENT01` to refresh the security token.
4. Confirmed both former IT groups were absent and `\\DC01\IT` returned **Access is denied** while TCP 445 remained reachable.
5. Created `SG-HR-Users` (Global Security) and `DL-HR-Share-Modify` (Domain Local Security).
6. Added Jordan to the HR Global group and nested it in the HR Domain Local group.
7. Inspected `C:\CorpShares\HR`, which initially had inherited `BUILTIN\Users` permissions and no SMB share.
8. Used the lab procedure to back up the ACL, remove inheritance, and grant Administrators/SYSTEM Full Control and `DL-HR-Share-Modify` Modify.
9. Created `\\DC01\HR` with Administrators Full and `DL-HR-Share-Modify` Change share permissions.
10. Re-signed in and verified effective HR access while IT access remained denied.

## Verification evidence

| Test | Observed result |
| --- | --- |
| Department and OU | HR / HR OU |
| IT Global group after removal | Alex Morgan only |
| Old IT security token groups | Absent after fresh sign-in |
| Old IT share | `Access is denied` |
| SMB connectivity to DC01 | `TcpTestSucceeded=True` on port 445 |
| HR group nesting | `SG-HR-Users` inside `DL-HR-Share-Modify` |
| HR NTFS inheritance | `AreAccessRulesProtected=True` |
| HR NTFS permissions | Administrators/SYSTEM Full, HR Domain Local group Modify |
| HR SMB permissions | Administrators Full, HR Domain Local group Change |
| HR client security token | Included both HR groups |
| HR file test | List/create/write/read/delete succeeded; `Test-Path=False` |
| IT share retest | `Access is denied` |

**Outcome:** IT-to-HR transfer completed with effective access removal and re-provisioning verified from the domain-joined workstation.

## Controls demonstrated

Role-based access control, AGDLP nesting, least-privilege transitions, NTFS and SMB permission management, and separating network availability from authorization.

**Evidence note:** Simulated request; approvals and production change controls were not part of this exercise.
