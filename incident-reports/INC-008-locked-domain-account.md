# INC-008 — Locked Domain Account

| Field | Detail |
|---|---|
| Ticket type | Incident |
| Status | Resolved (lab simulation) |
| Affected service | Active Directory domain authentication |
| Environment | `corp.example.test` / DC01 / WIN11-CLIENT01 |
| Affected user | Alex Morgan (`alex.morgan`) |
| Impact | Simulated inability to sign in with a locked domain account |
| Priority / timestamps | Not recorded |

## Reported issue
A domain account became locked after intentionally unsuccessful sign-in attempts during a controlled lab exercise.

## Investigation
The domain initially had a lockout threshold of `0`, which disables automatic account lockout. For the simulation only, the threshold was changed to five attempts, with a 10-minute duration and observation window.

```powershell
Get-ADDefaultDomainPasswordPolicy |
    Select-Object LockoutThreshold,LockoutDuration,LockoutObservationWindow

Set-ADDefaultDomainPasswordPolicy -Identity 'corp.example.test' `
    -LockoutThreshold 5 `
    -LockoutDuration '00:10:00' `
    -LockoutObservationWindow '00:10:00'
```

Following simulated failed logins, checked the account:

```powershell
Get-ADUser -Identity 'alex.morgan' -Properties LockedOut,Enabled |
    Select-Object Name,SamAccountName,LockedOut,Enabled
```

**Before remediation:**

```text
Name        SamAccountName LockedOut Enabled
Alex Morgan alex.morgan         True    True
```

## Resolution steps

1. Unlocked the account:

   ```powershell
   Unlock-ADAccount -Identity 'alex.morgan'
   ```

2. Rechecked the user state.

   ```text
   Name        SamAccountName LockedOut Enabled
   Alex Morgan alex.morgan        False    True
   ```

3. Restored the original lockout threshold:

   ```powershell
   Set-ADDefaultDomainPasswordPolicy -Identity 'corp.example.test' -LockoutThreshold 0
   ```

4. Verified the restored policy:

   ```text
   LockoutThreshold LockoutDuration LockoutObservationWindow
                  0 00:10:00        00:10:00
   ```

## Root cause
Intentional incorrect password submissions in the lab after a temporary lockout policy change. This was a controlled simulation, not an unexplained production authentication failure.

## Resolution verification
**Passed:** `LockedOut=False`, `Enabled=True`, and original domain `LockoutThreshold=0` restored. A separate post-unlock interactive login test was not recorded.

## Prevention / operational notes
In production, identify the source of repeated authentication failures (e.g., cached credentials, scheduled tasks, or stale sessions) before assuming the problem is resolved. Changes to domain-wide security policy require approval and change control.

**Related lab:** [`../docs/15-lab10-active-directory-user-group-administration.md`](../docs/15-lab10-active-directory-user-group-administration.md)
