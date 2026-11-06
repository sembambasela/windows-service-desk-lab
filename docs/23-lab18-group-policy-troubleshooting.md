# Lab 18 — Group Policy Troubleshooting

**Status:** Complete  
**Date:** November 6, 2026  
**Environment:** VirtualBox Windows enterprise service desk lab  
**Related incident:** [INC-018 — Workstation Group Policy Not Applying](INC-018-group-policy-not-applying.md)

## Objective

Troubleshoot a controlled Group Policy application issue by validating Active Directory and workstation health, examining Group Policy scope and processing, identifying a missing GPO link, restoring policy application, and safely removing the temporary test configuration.

## Lab environment

| Component | Configuration |
| --- | --- |
| Domain | `corp.example.test` (`CORP`) |
| Domain controller | `DC01` — Windows Server 2025 |
| Workstation | `WIN11-CLIENT01` — Windows 11 Pro |
| Workstation OU | `OU=Corp-Workstations,DC=corp,DC=example,DC=test` |
| Existing workstation GPO | `GPO-Workstation-Baseline` |
| Test GPO | `GPO-Lab18-Troubleshooting` (temporary) |
| Test policy | `HKLM\SOFTWARE\Policies\Lab18\TroubleshootingEnabled` = DWORD `1` |

## Checkpoint 1 — Confirm environment health

On `DC01`, verified the host and domain administrator context. `DNS`, `KDC`, `Netlogon`, and `NTDS` were running with automatic startup.

On `WIN11-CLIENT01`, confirmed:

```powershell
hostname
whoami
Test-ComputerSecureChannel
Test-NetConnection 192.168.100.10 -Port 389
nltest /dsgetdc:corp.example.test
```

**Observed:** Domain secure channel `True`; TCP port 389 reachable; domain controller discovery succeeded.

## Checkpoint 2 — Review GPOs, OUs, and links

On `DC01`:

```powershell
Get-GPO -All | Select-Object DisplayName, GpoStatus
Get-ADComputer -Identity 'WIN11-CLIENT01' | Select-Object Name, DistinguishedName
Get-GPInheritance -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test'
```

**Observed:** `GPO-Workstation-Baseline` linked to `Corp-Workstations`; `Default Domain Policy` inherited. `WIN11-CLIENT01` resided in the correct OU. Group Policy Management was installed.

## Checkpoint 3 — Establish a healthy processing baseline

On `WIN11-CLIENT01`:

```powershell
gpresult /scope computer /r
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-GroupPolicy/Operational'
    StartTime = (Get-Date).AddDays(-1)
} -MaxEvents 10 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-List
```

**Observed:** `GPO-Workstation-Baseline` and `Default Domain Policy` applied. Group Policy Operational Event ID `5117` reported successful session completion. Other sampled events were informational.

## Checkpoint 4 — Reproduce a missing-policy issue

On `DC01`, created an isolated GPO and configured a computer-side registry policy:

```powershell
New-GPO -Name 'GPO-Lab18-Troubleshooting' `
    -Comment 'Lab 18 isolated Group Policy troubleshooting exercise'

Set-GPRegistryValue `
    -Name 'GPO-Lab18-Troubleshooting' `
    -Key 'HKLM\SOFTWARE\Policies\Lab18' `
    -ValueName 'TroubleshootingEnabled' `
    -Type DWord `
    -Value 1

Get-GPRegistryValue `
    -Name 'GPO-Lab18-Troubleshooting' `
    -Key 'HKLM\SOFTWARE\Policies\Lab18' `
    -ValueName 'TroubleshootingEnabled'
```

**Observed:** `PolicyState: Set`, `Type: DWord`, `Value: 1`. The GPO was intentionally **not linked** to the workstation OU.

On `WIN11-CLIENT01`:

```powershell
gpupdate /target:computer /force
Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Policies\Lab18' `
    -Name 'TroubleshootingEnabled' `
    -ErrorAction SilentlyContinue
gpresult /scope computer /r
```

