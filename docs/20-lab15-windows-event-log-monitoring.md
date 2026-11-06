# Lab 15 — Windows Event Log Monitoring and Security Incident Response

**Project:** Windows Enterprise IT Service Desk Home Lab  
**Date performed:** November 5, 2026  
**Status:** Completed — monitoring script and export verified; some historical events remain unresolved  
**Environment:** DC01 (Windows Server 2025, AD DS/DNS), WIN11-CLIENT01 (Windows 11 Pro), `corp.example.test`  
**Internal network:** `AD-LAB` — DC01 `192.168.100.10`, WIN11-CLIENT01 `192.168.100.20`

## Objectives

- Review Windows Security audit policy and log configuration.
- Investigate successful and failed authentication, Kerberos failures, and account lockouts.
- Correlate authentication activity between a domain controller and a Windows client.
- Build a reusable PowerShell Security log reporting script with CSV export.
- Record evidence, limitations, and follow-up recommendations without overstating conclusions.

## Checkpoint 1 — Audit baseline (passed)

On DC01, reviewed `auditpol /get /category:"Account Logon"`, `auditpol /get /category:"Logon/Logoff"`, and `auditpol /get /category:"Account Management"`.

Verified Kerberos Authentication Service, Credential Validation, Logon, and relevant account-management auditing. The Security log was enabled, circular, with a 128 MB maximum size. At baseline it contained 11,791 records.

## Checkpoint 2 — Authentication event review (passed)

Inspected DC01 Event ID **4624**: recent successful events included service logons (type 5) and network logons (type 3) from machine accounts and `192.168.100.20`.

Inspected Event ID **4625** and identified:

| Time (Nov 5, 2026) | Account | Logon type | Source | Status / substatus | Interpretation |
|---|---|---:|---|---|---|
| 18:49:20 (two events) | Not populated | 3 | `192.168.100.20` | `0xC0000133` / `0x0` | Clock-skew-related authentication failure |
| 15:31:50 | `jordan.lee` | 2 | `127.0.0.1` | `0xC000006E` / `0xC0000072` | Disabled account |
| 10:53:28 | `Administrator` | 2 | `127.0.0.1` | `0xC000006D` / `0xC000006A` | Incorrect password |

The user later clarified that they attempted to sign in with disabled `jordan.lee` on WIN11-CLIENT01, then used `taylor.brooks`. That explains the intended lab activity, but it does not independently prove the cause of all DC01 events. The reported `127.0.0.1` source for the 15:31 event is preserved as logged, not silently replaced with the client's IP.

## Checkpoint 2C — Time service investigation (passed)

Client command:

```powershell
w32tm /stripchart /computer:192.168.100.10 /samples:5 /dataonly
w32tm /query /status
```

Five measured offsets were approximately -0.355 to -0.387 milliseconds. WIN11-CLIENT01 reported its time source as `DC01.corp.example.test` (stratum 2); DC01 reported **Local CMOS Clock** (stratum 1). DC01 was verified as the PDC emulator. These results demonstrate synchronization **at the time of testing**, not necessarily at 18:49:20. An appropriate future improvement is to configure an approved external time source for the forest-root PDC emulator.

## Checkpoint 3 — Event correlation (partially completed)

DC01 records around 18:49:20 showed Event ID 4624 type 3 Kerberos network logons for `WIN11-CLIENT01$` and `jordan.lee` from `192.168.100.20`, two Event ID 4625 type 3 failures with `0xC0000133`, and a successful Event ID 4768 TGT request for `WIN11-CLIENT01$`. A query of WIN11-CLIENT01 for Events 4624, 4625, and 4648 in the same window returned no records.

**Limitation:** Matching workstation Security events were not obtained. The successful `jordan.lee` network events are not proof of a successful interactive sign-in, nor proof of compromise. Existing sessions/tickets are possible explanations but were not verified. `jordan.lee` was subsequently **re-enabled intentionally**; `Get-ADUser jordan.lee | Select Name,Enabled` returned `True`. Re-enabling does not resolve historical event interpretation.

