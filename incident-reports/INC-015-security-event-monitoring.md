# INC-015 — Security Event Monitoring and Authentication Investigation

| Field | Value |
|---|---|
| Incident ID | INC-015 |
| Date | November 5, 2026 |
| Environment | Windows Enterprise IT Service Desk Home Lab |
| Systems | DC01 (`corp.example.test`), WIN11-CLIENT01 |
| Category | Authentication / Windows Security Event Review |
| Severity | Low — controlled lab; no compromise established |
| Status | Monitoring and evidence review complete; historical causes partly unresolved |
| Evidence source | DC01 Windows Security log, PowerShell output, CSV export |

## Summary

During a lab exercise to monitor and investigate Windows Security events, DC01 recorded successful network logons, failed logons, a Kerberos pre-authentication failure, and an account lockout. The user reported an attempted sign-in with previously disabled `jordan.lee`, followed by use of `taylor.brooks`. The investigation produced a reusable PowerShell event-reporting script and a verified CSV export.

This report covers several observed events; they are **not** assumed to be one attack or one causal chain.

## Evidence and timeline (Nov 5, 2026; local log time)

| Time | Event | Evidence | Assessment |
|---|---|---|---|
| 10:53:28 | 4625 | `Administrator`, type 2, `127.0.0.1`, `0xC000006D / 0xC000006A` | Bad-password logon failure |
| 15:31:50 | 4625 | `jordan.lee`, type 2, `127.0.0.1`, `0xC000006E / 0xC0000072` | Disabled-account logon failure |
| 17:01:48 | 4740 | `taylor.brooks` lockout | Consistent with Lab 14 account-lockout test; caller field absent |
| 17:18:10 | 4771 | `taylor.brooks`, `::ffff:192.168.100.20`, status `0x18` | Kerberos pre-authentication failure; not proven to have caused the earlier lockout |
| 18:49:20 | 4625 (twice) | Type 3, `192.168.100.20`, `0xC0000133` | Clock-skew-related authentication failures |
| 18:49:20 | 4624 / 4768 | Network logons from client; successful machine-account TGT request | Concurrent authentication activity, not necessarily the same logon transaction |
| 20:16:29 | 4624 | `jordan.lee`, type 3, `192.168.100.20` | Occurred after account was intentionally re-enabled |
| 20:20:35 | CSV export | `SecurityEvents.csv`, 195,426 bytes | Monitoring export verified |

The exact time of `jordan.lee` re-enablement was not recorded here; the user verified `Enabled=True` before the 20:16:29 event appeared in the subsequent report.

## Investigation actions

1. Verified DC01 Security auditing and log retention settings.
2. Reviewed Event IDs 4624, 4625, 4740, 4768, 4771, and 4776.
3. Compared DC01 authentication records with a client query; the client query returned no matching records in the selected interval.
4. Checked client-to-DC time offset: five samples within approximately 0.4 milliseconds at test time.
5. Verified DC01 uses Local CMOS Clock and WIN11-CLIENT01 synchronizes from DC01.
6. Created and ran `Get-SecurityEvents.ps1`; verified event counts and CSV export.
7. Inspected Event 4740 XML to determine whether a caller computer was recorded.

## Account lockout evidence

The 4740 event contained:

```text
TargetUserName    taylor.brooks
TargetDomainName  WIN11-CLIENT01
SubjectUserName   DC01$
SubjectDomainName CORP
```

No `CallerComputerName` field was present. `TargetDomainName` is retained as logged and is **not** used as a substitute for a confirmed caller computer. The CSV `Source` value is appropriately blank.

## Findings and conclusions

- **Confirmed:** Authentication failures, a lockout, and Kerberos pre-authentication failure were recorded. The reporting script successfully collected and exported these records.
- **Consistent with controlled testing:** Disabled-account attempt and Lab 14 lockout exercise. `jordan.lee` was subsequently re-enabled as an intentional lab change.
- **Not conclusively determined:** Why historical successful type 3 network logons were recorded for `jordan.lee` while the account had previously been disabled. Cached tickets/sessions are hypotheses, not verified findings.
- **Not conclusively determined:** Why two `0xC0000133` events occurred. Later time-offset checks do not reconstruct the earlier state.
- **No evidence presented of compromise:** This is not proof that compromise was impossible.

## Resolution and follow-up

**Completed:** Implemented repeatable log monitoring and CSV reporting; documented findings and data limitations. No remediation of the historical clock-skew cause or network-logon ambiguity was verified.

**Recommended:** Review the PDC emulator's authoritative time source, retain both client and DC event evidence during future tests, and consider event-specific extraction enhancements and automated alerting.

## References

- [Lab 15 documentation](../docs/20-lab15-windows-event-log-monitoring.md)
- [PowerShell monitoring script](../scripts/Get-SecurityEvents.ps1)