**Observed:** `gpupdate` completed successfully, but the registry check returned no value and `GPO-Lab18-Troubleshooting` was absent from the applied GPO list. Existing baseline policies continued to apply.

## Checkpoint 5 — Diagnose and repair the missing link

On `DC01`, inspected direct OU links and confirmed the test GPO existed but was not linked:

```powershell
Get-GPInheritance `
    -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test' |
    Select-Object -ExpandProperty GpoLinks |
    Format-Table DisplayName, Enabled, Enforced, Order -AutoSize

Get-GPO -Name 'GPO-Lab18-Troubleshooting' |
    Select-Object DisplayName, GpoStatus
```

**Root cause:** The configured GPO had no link to the workstation OU, so it was outside the workstation's applicable GPO scope.

Repaired the link:

```powershell
New-GPLink `
    -Name 'GPO-Lab18-Troubleshooting' `
    -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test' `
    -LinkEnabled Yes
```

**Observed:** The existing baseline link remained enabled at order `1`; the troubleshooting GPO appeared enabled at order `2`.

On `WIN11-CLIENT01`, reran `gpupdate /target:computer /force`, `Get-ItemProperty`, and `gpresult /scope computer /r`.

**Observed:** `TroubleshootingEnabled : 1`, and `GPO-Lab18-Troubleshooting` appeared in the applied GPO list alongside the two original policies. The last application at this stage was November 6, 2026 at **3:10:49 PM**, from `DC01.corp.example.test`.

## Checkpoint 6 — Clean up the temporary configuration

On `DC01`:

```powershell
Remove-GPLink `
    -Name 'GPO-Lab18-Troubleshooting' `
    -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test'

Get-GPInheritance `
    -Target 'OU=Corp-Workstations,DC=corp,DC=example,DC=test' |
    Select-Object -ExpandProperty GpoLinks

Remove-GPO -Name 'GPO-Lab18-Troubleshooting'
Get-GPO -All | Select-Object DisplayName, GpoStatus
```

**Observed:** Only `GPO-Workstation-Baseline` remained directly linked to the workstation OU. The temporary GPO was deleted, leaving `Default Domain Policy`, `Default Domain Controllers Policy`, and `GPO-Workstation-Baseline`.

On `WIN11-CLIENT01`, refreshed computer policy and checked the test registry value again. The query returned no output, indicating the test value was absent; no manual registry deletion was needed.

## Checkpoint 7 — Final validation

On `WIN11-CLIENT01`:

```powershell
gpresult /scope computer /r
Test-ComputerSecureChannel
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-GroupPolicy/Operational'
    Level = 2,3
    StartTime = (Get-Date).AddMinutes(-30)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Format-List
```

**Observed:**

- Applied GPOs: `GPO-Workstation-Baseline`, `Default Domain Policy`.
- Temporary troubleshooting GPO absent.
- Domain secure channel: `True`.
- No matching Group Policy warning or error events returned for the 30-minute query window.
- Last Group Policy application: **November 6, 2026, 3:13:33 PM**, from `DC01.corp.example.test`.

## Outcome

**PASS — Lab complete.** Reproduced a policy scope issue, diagnosed the missing GPO link, corrected it, demonstrated policy application using `gpresult` and the registry, and restored the original configuration.

## Skills demonstrated

Active Directory OU and GPO link management; PowerShell GroupPolicy cmdlets; Group Policy scope troubleshooting; RSoP analysis; Windows registry verification; Operational event log review; controlled change and rollback; service desk incident documentation.

## Evidence checklist

The PowerShell outputs were verified during the lab. Add screenshots to the repository if retained:

- [ ] Existing workstation GPO link and applied GPO baseline
- [ ] Test GPO registry configuration
- [ ] Missing registry value and absent test GPO before repair
- [ ] Restored GPO link
- [ ] Applied test GPO and registry DWORD `1` after repair
- [ ] Removed test GPO and final clean `gpresult`

> **Note:** This was an intentionally created lab scenario, not a production incident. No screenshot files are included in this documentation package.
