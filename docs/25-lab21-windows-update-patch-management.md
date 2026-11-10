# Lab 21 — Windows Update and Patch Management

**Status:** Complete  
**Date:** November 9–10, 2026  
**Environment:** VirtualBox Windows enterprise service desk lab  
**Related incident:** [INC-021 — Windows Update Pending Restart](../incident-reports/INC-021-windows-update-pending-restart.md)

## Objective

Assess Windows Update health on a domain-joined Windows 11 workstation; investigate a .NET security update stuck in a pending installation/restart state; complete required servicing safely; install a remaining applicable update without selecting optional preview updates; and verify the final patch state.

## Lab environment

| Component | Configuration |
| --- | --- |
| Domain | `corp.example.test` (`CORP`) |
| Domain controller | `DC01` — Windows Server 2025, internal IP `192.168.100.10` |
| Workstation | `WIN11-CLIENT01` — Windows 11 Pro |
| OS version / build | `10.0.26300` / `26300` |
| Workstation internal IP | `192.168.100.20` |
| Workstation NAT IP | `10.0.2.15` |

## Checkpoint 1 — Confirm workstation and connectivity

Restarted the workstation and verified the domain secure channel, connectivity to the domain controller on TCP port 389, and external HTTPS connectivity on port 443.

**Observed:** Domain trust and network connectivity checks succeeded.

## Checkpoint 2 — Establish update baseline and diagnose pending restart

Collected operating system and hotfix information, reviewed Windows Update services, queried Windows Update COM history, checked pending-restart registry indicators, and inspected component servicing state.

The Windows Update history included **2026-10 .NET Framework Security Update (KB5127694)** in an **In Progress** state with HResult `0x80242014`. The servicing package `Package_for_DotNetRollup_481~31bf3856ad364e35~amd64~~10.0.10008.1` was reported as **InstallPending**.

Initial reboot indicators:

- CBS reboot pending: `True`
- Windows Update reboot required: `True`
- Pending file rename operations: `True`

Ran:

```powershell
DISM /Online /Cleanup-Image /ScanHealth
Get-WindowsPackage -Online
```

**Observed:** DISM reported no component store corruption. Windows Update and CBS servicing evidence indicated that a restart was required to complete the .NET update. An earlier controlled restart did not clear the pending state.

Windows Update Settings subsequently displayed **Restart required**. Used the **Restart now** action from Windows Update Settings rather than initiating another generic restart.

**After restart:** The update was no longer offered as uninstalled. The .NET servicing package version `10.0.10008.1` showed **Installed** and the older version `10.0.9347.1` showed **Superseded**. All three pending-restart indicators returned `False`.

## Checkpoint 3 — Identify and install remaining updates

Queried applicable uninstalled software updates using the Windows Update API:

```powershell
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
$SearchResult = $UpdateSearcher.Search('IsInstalled=0 and Type=\'Software\'')
$SearchResult.Updates |
    Select-Object Title, IsDownloaded, IsInstalled, RebootRequired
```

An earlier scan showed:

- **KB890830** — Windows Malicious Software Removal Tool x64 v5.146; downloaded, not installed.
- **KB2267602** — Microsoft Defender Security Intelligence; initially offered but no longer present after subsequent scan. `Get-MpComputerStatus` showed antivirus signature version `1.463.218.0`, matching the version previously offered.

A fresh scan identified **KB890830 as the sole applicable uninstalled software update**. Selected that update alone in a `Microsoft.Update.UpdateColl` and installed it through `Microsoft.Update.UpdateInstaller`.

**Installation result:**

| Property | Observed value |
| --- | --- |
| Update | KB890830, version 5.146 |
| `ResultCode` | `2` — Succeeded |
| `HResult` | `0x00000000` |
| `RebootRequired` | `False` |

**Change control:** Did not install the optional **2026-10 Preview Update KB5127936 (26300.9818)** or optional driver update.

## Checkpoint 3G — Final applicable-update scan

Repeated the Windows Update API query for `IsInstalled=0 and Type='Software'`.

**Observed:** `Remaining software updates: 0`.

This indicates no applicable uninstalled software updates were returned by that scan at the time of verification. It does not independently establish compliance with all possible enterprise patch policies.

## Checkpoint 4 — Final operating system and hotfix inventory

Ran:

```powershell
Get-ComputerInfo |
    Select-Object CsName, OsName, OsVersion, OsBuildNumber |
    Format-List

Get-HotFix |
    Select-Object HotFixID, Description, InstalledOn |
    Format-Table -AutoSize
```

**Observed:**

- Computer: `WIN11-CLIENT01`
- OS: Microsoft Windows 11 Pro
- Version: `10.0.26300`; build `26300`
- `KB5127694` present in installed hotfix inventory, with `InstalledOn` displayed as November 10, 2026
- Six hotfix entries returned: `KB5127694`, `KB5121794`, `KB5128942`, `KB5127648`, `KB5124007`, `KB5127647`

`Get-HotFix` does not enumerate every category of update; the Windows Update API and Defender status were also used for verification.

## Outcome

**PASS — Lab complete.** Diagnosed a pending .NET security update installation, completed the servicing restart through Windows Update Settings, verified that reboot-pending indicators cleared, installed KB890830 with a successful result, and confirmed that the final Windows Update API scan returned zero applicable uninstalled software updates.

## Skills demonstrated

Windows Update troubleshooting; PowerShell COM automation; update inventory and applicability assessment; CBS and DISM diagnostics; reboot-pending analysis; Windows Update event/history review; controlled patch installation; post-install validation; change restraint around optional preview updates; incident documentation.

## Evidence checklist

Store retained screenshots directly in the repository's existing `screenshots/` directory, using a `lab21-` prefix. Only reference images that have actually been captured and saved.

- [ ] Windows Update **Restart required** state before resolution
- [ ] Windows Update screen after successful restart
- [ ] Installed .NET package or `Get-HotFix` entry for KB5127694
- [ ] KB890830 installation result (`ResultCode: 2`, `HResult: 0x00000000`)
- [ ] Final scan showing `Remaining software updates: 0`
- [ ] Final Windows 11 system and hotfix inventory

> **Note:** This was an isolated training lab. The pending update condition was observed during the exercise, not claimed to be an intentionally injected fault. Screenshots are not embedded until their final filenames are confirmed.
