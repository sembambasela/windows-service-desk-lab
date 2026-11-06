# INC-016 — Windows Service Startup Failure

| Field | Detail |
|---|---|
| Incident ID | INC-016 |
| Date | November 5, 2026 |
| Environment | Windows Service Desk Home Lab |
| Affected system | WIN11-CLIENT01 (Windows 11 Pro) |
| Affected service | `Lab16-TestService` (`Lab 16 Test Service`) |
| Category | Windows Services / Startup Failure |
| Status | **Resolved — controlled lab cleanup verified** |
| Scope | Isolated, deliberately misconfigured test service |
| Business impact | No production impact; simulated service unavailability |

## Incident description

A temporary Windows service created for Lab 16 failed to start on WIN11-CLIENT01. The simulated user-facing symptom was an unavailable service. The technician reproduced the failure, inspected Service Control Manager logs, checked service configuration and dependencies, and removed the invalid test service.

## Observed symptoms

- `Start-Service -Name 'Lab16-TestService'` returned a `CouldNotStartService` error.
- `Get-Service` reported the service remained **Stopped**.
- System log contained Service Control Manager **7009** (30,000 ms service connection timeout) and **7000** (service failed to start).

## Timeline (November 5, 2026; local workstation time)

| Time | Evidence / action |
|---|---|
| 9:12:34 PM | Event 7045: test service installed with `cmd.exe /c exit 1`, demand start, LocalSystem |
| 9:14:22 PM | Events 7009 and 7000: timeout and failed startup |
| 9:14:47 PM | Events 7009 and 7000: repeated failure |
| 9:15:37 PM | Events 7009 and 7000: repeated failure |
| Later in exercise | Configuration and dependency checks confirmed invalid executable and no registered dependencies |
| Later in exercise | `sc.exe delete Lab16-TestService` succeeded; subsequent service queries returned no results |

The precise cleanup time was not captured in the supplied output.

## Investigation and evidence

### Service state

```powershell
Get-Service -Name 'Lab16-TestService' |
    Select-Object Name, Status, StartType
```

Observed: `Stopped`, `Manual`.

### Service Control Manager events

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = 'Service Control Manager'
    StartTime = (Get-Date).AddMinutes(-10)
} |
    Where-Object { $_.Message -match 'Lab16-TestService|Lab 16 Test Service' } |
    Select-Object TimeCreated, Id, Message |
    Format-List
```

Relevant event IDs: **7045** (installation), **7009** (30-second connection timeout), **7000** (startup failure).

### Configuration

```powershell
sc.exe qc Lab16-TestService
```

Observed binary path:

```text
C:\Windows\System32\cmd.exe /c exit 1
```

Service type: `WIN32_OWN_PROCESS`; startup: `DEMAND_START`; account: `LocalSystem`.

### Dependencies

```powershell
Get-Service -Name 'Lab16-TestService' |
    Select-Object -ExpandProperty ServicesDependedOn

Get-Service -Name 'Lab16-TestService' |
    Select-Object -ExpandProperty DependentServices
```

Both commands returned no entries: no dependencies or dependents were registered.

## Root cause

The test service's executable was configured as `cmd.exe /c exit 1`. The Windows command interpreter is **not** a service-aware executable and cannot establish the required connection with Service Control Manager. Windows consequently logged a service connection timeout (7009) and startup failure (7000). This was an intentional lab misconfiguration, not an unexpected failure of a production service.

## Resolution and verification

After capturing evidence and confirming no registered service dependencies, the technician removed the invalid test service:

```powershell
sc.exe delete Lab16-TestService
```

Observed result:

```text
[SC] DeleteService SUCCESS
```

Verification:

```powershell
Get-Service -Name 'Lab16-TestService' -ErrorAction SilentlyContinue

Get-CimInstance Win32_Service |
    Where-Object { $_.Name -eq 'Lab16-TestService' } |
    Select-Object Name, State, StartMode
```

Both returned no output, confirming the service registration was removed. **The lab incident is closed as a verified cleanup**, not as restoration of a functioning application service.

## Preventive guidance / service desk lessons

1. Confirm the affected service's executable path and whether it implements the Windows service interface.
2. Correlate user-reported symptoms with Service Control Manager events before changing configuration.
3. Review dependencies and service account context before stopping, deleting, or reinstalling a service.
4. For real incidents, use an approved repair or reinstall process and verify that the application works after recovery.
5. Preserve logs and document verification rather than assuming a successful command means the user issue is resolved.

## Related documentation

[Lab 16 — Windows Service Troubleshooting and Incident Management](../docs/21-lab16-windows-service-troubleshooting.md)
