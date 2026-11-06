# INC-018 — Workstation Group Policy Not Applying

**Incident type:** Controlled service desk lab simulation  
**Status:** Resolved / Closed  
**Date:** November 6, 2026  
**Affected asset:** `WIN11-CLIENT01`  
**Domain:** `corp.example.test`  
**Domain controller:** `DC01`  
**Related lab:** [Lab 18 — Group Policy Troubleshooting](18-lab18-group-policy-troubleshooting.md)

## Reported issue

A required computer-side policy setting was not appearing on a domain-joined Windows 11 workstation, despite successful Group Policy refreshes.

**Expected:** `HKLM\SOFTWARE\Policies\Lab18\TroubleshootingEnabled` should be a DWORD set to `1` after the test GPO is correctly scoped and applied.

**Observed before remediation:** The registry value was absent, and `GPO-Lab18-Troubleshooting` did not appear in `gpresult /scope computer /r`.

## Scope and impact

One lab workstation, `WIN11-CLIENT01`, was used to reproduce the issue. The existing `GPO-Workstation-Baseline` and `Default Domain Policy` continued to apply. No production users or systems were involved.

## Troubleshooting timeline

| Phase | Investigation / action | Evidence |
| --- | --- | --- |
| Baseline | Verified domain connectivity and existing computer policies | Secure channel `True`; existing GPOs applied |
| Reproduction | Created test GPO and registry policy without linking it | GPO configuration present on DC01 |
| Symptom confirmation | Ran `gpupdate /target:computer /force` | Refresh succeeded; test value absent |
| Scope investigation | Inspected `Corp-Workstations` GPO links | Only `GPO-Workstation-Baseline` linked |
| Remediation | Linked test GPO to `Corp-Workstations` | Test link enabled at order `2` |
| Validation | Refreshed workstation policies | Test GPO applied; DWORD value `1` |
| Cleanup | Removed link and deleted temporary GPO | Three original domain GPOs remained |
| Closure | Refreshed policies and checked registry, RSoP, secure channel, and logs | Original applied GPOs restored; secure channel `True`; no matching recent warning/error events |

## Root cause

The configured `GPO-Lab18-Troubleshooting` was not linked to `OU=Corp-Workstations,DC=corp,DC=example,DC=test`. Because the workstation's computer account resided in that OU, the test GPO was not in its applicable policy scope. The successful `gpupdate` command did not imply that the unlinked GPO had been applied.

## Resolution

On `DC01`:

```powershell
New-GPLink `
    -Name 'GPO-Lab18-Troubleshooting' `
    -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test' `
    -LinkEnabled Yes
```

On `WIN11-CLIENT01`:

```powershell
gpupdate /target:computer /force
gpresult /scope computer /r
Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Policies\Lab18' `
    -Name 'TroubleshootingEnabled'
```

**Validation:** `gpresult` listed `GPO-Lab18-Troubleshooting`, and the registry returned `TroubleshootingEnabled : 1`.

## Rollback and final checks

The temporary GPO link was removed and the GPO deleted on `DC01`. After another workstation policy refresh, the temporary registry value was absent without manual deletion.

Final `gpresult` showed only `GPO-Workstation-Baseline` and `Default Domain Policy` applied. `Test-ComputerSecureChannel` returned `True`. A Group Policy Operational log query for warning and error events over the preceding 30 minutes returned no matches. Final policy application time: **November 6, 2026, 3:13:33 PM**.

## Closure notes

**Resolution confirmed.** The issue was reproduced and resolved through proper GPO linking, then the lab environment was restored. Future troubleshooting should check OU placement, link scope, security/WMI filtering, and RSoP before assuming a successful `gpupdate` proves a specific GPO was applied.

> **Classification:** Simulated incident for portfolio documentation; no production outage or actual SLA measurements.
