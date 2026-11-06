# INC-002 — Domain Login Failure (Simulated)

| Field | Value |
| --- | --- |
| Incident ID | `INC-002` |
| Title | Domain account authentication failure — disabled user account |
| Date | November 6, 2026 |
| Status | **Resolved — validated** |
| Incident type | Identity and Access Management / Windows authentication |
| Environment | VirtualBox enterprise service desk lab |
| Affected user | Taylor Brooks (`CORP\taylor.brooks`) |
| Affected workstation | `WIN11-CLIENT01` |
| Domain controller | `DC01.corp.example.test` |
| Severity / SLA | Not formally assigned; simulated lab incident |

## 1. Reported issue

The test user could not authenticate to launch a process on a domain-joined Windows 11 workstation. The `runas` command failed with Windows error **1327**: account restrictions prevented sign-in.

**Scope:** A controlled lab scenario. The account was deliberately disabled for training purposes; this was not an unplanned production outage.

## 2. Initial assessment

Baseline checks confirmed the workstation's domain secure channel and connectivity to the domain controller were functional. Before the test, `taylor.brooks` was enabled, unlocked, and the password was not expired. The account was then deliberately disabled on `DC01`:

```powershell
Disable-ADAccount -Identity 'taylor.brooks'
Get-ADUser -Identity 'taylor.brooks' -Properties Enabled,LockedOut |
    Select-Object Name,Enabled,LockedOut
```

**Result:** `Enabled=False`, `LockedOut=False`.

## 3. Reproduction

On `WIN11-CLIENT01`:

```powershell
runas /user:CORP\taylor.brooks "cmd.exe"
```

**Result:** Command Prompt did not launch. `RUNAS ERROR` **1327** reported account restrictions. This error alone was not treated as conclusive proof of the precise restriction.

## 4. Investigation and evidence

Security auditing on the workstation was configured for **Logon: Success and Failure**. Windows Security log evidence included:

| Time (local) | Event ID | Details |
| --- | --- | --- |
| Nov. 6, 2026, 1:31:28 PM | **4625** | Failed logon for `CORP\taylor.brooks`; Logon Type `2`; failure reason **Account currently disabled**; Status `0xC000006E`; SubStatus **`0xC0000072`** |
| Nov. 6, 2026, 1:20:06 PM | **4648** | Explicit credentials supplied for `CORP\taylor.brooks`; does not independently establish outcome |
| Nov. 6, 2026, 1:19:52 PM | **4625** | Separate invalid-credential result: Status `0xC000006D`, SubStatus `0xC000006A`; not assumed to have the same cause |

**Confirmed root cause:** The domain account was disabled in Active Directory. Event 4625 explicitly reported **Account currently disabled**, corroborating the AD account state.

## 5. Resolution

On `DC01`, restored the account:

```powershell
Enable-ADAccount -Identity 'taylor.brooks'
Get-ADUser -Identity 'taylor.brooks' -Properties Enabled,LockedOut,PasswordExpired |
    Select-Object Name,Enabled,LockedOut,PasswordExpired
```

**Result:** `Enabled=True`, `LockedOut=False`, `PasswordExpired=False`.

No password reset, profile deletion, registry modification, or domain rejoin was required.

## 6. Post-resolution validation

On `WIN11-CLIENT01`, the `runas` command succeeded and opened a new Command Prompt:

```powershell
runas /user:CORP\taylor.brooks "cmd.exe"
```

Inside the new process:

```cmd
whoami
```

**Result:** `corp\taylor.brooks`.

Final domain checks also passed:

| Test | Result |
| --- | --- |
| `Test-ComputerSecureChannel` | `True` |
| `nltest /dsgetdc:corp.example.test` | `DC01.corp.example.test` at `192.168.100.10`; successful |
| `Test-NetConnection 192.168.100.10 -Port 389` | `TcpTestSucceeded=True` |

The user profile investigation found expected registered profile directories, no `.bak` ProfileList keys, a running automatic `ProfSvc` service, and no critical/error/warning events returned from the User Profile Service Operational log for the preceding seven days (log enabled, 202 total records).

**Validation limit:** Successful `runas` authentication does not independently verify a new interactive desktop sign-in or full profile loading. No profile corruption was demonstrated in this lab.

## 7. Resolution summary

**Disposition:** Resolved in the controlled lab. Authentication was restored by re-enabling the domain account. Domain trust and LDAP connectivity remained healthy. No profile remediation was necessary.

**Service desk learning:** Distinguish general sign-in errors from definitive event-log evidence; confirm account state in Active Directory; apply the smallest appropriate fix; validate authentication after remediation; document related but distinct invalid-password events without conflating their causes.

## 8. Evidence references

- Lab walkthrough: [Lab 17 — Domain Login and User Profile Troubleshooting](lab17-domain-login-profile-troubleshooting.md)
- Suggested screenshots, if captured: `lab17-03-runas-error-1327.png`, `lab17-04-event-4625-account-disabled.png`, `lab17-05-account-restored.png`, `lab17-09-runas-success-whoami.png`, `lab17-10-final-domain-validation.png`

> Do not include account passwords or other authentication secrets in repository screenshots.
