# Lab 11 — Active Directory Group Policy Management

**Project:** Windows Enterprise IT Service Desk Home Lab  
**Domain:** `corp.example.test`  
**Domain controller:** `DC01` (Windows Server 2025)  
**Client:** `WIN11-CLIENT01` (Windows 11 Pro)  
**Status:** Completed — verified November 5, 2026  
**Related ticket:** [INC-011 — Workstation GPO Not Applying](../incident-reports/INC-011-workstation-gpo-not-applying.md)

## Objective

Create, configure, deploy, verify, and troubleshoot a domain Group Policy Object (GPO) that enables the Windows Defender Firewall Domain Profile on a domain-joined workstation.

## Environment and scope

- Active Directory domain: `corp.example.test` (NetBIOS: `CORP`)
- GPO: `GPO-Workstation-Baseline`
- Target OU: `OU=Corp-Workstations,DC=corp,DC=example,DC=test`
- Target computer: `CN=WIN11-CLIENT01,OU=Corp-Workstations,DC=corp,DC=example,DC=test`
- Domain account used for client-side verification: `CORP\alex.morgan`
- Management tools: Group Policy Management Console (GPMC), PowerShell GroupPolicy module, `gpupdate`, `gpresult`, and NetSecurity PowerShell cmdlets

> This is an isolated training lab. The policy change targeted the lab workstation OU. No production systems were involved.

## Checkpoint 1 — Inspect existing GPOs

On DC01:

```powershell
Import-Module GroupPolicy
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime | Format-Table -AutoSize
```

**Verified:** Both `Default Domain Policy` and `Default Domain Controllers Policy` existed with `AllSettingsEnabled`. Their reported creation time was November 2, 2026, 8:09:46 PM. The default GPOs were left unchanged.

## Checkpoint 2 — Create a workstation baseline GPO

On DC01:

```powershell
New-GPO -Name "GPO-Workstation-Baseline" `
  -Comment "Baseline configuration for corporate Windows workstations"

Get-GPO -Name "GPO-Workstation-Baseline" |
  Select-Object DisplayName, GpoStatus, Owner, Description
```

**Verified:** `GPO-Workstation-Baseline` existed, `GpoStatus` was `AllSettingsEnabled`, owner was `CORP\Domain Admins`, and the description was populated.

## Checkpoint 3 — Configure Windows Defender Firewall

On DC01, opened `gpmc.msc`, selected **Group Policy Objects → GPO-Workstation-Baseline → Edit**, then navigated to:

```text
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Windows Defender Firewall with Advanced Security
```

In **Windows Defender Firewall with Advanced Security Properties → Domain Profile**, configured **Firewall state: On (recommended)**. Other firewall settings were left **Not Configured**. This configuration was confirmed in the GPO editor.

## Checkpoint 4 — Link the GPO to the workstation OU

In GPMC, linked the existing GPO to `Corp-Workstations`. Verified on DC01:

```powershell
Get-GPInheritance -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" |
  Select-Object -ExpandProperty GpoLinks |
  Select-Object DisplayName, Enabled, Enforced, Order
```

**Verified result:**

```text
DisplayName              Enabled Enforced Order
-----------              ------- -------- -----
GPO-Workstation-Baseline    True    False     1
```

**Observation:** An Internet Explorer Enhanced Security Configuration warning (`about:security_mmc.exe`) appeared after the GPMC link operation. The PowerShell verification confirmed that the link was created despite the popup. No IE security setting changes were required.

## Checkpoint 5 — Refresh Group Policy on the client

On WIN11-CLIENT01:

```powershell
gpupdate /force
whoami
```

**Verified:** Both computer and user policy updates completed successfully. `whoami` returned `corp\alex.morgan`.

## Checkpoint 6 — Verify GPO application and firewall configuration

### Applied policies

```powershell
gpresult /r /scope computer
```

**Verified:**

```text
COMPUTER SETTINGS
CN=WIN11-CLIENT01,OU=Corp-Workstations,DC=corp,DC=example,DC=test
Last time Group Policy was applied: 11/5/2026 at 6:16:29 PM
Group Policy was applied from: DC01.corp.example.test

Applied Group Policy Objects
-----------------------------
    GPO-Workstation-Baseline
    Default Domain Policy
```

`Local Group Policy` was listed as `Not Applied (Empty)`, which was not a failure.

### Effective firewall state

```powershell
Get-NetFirewallProfile -PolicyStore ActiveStore -Name Domain |
  Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
