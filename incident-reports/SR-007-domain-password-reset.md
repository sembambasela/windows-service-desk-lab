# SR-007 — Domain Password Reset

| Field | Detail |
|---|---|
| Ticket type | Service Request |
| Status | Completed (lab simulation) |
| Environment | `corp.example.test` / DC01 / WIN11-CLIENT01 |
| Affected user | Alex Morgan (`alex.morgan`) |
| Authorization | Simulated request; no real identity verification or approval record |

## Request
Reset a domain user's password and require a password change at the next sign-in.

## Actions performed

```powershell
Set-ADAccountPassword -Identity 'alex.morgan' -Reset `
    -NewPassword (Read-Host 'Enter temporary password' -AsSecureString)
Set-ADUser -Identity 'alex.morgan' -ChangePasswordAtLogon $true
```

The initial password-change-required verification did not reflect the intended state. Reapplied `ChangePasswordAtLogon` and confirmed `PasswordLastSet` was blank and `PasswordExpired` was `True` at that stage.

## Verification evidence

Domain sign-in on WIN11-CLIENT01:

```text
whoami             -> corp\alex.morgan
USERDNSDOMAIN      -> CORP.EXAMPLE.TEST
```

Final account inspection recorded:

```text
PasswordLastSet : 11/4/2026 4:41:00 PM
Enabled         : True
LockedOut       : False
```

The exact interactive password-change screen was not independently recorded. Do not interpret this report as evidence of a completed identity verification process or a production reset.

## Resolution
Password reset command completed, change-at-next-sign-in requirement was verified at the time of configuration, and subsequent domain sign-in and password timestamp were recorded.

## Security notes
Never store passwords in tickets, screenshots, shell history, or repositories. In production, verify the requester's identity using approved procedures before resetting credentials.

**Related lab:** [`../docs/15-lab10-active-directory-user-group-administration.md`](../docs/15-lab10-active-directory-user-group-administration.md)
