# INC-011 — Workstation Group Policy Not Applying

**Ticket type:** Incident (simulated)  
**Status:** Resolved  
**Related lab:** [Lab 11 — Active Directory Group Policy Management](../docs/16-lab11-group-policy-management.md)  
**Affected device:** `WIN11-CLIENT01`  
**Domain:** `corp.example.test`  
**Domain controller:** `DC01`  
**Affected GPO:** `GPO-Workstation-Baseline`  
**Target OU:** `OU=Corp-Workstations,DC=corp,DC=example,DC=test`  
**Exercise date:** November 5, 2026

## Incident summary

In a controlled Service Desk troubleshooting exercise, a Windows 11 domain workstation stopped receiving its custom workstation security baseline GPO after the GPO's OU link was intentionally disabled. The objective was to identify the reason for non-application, restore the link, and verify policy application on the client.

## Reported symptoms

- The custom `GPO-Workstation-Baseline` did not appear in the client's applied GPO list.
- `Default Domain Policy` continued to apply.
- `gpresult` identified the custom GPO as filtered because its link was disabled.

> This incident was deliberately simulated in a lab; no real employee reported an outage. The firewall was not deliberately disabled during troubleshooting.

## Initial working configuration

Before the simulation:

- `GPO-Workstation-Baseline` existed and had `AllSettingsEnabled`.
- The GPO configured the Domain Profile firewall state to **On**.
- The link to `Corp-Workstations` was enabled.
- `gpresult /r /scope computer` listed the baseline GPO as applied.
- Domain firewall ActiveStore and RSOP reported `Enabled=True`.

## Reproduction and diagnostic steps

### 1. Disable the OU link (DC01)

```powershell
Set-GPLink -Name "GPO-Workstation-Baseline" `
  -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" `
  -LinkEnabled No
```

Verified with:

```powershell
Get-GPInheritance -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" |
  Select-Object -ExpandProperty GpoLinks |
  Select-Object DisplayName, Enabled, Enforced, Order
```

**Observed:** `GPO-Workstation-Baseline` / `Enabled=False` / `Enforced=False` / `Order=1`.

### 2. Refresh and inspect applied policy (WIN11-CLIENT01)

```powershell
gpupdate /force
gpresult /r /scope computer
```

**Observed:**

```text
Applied Group Policy Objects
-----------------------------
    Default Domain Policy

The following GPOs were not applied because they were filtered out
-------------------------------------------------------------------
    GPO-Workstation-Baseline
        Filtering: Disabled (Link)
```

## Root cause

**Disabled Group Policy link:** `GPO-Workstation-Baseline` was linked to the correct OU, but the link was disabled. This excluded the GPO from the workstation's applied policy set after policy processing.

The issue was not caused by deleting the GPO, changing its firewall configuration, or moving the computer out of the target OU.

## Resolution

On DC01, restored the existing link:

```powershell
Set-GPLink -Name "GPO-Workstation-Baseline" `
  -Target "OU=Corp-Workstations,DC=corp,DC=example,DC=test" `
  -LinkEnabled Yes
```

Verified link status returned to `Enabled=True`, `Enforced=False`, `Order=1`.

## Post-resolution verification

On WIN11-CLIENT01:

```powershell
gpupdate /force
gpresult /r /scope computer
Get-NetFirewallProfile -PolicyStore RSOP -Name Domain |
  Select-Object Name, Enabled
```

**Verified results:**

| Check | Result |
|---|---|
| OU GPO link | Enabled |
| `GPO-Workstation-Baseline` | Listed under Applied Group Policy Objects |
| `Default Domain Policy` | Listed under Applied Group Policy Objects |
| Custom GPO filtered by disabled link | No longer listed as filtered |
| Domain firewall RSOP | `Enabled=True` |

The final user-provided evidence included the applied GPO list and RSOP output, but not a separate `gpupdate` completion message. These results are sufficient to establish that the expected policy was again in effect.

## Resolution summary

Re-enabled the disabled OU link and verified that the workstation again received the intended GPO. **Incident status: Resolved.**

## Prevention and operational lessons

- Verify GPO link state and target OU before modifying policy settings.
- Use `gpresult /r /scope computer` to distinguish successful policy processing from successful application of a specific GPO.
- Review the filtered-out GPO section for explicit reasons such as `Disabled (Link)`.
- Confirm effective security settings with RSOP after remediation.
- Avoid unnecessary changes to default domain policies or firewall rules during diagnosis.

## Evidence and privacy

Supporting lab evidence includes the command outputs recorded above and the locally generated `C:\LabReports\Lab11-GPO-Results.html` (291,582 bytes, November 5, 2026, 6:28:41 PM). The HTML report was generated before the simulated incident; it documents the working baseline, not the disabled-link state. Review it for account, SID, and environment details before publishing.
