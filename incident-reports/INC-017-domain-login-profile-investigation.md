# INC-017 — Domain Sign-in Restriction and User Profile Investigation

**Date:** 2026-11-06  
**Environment:** `corp.example.test` / DC01 / WIN11-CLIENT01  
**Category:** Identity and Access Management / Windows Authentication  
**Status:** Resolved (controlled lab incident)

## Summary
A test domain account (`CORP\taylor.brooks`) was intentionally disabled to simulate an account-related sign-in incident. Two `runas` attempts on WIN11-CLIENT01 failed with Windows error **1327** (account restriction). The account was re-enabled and verified healthy. Related workstation profile and domain connectivity checks found no active issue.

## Impact
Test account could not start the requested process using its credentials during the controlled simulation. No production users or systems were involved.

## Timeline and evidence
1. **Preparation (DC01):** `Disable-ADAccount -Identity 'taylor.brooks'`; AD confirmed `Enabled=False`, `LockedOut=False`.
2. **Reproduction (WIN11-CLIENT01):** `runas /user:CORP\taylor.brooks "cmd.exe"` failed twice with **1327**.
3. **Log review:** Security event searches on DC01 and WIN11-CLIENT01 for relevant IDs yielded no account-specific matches in the queried windows. WIN11-CLIENT01 Logon auditing was set to Success and Failure; Security log was enabled.
4. **Profile investigation:** Registered user profile paths existed, no `.bak` ProfileList keys were found, `ProfSvc` was Running/Automatic, and no Warning/Error/Critical User Profile Service Operational events matched the seven-day query.
5. **Remediation (DC01):** `Enable-ADAccount`; verified `Enabled=True`, `LockedOut=False`, `PasswordExpired=False`.
6. **Validation (WIN11-CLIENT01):** `Test-ComputerSecureChannel` returned `True`; `nltest /dsgetdc:corp.example.test` successfully located DC01 at `192.168.100.10`.

## Cause assessment
The deliberately disabled account was the intended simulated restriction and is consistent with the error. However, error 1327 is generic and no matching Security event was recovered to prove the precise restriction. **Root-cause attribution is therefore qualified, not definitive.**

## Resolution
The account was restored to enabled status; no further sign-in failures were attempted. Domain trust and DC discovery checks passed. No profile changes were required.

## Follow-up / lessons learned
- Confirm the hostname before examining local event logs.
- Record both negative and positive findings; absence of a matching event is not proof an attempt never occurred.
- Avoid changing profile registry values or removing profile directories without a verified fault and recovery plan.
- For future exercises, capture exact attempt timestamps and examine relevant authentication auditing at the point of failure.
