# SR-006 — New Employee Onboarding

| Field | Detail |
|---|---|
| Ticket type | Service Request |
| Status | Completed (lab simulation) |
| Environment | `corp.example.test` / DC01 |
| Requester | Simulated onboarding request; no actual requester recorded |
| Affected user | Alex Morgan (`alex.morgan`) |
| Business unit | IT |
| Authorization | Simulated request; no real approval record |

## Request
Provision a new domain account for a fictional IT employee and assign the appropriate security group.

## Actions performed
1. Created the enabled domain user `alex.morgan` in `OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test`.
2. Created the global security group `SG-IT-Users` in `OU=Corp-Groups`.
3. Added `alex.morgan` to `SG-IT-Users`.
4. Verified the user object and security group membership.

## Verification evidence

```text
UserPrincipalName : alex.morgan@corp.example.test
DistinguishedName : CN=Alex Morgan,OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test
Enabled           : True
```

```text
Name         GroupScope GroupCategory
Domain Users Global     Security
SG-IT-Users  Global     Security
```

## Resolution
User account provisioned and assigned to the IT security group. Final lab verification confirmed the account was enabled and retained group membership.

## Notes
This is a simulated service request in an isolated home lab. No production identity or real onboarding approval was involved.

**Related lab:** [`../docs/15-lab10-active-directory-user-group-administration.md`](../docs/15-lab10-active-directory-user-group-administration.md)