## Checkpoint 4A–4D — Monitoring script and validation (passed)

Created `C:\LabScripts\Get-SecurityEvents.ps1` and stored a portfolio copy at [`../scripts/Get-SecurityEvents.ps1`](../scripts/Get-SecurityEvents.ps1). The script accepts a lookback window in hours, reads Event IDs `4624, 4625, 4740, 4768, 4771, 4776`, extracts named XML fields, summarizes counts, displays recent records, and optionally exports CSV.

Run on DC01:

```powershell
& 'C:\LabScripts\Get-SecurityEvents.ps1' -Hours 24
& 'C:\LabScripts\Get-SecurityEvents.ps1' -Hours 24 -ExportPath 'C:\LabScripts\SecurityEvents.csv'
```

**Observed export run:**

| Event ID | Count |
|---|---:|
| 4624 | 2,145 |
| 4768 | 54 |
| 4625 | 4 |
| 4776 | 4 |
| 4740 | 1 |
| 4771 | 1 |
| **Total** | **2,209** |

CSV `SecurityEvents.csv` was verified on DC01 with `Get-Item`; **195,426 bytes**, modified November 5, 2026 at 20:20:35. The exported CSV is a local lab artifact, not included in this package.

Example records: 4624 type 3 for `WIN11-CLIENT01$` from `192.168.100.20`; 4624 type 3 for `jordan.lee` from `192.168.100.20` at 20:16:29, **after** the intentional re-enable.

Focused failure review:

```powershell
Import-Csv 'C:\LabScripts\SecurityEvents.csv' |
    Where-Object { $_.EventID -in @('4625','4740','4771') } |
    Select-Object TimeCreated,EventID,Account,Source,LogonType,Status,SubStatus |
    Format-Table -AutoSize
```

- Event **4771**: `taylor.brooks`, source `::ffff:192.168.100.20`, `Status=0x18` (Kerberos pre-authentication failure).
- Event **4740**: `taylor.brooks`, recorded at 17:01:48, with no `CallerComputerName` XML field.
- Event **4625**: two clock-skew failures; disabled-account and bad-password failures as shown above.

The Event 4740 XML contained `TargetUserName=taylor.brooks`, `TargetDomainName=WIN11-CLIENT01`, `SubjectUserName=DC01$`, and **no** `CallerComputerName`. The script correctly leaves `Source` empty. `TargetDomainName` must not be relabeled as a verified caller computer.

## Validation and limitations

- **Passed:** Security log collection, event grouping, account/source/logon-type/status extraction, CSV creation and file verification.
- **Partially completed:** Cross-machine correlation; matching workstation events were not obtained.
- **Not established:** Historical root cause of clock skew; explanation of earlier successful network logons for disabled `jordan.lee`; definitive caller for the lockout event.
- **Script limitations:** Selected XML fields vary by Event ID; some values legitimately remain empty. The script is a reporting tool, not an alerting system or a forensic attribution engine. It assumes local Security log read access and a valid export directory.

## Recommended follow-up

1. Review approved time-source configuration for the PDC emulator.
2. For future investigations, preserve matching client and DC Security log exports before changing account state.
3. Extend the script with event-specific mappings, filtering, and optional scheduled execution after baseline validation.
4. Keep real account names and lab-only network addresses in public documentation only if acceptable for the portfolio.

## Portfolio artifacts

- [`scripts/Get-SecurityEvents.ps1`](../scripts/Get-SecurityEvents.ps1)
- [`incident-reports/INC-015-security-event-monitoring.md`](../incident-reports/INC-015-security-event-monitoring.md)

**Outcome:** Implemented and tested a reusable Windows Security event reporting workflow, analyzed authentication failures and lockout evidence, and documented uncertainty where the logs did not establish root cause.
