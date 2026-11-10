# INC-021 — Windows Update Pending Restart

**Incident type:** Service desk lab — observed Windows Update servicing issue  
**Status:** Resolved / Closed  
**Date:** November 9–10, 2026  
**Affected asset:** `WIN11-CLIENT01`  
**Domain:** `corp.example.test`  
**Related lab:** [Lab 21 — Windows Update and Patch Management](../docs/21-lab21-windows-update-patch-management.md)

## Incident summary

A .NET Framework security update, **KB5127694**, remained in an in-progress / pending-installation state. Windows servicing indicated a restart was required. An initial controlled restart did not clear the pending state.

## User and service impact

Patch completion could not be confirmed while the update remained pending. No broader user outage or business impact was established in this isolated lab.

## Initial findings

| Check | Finding |
| --- | --- |
| Windows Update history | KB5127694 shown as In Progress; HResult `0x80242014` |
| CBS package state | `Package_for_DotNetRollup_481` version `10.0.10008.1` — `InstallPending` |
| CBS reboot pending | `True` |
| Windows Update reboot required | `True` |
| Pending file rename operations | `True` |
| DISM component store scan | No component store corruption detected |
| Windows Update UI | Restart required |

CBS servicing records included a delayed execution / restart-required status `0x80070bc2`. This supported the reboot requirement; it did not establish a corrupt component store.

## Troubleshooting and actions taken

1. Confirmed workstation connectivity, domain trust, and Windows Update service health.
2. Reviewed Windows Update COM history, applicable updates, CBS package states, and pending-restart indicators.
3. Ran `DISM /Online /Cleanup-Image /ScanHealth`; no component store corruption was detected.
4. Performed an initial controlled restart; the pending condition remained.
5. Confirmed Windows Update Settings explicitly showed **Restart required**.
6. Selected **Restart now** from Windows Update Settings and allowed servicing to complete.
7. Rechecked Windows package state, pending-restart indicators, update applicability, and hotfix inventory.

## Resolution and verification

- KB5127694 was no longer returned among applicable uninstalled software updates.
- `Package_for_DotNetRollup_481` version `10.0.10008.1` changed to **Installed**; prior version `10.0.9347.1` was **Superseded**.
- CBS reboot pending, Windows Update reboot required, and pending file rename operations all returned `False`.
- `Get-HotFix` listed `KB5127694` as installed, with an installation date displayed as November 10, 2026.
- As part of the broader Lab 21, KB890830 was installed successfully (`ResultCode 2`, `HResult 0x00000000`, no reboot required).
- The final Windows Update software scan returned **0** applicable uninstalled updates.

## Root cause assessment

**Confirmed:** The .NET update was awaiting completion of Windows servicing during a restart, and the Windows Update Settings restart action resolved the pending condition.

**Not established:** Why the first controlled restart did not complete servicing. The evidence does not justify attributing the issue to component store corruption or another specific underlying defect.

## Closure

**Resolved.** KB5127694 installation verified, pending-restart state cleared, and the workstation passed the final applicable-software-update scan.

## Preventive / service desk notes

For similar cases, check Windows Update Settings, CBS package state, reboot indicators, and update history before attempting disruptive repairs. Verify installation after the restart rather than relying solely on a changed UI banner. Avoid applying optional preview updates without a defined reason or approval.

## Evidence

Relevant screenshots, if retained, should be placed directly in `screenshots/` with `lab21-` filenames. The command outputs and results above were verified during the lab; screenshots are not claimed as attached to this report.
