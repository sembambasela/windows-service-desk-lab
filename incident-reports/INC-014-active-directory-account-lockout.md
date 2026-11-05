# INC-014 — Active Directory Account Lockout

**Type:** Simulated service desk security incident  
**Date:** November 5, 2026  
**Environment:** `corp.example.test`  
**Affected user:** Taylor Brooks (`CORP\taylor.brooks`)  
**Domain controller:** DC01  
**Originating workstation:** WIN11-CLIENT01  
**Status:** Resolved — lab test completed

## Summary
A dedicated Active Directory test account was locked after repeated incorrect password submissions from WIN11-CLIENT01. The lockout was confirmed by AD account properties and Security Event 4740. Investigation revealed that failure auditing for Kerberos Authentication Service and Credential Validation was not enabled. Both audit categories were updated, and a subsequent controlled failed sign-in generated Kerberos Event 4771.

## Symptoms and impact
- Test account `taylor.brooks` became locked.
- `LockedOut=True`; `BadPwdCount=3`.
- No production or other lab-user accounts were involved in the simulation.

## Timeline (DC01 local time)
| Time | Evidence / action |
|---|---|
| 4:44:12 PM | Test account password set |
| 5:01:48 PM | Account lockout; Security Event 4740; caller `WIN11-CLIENT01` |
| After lockout | Initial 4771 query returned no matching records; Kerberos failure auditing found disabled |
| Investigation | Enabled Success and Failure for Kerberos Authentication Service and Credential Validation |
| Recovery | Account observed automatically unlocked after lockout period; manual `Unlock-ADAccount` cleared failed-password count |
| 5:18:10 PM | Controlled incorrect password attempt generated Event 4771, failure code `0x18`, client `192.168.100.20` |
| Final cleanup | Cleared bad-password count, removed temporary FGPP, verified default threshold 0; retained enhanced auditing |

## Investigation
**Event 4740:** Locked account `taylor.brooks`, caller computer `WIN11-CLIENT01`, timestamp November 5, 2026 5:01:48 PM.

**Event 4771:** Kerberos pre-authentication failure for `taylor.brooks`, client `::ffff:192.168.100.20`, service `krbtgt/CORP`, failure code `0x18`, pre-authentication type 2, timestamp November 5, 2026 5:18:10 PM.

The later Event 4771 was generated **after** enabling failure auditing and does not retroactively document the original failed attempts.

## Root cause
**Simulated incident:** Repeated incorrect password submissions reached the test FGPP threshold of three attempts.

**Audit finding:** Kerberos Authentication Service and Credential Validation had Success-only auditing, reducing visibility into authentication failures.

## Resolution
1. Verified lockout and originating workstation through AD and Event 4740.
2. Enabled failure auditing for Kerberos Authentication Service and Credential Validation.
3. Recovered the test account and cleared the bad-password count with `Unlock-ADAccount`.
4. Confirmed new Kerberos failure events could be recorded through Event 4771.
5. Removed test-specific FGPP and verified original domain lockout threshold (`0`).
6. Retained enhanced auditing by explicit lab decision.

## Final validation
- `taylor.brooks`: enabled `True`, locked `False`, bad-password count `0`.
- No FGPPs configured; Taylor has no resultant FGPP.
- Domain lockout threshold `0` (unchanged).
- Kerberos Authentication Service: Success and Failure.
- Credential Validation: Success and Failure.

## Preventive recommendations
- Manage persistent domain controller auditing through Group Policy and monitor Security log retention.
- Review failed-authentication events and correlate account, time, and source device before remediation.
- Avoid account lockout testing against real users; use a dedicated account and isolated policy.

## Related lab
`docs/19-lab14-account-lockout-security-auditing.md`
