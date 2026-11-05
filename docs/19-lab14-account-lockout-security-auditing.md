# Lab 14 — Active Directory Account Lockout and Security Auditing

## Objective
Simulate an account lockout using a dedicated test account, investigate Security events on the domain controller, recover access, and improve authentication-failure auditing.

## Lab environment
- Domain: `corp.example.test` (`CORP`)
- Domain controller: `DC01` (Windows Server 2025)
- Client: `WIN11-CLIENT01` (Windows 11)
- Dedicated test user: `CORP\taylor.brooks` (Taylor Brooks), IT OU
- Internal client address observed in Kerberos event: `192.168.100.20`

## Initial configuration
- Default domain password policy: complexity enabled; minimum password length 7; maximum password age 42 days; lockout threshold **0** (never); lockout duration 10 minutes; observation window 10 minutes.
- No Fine-Grained Password Policies (FGPPs) initially existed.
- Kerberos Authentication Service and Credential Validation auditing were initially **Success** only.

## Procedure and evidence

### 1. Create dedicated account
Created enabled `taylor.brooks` in `OU=IT,OU=Corp-Users,DC=corp,DC=example,DC=test` with a compliant password. Verified enabled status, department IT, and populated `PasswordLastSet` (November 5, 2026, 4:44:12 PM).

### 2. Apply isolated test policy
Created `PSO-Lab14-Lockout-Test` with precedence 10, lockout threshold 3, lockout duration 10 minutes, observation window 10 minutes, password complexity enabled, and minimum password length 7. Assigned directly to Taylor Brooks. Verified the resultant password policy applied to that account.

### 3. Trigger account lockout
Performed incorrect sign-in attempts on `WIN11-CLIENT01` (more than three attempts were made). DC01 confirmed:

```text
Name          LockedOut BadPwdCount LastBadPasswordAttempt
Taylor Brooks True      3           11/5/2026 5:01:48 PM
```

### 4. Investigate account lockout event
DC01 Security log contained Event ID **4740** at **November 5, 2026, 5:01:48 PM**:
- Locked account: `taylor.brooks`
- Caller computer: `WIN11-CLIENT01`
- Event subject: `DC01$` / local system

An initial search returned no Event ID 4771 for Taylor. `auditpol` showed Kerberos Authentication Service set to **Success** only. Credential Validation was also **Success** only.

### 5. Enable enhanced auditing
Enabled **Success and Failure** for:
- Kerberos Authentication Service
- Credential Validation

Verified both with `auditpol /get`. These settings were intentionally **retained** at lab completion.

### 6. Recover account and validate failure logging
Following the 10-minute duration, Taylor was observed `LockedOut=False` with `BadPwdCount=3`. Ran `Unlock-ADAccount`, then verified enabled, unlocked, and `BadPwdCount=0`.

Generated one new incorrect password attempt. DC01 recorded Security Event ID **4771** at **November 5, 2026, 5:18:10 PM**:
- Account: `taylor.brooks`
- Client address: `::ffff:192.168.100.20` (IPv4-mapped IPv6)
- Service: `krbtgt/CORP`
- Failure code: `0x18` (invalid pre-authentication information, commonly incorrect password)
- Pre-authentication type: `2`
- Account remained unlocked; `BadPwdCount=1`

No matching Event ID 4776 was returned in that search; the observed failure was Kerberos.

### 7. Cleanup and final verification
Ran `Unlock-ADAccount` again and verified `Enabled=True`, `LockedOut=False`, `BadPwdCount=0`. Removed the test account's FGPP assignment and deleted `PSO-Lab14-Lockout-Test`. Verified no FGPPs remained, no resultant FGPP applied to Taylor, and default domain lockout threshold remained **0**.

Final checks:

| Item | Verified final state |
|---|---|
| Taylor Brooks | Enabled, unlocked, bad password count 0 |
| Temporary FGPP | Removed |
| Default domain lockout threshold | 0 |
| Kerberos Authentication Service audit | Success and Failure |
| Credential Validation audit | Success and Failure |
| Security Event 4740 | Observed |
| Security Event 4771 | Observed after enabling failure auditing |

## Useful PowerShell commands

```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object LockoutThreshold,LockoutDuration,LockoutObservationWindow
Get-ADFineGrainedPasswordPolicy -Filter *
Get-ADUser -Identity 'taylor.brooks' -Properties Enabled,LockedOut,BadPwdCount,LastBadPasswordAttempt
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740;StartTime=(Get-Date).AddHours(-2)}
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4771,4776;StartTime=(Get-Date).AddHours(-2)}
auditpol /get /subcategory:'Kerberos Authentication Service'
auditpol /get /subcategory:'Credential Validation'
```

## Lessons learned
- A dedicated test account and directly assigned FGPP can isolate lockout tests from normal domain users.
- Event ID 4740 identifies the account lockout and caller computer; Event ID 4771 provides Kerberos failure details when failure auditing is enabled.
- A lack of recorded events does not prove a lack of failed attempts; audit configuration must be checked.
- Automatic unlock and manual recovery can be distinguished by checking account status before issuing `Unlock-ADAccount`.
- Retained `auditpol` settings may be superseded by domain Group Policy. A dedicated domain controller audit GPO is recommended for persistent management.
- DC01 DNS resolution also returned a NAT IPv4 address (`10.0.2.15`) and several IPv6 addresses in addition to internal IPv4 `192.168.100.10`; consider reviewing multihomed domain-controller DNS registration separately.

## Related incident
`incident-reports/INC-014-active-directory-account-lockout.md`
