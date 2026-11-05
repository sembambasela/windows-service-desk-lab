# SR-009 — Active Directory Account Deactivation

| Field | Detail |
|---|---|
| Ticket type | Service Request |
| Status | Completed (lab simulation) |
| Environment | `corp.example.test` / DC01 |
| Affected user | Alex Morgan (`alex.morgan`) |
| Scenario | Employee offboarding |
| Authorization | Simulated as approved; no real approval record |

## Request
Disable a departing employee's domain account while retaining the directory object for administrative purposes.

## Action performed

```powershell
Disable-ADAccount -Identity 'alex.morgan'
Get-ADUser -Identity 'alex.morgan' -Properties Enabled |
    Select-Object Name,SamAccountName,Enabled
```

## Verification evidence

```text
Name        SamAccountName Enabled
Alex Morgan alex.morgan      False
```

## Resolution
Account deactivation succeeded and was verified with `Enabled=False`.

## Operational notes
Disabling an AD account does not necessarily revoke already-issued tokens or terminate active sessions. Production offboarding may also require session revocation, access review, device recovery, and other approved controls. The account was later re-enabled under simulated SR-010 to continue the lab.

**Related ticket:** [`SR-010-account-reactivation.md`](SR-010-account-reactivation.md)  
**Related lab:** [`../docs/15-lab10-active-directory-user-group-administration.md`](../docs/15-lab10-active-directory-user-group-administration.md)
