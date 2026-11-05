# SR-010 — Active Directory Account Reactivation

| Field | Detail |
|---|---|
| Ticket type | Service Request |
| Status | Completed (lab simulation) |
| Environment | `corp.example.test` / DC01 |
| Affected user | Alex Morgan (`alex.morgan`) |
| Scenario | Authorized restoration of a disabled account |
| Authorization | Simulated as approved; no real approval record |

## Request
Re-enable a previously disabled domain account and confirm that its security group membership remains intact.

## Action performed

```powershell
Enable-ADAccount -Identity 'alex.morgan'
Get-ADUser -Identity 'alex.morgan' -Properties Enabled |
    Select-Object Name,SamAccountName,Enabled
```

## Verification evidence

```text
Name        SamAccountName Enabled
Alex Morgan alex.morgan       True
```

Final account review:

```text
Enabled   : True
LockedOut : False
```

```text
Name         GroupScope GroupCategory
Domain Users Global     Security
SG-IT-Users  Global     Security
```

## Resolution
Account reactivation succeeded. The account was enabled, unlocked, and retained its IT security group membership.

## Operational notes
In production, reactivation should be based on an approved request and an access review to ensure existing group memberships are still appropriate.

**Related ticket:** [`SR-009-account-deactivation.md`](SR-009-account-deactivation.md)  
**Related lab:** [`../docs/15-lab10-active-directory-user-group-administration.md`](../docs/15-lab10-active-directory-user-group-administration.md)
