# Lab 16 — Windows Service Troubleshooting and Incident Management

**Project:** Windows Service Desk Lab  
**Date:** November 5, 2026  
**Workstation:** WIN11-CLIENT01 (Windows 11 Pro; `corp.example.test` lab)  
**Status:** Completed — controlled test service removed and removal verified  
**Related incident:** [INC-016 — Windows Service Startup Failure](../incident-reports/INC-016-windows-service-startup-failure.md)

## Objectives

- Inspect Windows services, startup modes, and service accounts.
- Reproduce a noncritical service startup failure in a controlled environment.
- Correlate PowerShell errors with Service Control Manager events.
- Inspect the service executable and registered dependencies.
- Safely remove the intentionally invalid test service and verify cleanup.
- Record evidence and distinguish lab cleanup from production service restoration.

## Scope and safety

All commands were executed on **WIN11-CLIENT01**, not on domain controller DC01. The exercise used a newly created, temporary service named `Lab16-TestService`. No existing Windows service was intentionally stopped or disabled. The Windows Time service was inspected only.

## Checkpoint 1 — Baseline assessment (passed)

### Running services

```powershell
Get-Service |
    Where-Object { $_.Status -eq 'Running' } |
    Select-Object -First 15 Name, DisplayName, Status |
    Format-Table -AutoSize
```

Sample observed running services included `AppIDSvc`, `Appinfo`, `AppXSvc`, `AudioEndpointBuilder`, `Audiosrv`, `BDESVC`, and `BFE`.

### Stopped automatic services

```powershell
Get-CimInstance Win32_Service |
    Where-Object { $_.StartMode -eq 'Auto' -and $_.State -eq 'Stopped' } |
    Select-Object Name, DisplayName, StartMode, State |
    Format-Table -AutoSize
```

Observed: `edgeupdate`, `MapsBroker`, `sppsvc`, and `TrustedInstaller`. These states alone did **not** establish a fault; some services start on demand or by trigger.

### Windows Time inspection

```powershell
Get-CimInstance Win32_Service -Filter "Name='W32Time'" |
    Select-Object Name, DisplayName, State, StartMode, StartName, PathName |
    Format-List
```

Observed: `W32Time` was **Running**, `StartMode=Manual`, running as `NT AUTHORITY\LocalService`, with executable `C:\WINDOWS\system32\svchost.exe -k LocalService`. No changes were made.

## Checkpoint 2 — Create isolated test service (passed)

```powershell
Get-Service -Name 'Lab16-TestService' -ErrorAction SilentlyContinue

New-Service `
    -Name 'Lab16-TestService' `
    -DisplayName 'Lab 16 Test Service' `
    -BinaryPathName 'C:\Windows\System32\cmd.exe /c exit 1' `
    -StartupType Manual `
    -Description 'Temporary service for Lab 16 troubleshooting exercises'

Get-CimInstance Win32_Service -Filter "Name='Lab16-TestService'" |
    Select-Object Name, DisplayName, State, StartMode, PathName |
    Format-List
```

Verified properties:

| Property | Value |
|---|---|
| Name | `Lab16-TestService` |
| Display name | `Lab 16 Test Service` |
| State | `Stopped` |
| Start mode | `Manual` |
| Executable | `C:\Windows\System32\cmd.exe /c exit 1` |

The executable was intentionally unsuitable for a Windows service: `cmd.exe` is a command interpreter, not an application implementing the Windows service interface.

## Checkpoint 3 — Reproduce and investigate failure (passed)

```powershell
Start-Service -Name 'Lab16-TestService'

Get-Service -Name 'Lab16-TestService' |
    Select-Object Name, Status, StartType

Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = 'Service Control Manager'
    StartTime = (Get-Date).AddMinutes(-10)
} |
    Where-Object { $_.Message -match 'Lab16-TestService|Lab 16 Test Service' } |
    Select-Object TimeCreated, Id, Message |
    Format-List
```

**Observed result:** `Start-Service` returned `ServiceCommandException` / `CouldNotStartService`. The service remained **Stopped** with **Manual** startup.

### Recorded Service Control Manager events

| Date/time (workstation local) | Event ID | Observation |
|---|---:|---|
| Nov 5, 2026 9:12:34 PM | 7045 | Service installed; binary `C:\Windows\System32\cmd.exe /c exit 1`; demand start; LocalSystem |
| Nov 5, 2026 9:14:22 PM | 7009 | 30,000 ms timeout waiting for service to connect |
| Nov 5, 2026 9:14:22 PM | 7000 | Service failed to start; did not respond in time |
| Nov 5, 2026 9:14:47 PM | 7009 / 7000 | Repeated timeout and startup failure |
| Nov 5, 2026 9:15:37 PM | 7009 / 7000 | Repeated timeout and startup failure |

The events support a service connection timeout. Together with the deliberately invalid executable path, they establish the cause of this controlled incident.

## Checkpoint 4 — Configuration and dependency checks (passed)

```powershell
sc.exe qc Lab16-TestService

Get-Service -Name 'Lab16-TestService' |
    Select-Object -ExpandProperty ServicesDependedOn

Get-Service -Name 'Lab16-TestService' |
    Select-Object -ExpandProperty DependentServices
```

Configuration observed:

| Field | Value |
|---|---|
| Type | `WIN32_OWN_PROCESS` |
| Start type | `DEMAND_START` |
| Error control | `NORMAL` |
| Binary path | `C:\Windows\System32\cmd.exe /c exit 1` |
| Service account | `LocalSystem` |
| Required dependencies | None registered |
| Dependent services | None registered |

**Root cause:** `cmd.exe` does not register and communicate with Service Control Manager as a Windows service. The 30-second connection timeout and subsequent startup failure were expected consequences of the deliberately invalid service binary.

## Checkpoint 5 — Cleanup and verification (passed)

```powershell
sc.exe delete Lab16-TestService

Get-Service -Name 'Lab16-TestService' -ErrorAction SilentlyContinue

Get-CimInstance Win32_Service |
    Where-Object { $_.Name -eq 'Lab16-TestService' } |
    Select-Object Name, State, StartMode
```

Observed:

```text
[SC] DeleteService SUCCESS
```

Both follow-up service queries returned **no output**, confirming the test service was absent from the service inventory.

## Outcome and lessons learned

- **Controlled incident resolved:** The invalid lab service registration was removed, and its absence verified.
- **Not a production application repair:** No functional application service was restored or tested. A real incident would require correcting/reinstalling the legitimate service and verifying the dependent application.
- Event IDs **7045**, **7009**, and **7000** provided a useful timeline from installation to startup failure.
- A stopped automatic service is not automatically evidence of a fault.
- Checking executable paths, startup modes, service accounts, and dependencies is essential before making service changes.
- Use a dedicated test service rather than interrupting domain, network, or security services during practice.

## Portfolio evidence

The evidence consists of the actual PowerShell command outputs and Event Viewer messages recorded above. No screenshots are claimed or included.

**Related report:** [`INC-016-windows-service-startup-failure.md`](../incident-reports/INC-016-windows-service-startup-failure.md)