```

**Verified result:**

```text
Name   Enabled DefaultInboundAction DefaultOutboundAction
----   ------- -------------------- ---------------------
Domain    True                Block                 Allow
```

### Resultant Set of Policy (RSOP)

```powershell
Get-NetFirewallProfile -PolicyStore RSOP -Name Domain |
  Select-Object Name, Enabled
```

**Verified:** `Domain` / `True`. Together with `gpresult`, this confirmed the expected domain firewall policy was in effect.

### HTML evidence report

```powershell
New-Item -Path "C:\LabReports" -ItemType Directory -Force
gpresult /h "C:\LabReports\Lab11-GPO-Results.html" /scope computer /f
Get-Item "C:\LabReports\Lab11-GPO-Results.html" |
  Select-Object Name, Length, LastWriteTime
```

**Verified:**

| File | Size | LastWriteTime |
|---|---:|---|
| `Lab11-GPO-Results.html` | 291,582 bytes | 11/5/2026 6:28:41 PM |

The report was opened and `GPO-Workstation-Baseline` was confirmed present. The HTML report remains a local evidence artifact; review it for environment and account information before any public upload.

## Checkpoint 7 — Troubleshoot a missing workstation GPO (INC-011)

### Simulated fault

On DC01, intentionally disabled the link without deleting the GPO or changing its firewall settings:

```powershell
Set-GPLink -Name "GPO-Workstation-Baseline" `
  -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" `
  -LinkEnabled No
```

**Verified:** Link `Enabled=False`, `Enforced=False`, `Order=1`.

### Diagnose on WIN11-CLIENT01

After a policy refresh, ran:

```powershell
gpupdate /force
gpresult /r /scope computer
```

**Verified diagnostic evidence:**

```text
Applied Group Policy Objects
-----------------------------
    Default Domain Policy

The following GPOs were not applied because they were filtered out
-------------------------------------------------------------------
    GPO-Workstation-Baseline
        Filtering: Disabled (Link)
```

**Root cause:** The custom GPO link on `Corp-Workstations` was disabled. A successful general Group Policy update alone would not have proved the specific GPO applied.

### Restore the link

On DC01:

```powershell
Set-GPLink -Name "GPO-Workstation-Baseline" `
  -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" `
  -LinkEnabled Yes
```

**Verified:** Link returned to `Enabled=True`, `Enforced=False`, `Order=1`.

### Validate recovery

On WIN11-CLIENT01, refreshed policy and checked:

```powershell
gpupdate /force
gpresult /r /scope computer
Get-NetFirewallProfile -PolicyStore RSOP -Name Domain |
  Select-Object Name, Enabled
```

**Verified:** `GPO-Workstation-Baseline` and `Default Domain Policy` were again listed under applied GPOs; the custom GPO no longer appeared as filtered; Domain RSOP returned `Enabled=True`. The final pasted verification did not separately include the `gpupdate` success text, so the resolution is supported by the applied-policy and RSOP results.

**Incident outcome:** [INC-011](../incident-reports/INC-011-workstation-gpo-not-applying.md) resolved.

## Final verification checklist

- [x] Default domain GPOs inspected and preserved
- [x] Custom workstation baseline GPO created
- [x] Domain firewall state configured to On
- [x] GPO linked to `Corp-Workstations`
- [x] Client computer policy refreshed
- [x] Custom GPO appeared in applied-policy results
- [x] Active firewall: Domain enabled, inbound Block, outbound Allow
- [x] RSOP Domain firewall enabled
- [x] HTML policy results report generated and reviewed
- [x] Disabled-link issue reproduced and diagnosed
- [x] Link restored and GPO application verified

## Key takeaways

1. **Scope matters:** A GPO must be linked to the appropriate site, domain, or OU to apply to intended targets.
2. **Processing is not proof of application:** `gpupdate` can succeed while a specific GPO is excluded.
3. **Use `gpresult` for root-cause analysis:** `Filtering: Disabled (Link)` identified why the baseline GPO was missing.
4. **Verify effective settings:** ActiveStore and RSOP queries provide complementary evidence of firewall configuration.
5. **Preserve default policies:** Use dedicated, narrowly scoped GPOs for lab or organizational baselines.

## Portfolio skills demonstrated

Active Directory Group Policy administration; Windows Server management; workstation security baselines; PowerShell; policy deployment and validation; Windows Defender Firewall; incident diagnosis and resolution; technical documentation.
