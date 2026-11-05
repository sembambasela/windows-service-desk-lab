# SR-015 — Employee Offboarding

| Field | Value |
| --- | --- |
| Type | Simulated IAM deprovisioning request |
| Employee | Jordan Lee (`CORP\jordan.lee`) |
| Department at offboarding | HR |
| Requested outcome | Disable identity, revoke departmental group access, retain audit object |
| Status | Completed and verified in lab |
| Related lab | [Lab 13](../docs/18-lab13-identity-access-management.md) |

## Request summary

Simulate an approved departure and prevent new domain sign-ins without deleting the directory object. Remove HR role membership and verify final AD state.

## Pre-change state

- `Enabled=True`, `Department=HR`, account located in HR OU.
- Group memberships returned: `Domain Users`, `SG-HR-Users`.
- `SG-HR-Users` contained Jordan Lee.
- AD `LastLogonDate` displayed `11/5/2026 12:48:37 PM`; this is not a comprehensive sign-in audit.

## Actions performed

```powershell
Disable-ADAccount -Identity "jordan.lee"
Set-ADUser -Identity "jordan.lee" `
    -Description "Lab 13 - SR-015 - Simulated employee offboarding - Account disabled"
Remove-ADGroupMember -Identity "SG-HR-Users" -Members "jordan.lee" -Confirm:$false
```

The AD object was deliberately retained in the HR OU for the lab's audit trail.

## Post-change verification

| Test | Observed result |
| --- | --- |
| `Enabled` | `False` |
| Department | HR |
| Distinguished name | `CN=Jordan Lee,OU=HR,OU=Corp-Users,DC=corp,DC=example,DC=test` |
| Description | `Lab 13 - SR-015 - Simulated employee offboarding - Account disabled` |
| Remaining membership | `Domain Users` only |
| HR Global group | No members |
| IT Global group | Alex Morgan only |
| Fresh Windows sign-in as Jordan | Rejected because the account is disabled |

**Outcome:** Planned account deactivation, departmental group removal, and fresh interactive sign-in rejection tests passed.

## Security and audit considerations

- A disabled AD account does not guarantee immediate termination of existing logon sessions, SMB connections, or issued Kerberos tickets.
- This lab verified a **new** sign-in rejection, not comprehensive session/ticket revocation.
- Production offboarding should additionally follow approved identity, device, application, session, data retention, and audit procedures.
- This was a simulated request; no production approval, ticketing platform, or event-log export was provided.
