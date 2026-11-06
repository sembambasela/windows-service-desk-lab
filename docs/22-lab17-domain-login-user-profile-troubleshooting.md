# Lab 17 — Domain Login and User Profile Troubleshooting

## Objective
Investigate a controlled domain authentication failure, examine Windows user profile health, restore the test account, and verify domain connectivity.

## Environment
- Domain: `corp.example.test` (NetBIOS: `CORP`)
- Domain controller: `DC01` — `192.168.100.10`
- Workstation: `WIN11-CLIENT01` — `192.168.100.20`
- Test account: `CORP\taylor.brooks`
- Investigation date: November 6, 2026

## 1. Domain authentication baseline
On WIN11-CLIENT01, domain controller discovery using `nltest /dsgetdc:corp.example.test`, DNS resolution, and TCP port 389 connectivity were previously verified. DC01 AD queries confirmed test accounts were initially enabled, unlocked, and not password-expired.

## 2. Simulated sign-in failure
On DC01, the test account was disabled:

```powershell
Disable-ADAccount -Identity 'taylor.brooks'
Get-ADUser 'taylor.brooks' -Properties Enabled,LockedOut |
  Select-Object Name,Enabled,LockedOut
```

Observed: `Enabled=False`, `LockedOut=False`.

Two `runas /user:CORP\taylor.brooks "cmd.exe"` attempts failed with Windows error **1327**, indicating an account restriction. The disabled state is consistent with the observed failure, but the exact restriction was **not** independently established by an authentication event.

## 3. Security event investigation
- Queries for IDs **4625**, **4771**, and **4776** on DC01 returned no events matching the account in the queried time window.
- A first query for ID **4648** was inadvertently run on DC01; its returned events concerned other accounts and system processes, not Taylor.
- After confirming `hostname` was `WIN11-CLIENT01`, a four-hour query for IDs **4625** and **4648**, filtered for `taylor.brooks` or `runas.exe`, returned no matches.
- On WIN11-CLIENT01, `auditpol /get /subcategory:"Logon"` reported **Success and Failure**. The Security log was enabled and contained **14,417** records at inspection.

**Interpretation:** The failure was reproduced, but no corresponding event was located with the selected IDs, filters, and time ranges. Do not claim an event confirmed the root cause.

## 4. Profile health inspection
On WIN11-CLIENT01:

```powershell
whoami
$env:USERPROFILE
Get-CimInstance Win32_UserProfile |
  Select-Object LocalPath,Loaded,Special,Status
Get-ChildItem C:\Users -Force
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' |
  ForEach-Object { Get-ItemProperty $_.PSPath |
    Select-Object PSChildName,ProfileImagePath,State,RefCount }
Get-Service ProfSvc
```

Findings:
- PowerShell was running as `CORP\Administrator`, profile `C:\Users\Administrator`.
- Registered regular profiles: Administrator, `alex.morgan`, `jordan.lee`, `taylor.brooks`, LabAdmin. All had CIM `Status=0` and corresponding `C:\Users` directories.
- Administrator and Jordan profiles were loaded at inspection; other regular profiles were not.
- No `.bak` keys were found under `ProfileList`.
- Administrator registry `State=256`; other listed profile registry states were `0`. No registry values were modified; `State=256` alone does not establish corruption.
- `ProfSvc` was **Running**, startup **Automatic**.
- Application log contained informational User Profile Service events **1531** (started) and **1532** (stopped).
- User Profile Service Operational log was enabled, with **182** records. A seven-day query for Warning, Error, and Critical events returned no matches.

**Interpretation:** No current profile-loading issue was identified by the checks performed. No destructive profile simulation was undertaken.

## 5. Recovery and final verification
On DC01:

```powershell
Enable-ADAccount -Identity 'taylor.brooks'
Get-ADUser 'taylor.brooks' -Properties Enabled,LockedOut,PasswordExpired |
  Select-Object Name,Enabled,LockedOut,PasswordExpired
```

Verified: `Enabled=True`, `LockedOut=False`, `PasswordExpired=False`.

On WIN11-CLIENT01:

```powershell
hostname
Test-ComputerSecureChannel
nltest /dsgetdc:corp.example.test
```

Verified:
- Hostname: `WIN11-CLIENT01`
- Secure channel: `True`
- Domain controller: `\\DC01.corp.example.test`, `192.168.100.10`
- Domain controller discovery command completed successfully; flags included `KDC` and `LDAP`.

## Outcome
**Completed.** The controlled account restriction was reproduced and reversed, the user profile baseline showed no identified loading errors, and domain secure-channel/discovery checks passed. The exact reason for error 1327 was not independently proven by a matching Security event.

## Portfolio skills
Active Directory account administration; Windows authentication diagnostics; Security log auditing; PowerShell; user profile and registry inspection; User Profile Service diagnostics; domain trust and DC discovery; incident documentation.
