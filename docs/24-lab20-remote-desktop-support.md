# Lab 20 — Remote Desktop and Remote Support

**Status:** Completed  
**Environment:** Isolated VirtualBox Active Directory lab  
**Systems:** `DC01` (Windows Server 2025, `192.168.100.10`) and `WIN11-CLIENT01` (Windows 11 Pro, `192.168.100.20`)  
**Domain:** `corp.example.test` (`CORP`)  
**Related incident:** [INC-020 — RDP authorization denied](../incident-reports/INC-020-rdp-authorization-denied.md)

## Objectives

1. Establish a secure, restricted RDP connection from the domain controller to the Windows 11 workstation.
2. Verify Network Level Authentication (NLA) and domain connectivity.
3. Reproduce and troubleshoot a standard domain user's RDP authorization failure.
4. Apply least-privilege access, validate the fix, and reverse temporary configuration changes.
5. Verify the workstation is no longer reachable on TCP port 3389 from DC01.

## Initial baseline

| Item | Observed baseline |
|---|---|
| Workstation | `WIN11-CLIENT01`, Windows 11 Pro |
| Domain secure channel | `Test-ComputerSecureChannel` returned `True` |
| DC LDAP connectivity | `Test-NetConnection 192.168.100.10 -Port 389`: `True` |
| Internal adapter | `Ethernet 2`, `DomainAuthenticated`, `192.168.100.20` |
| NAT adapter | `Ethernet`, `Public` |
| RDP configuration | `fDenyTSConnections = 1` (disabled) |
| RDP listener port | TCP `3389` |
| NLA | `UserAuthentication = 1` |
| `TermService` | Stopped; startup type Manual |
| Built-in `RemoteDesktop*` firewall rules | Disabled |
| Local Remote Desktop Users | Empty |

## Phase 1 — Enable restricted RDP

On `WIN11-CLIENT01`, enabled RDP by setting `fDenyTSConnections` to `0`. Confirmed `TermService` was running and NLA remained enabled. Created a tightly scoped firewall rule allowing inbound TCP 3389 **only** on the domain profile, from DC01's internal IP to the workstation's internal IP:

```powershell
New-NetFirewallRule `
  -DisplayName "LAB20 - RDP from DC01" `
  -Name "LAB20-RDP-DC01" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 3389 `
  -LocalAddress 192.168.100.20 `
  -RemoteAddress 192.168.100.10 `
  -Profile Domain `
  -Action Allow
```

From DC01, `Test-NetConnection 192.168.100.20 -Port 3389` returned `TcpTestSucceeded : True`. Connected using `mstsc /v:192.168.100.20` and `CORP\Administrator`. Within the session, `hostname` returned `WIN11-CLIENT01` and `whoami` returned `corp\administrator`.

## Phase 2 — Reproduce standard-user authorization failure

- On the workstation, the local `Remote Desktop Users` group was empty. Local Administrators included `CORP\Domain Admins` and local administrator accounts.
- On DC01, `jordan.lee` was enabled and belonged to `Domain Users` only.
- An RDP attempt using `CORP\jordan.lee` was rejected with: **“The connection was denied because the user account is not authorized for remote login.”**
- A Security event 4625 query filtered for `jordan.lee` returned no matching records in the specified 30-minute window.
- The RemoteConnectionManager operational log showed Event ID 1149 for successful `CORP\Administrator` authentication from `192.168.100.10`, plus listener connection events (ID 261). It did not show an explicit 1149 success for Jordan in the displayed entries.
- The LocalSessionManager operational log showed Jordan's session arbitration starting and ending (Event IDs 41 and 42), with disconnection activity (IDs 39/40). The displayed records did not establish a successful desktop logon for Jordan.

### User-rights policy verification

Exported user-rights assignments:

```powershell
secedit /export /cfg C:\Windows\Temp\lab20-security.cfg /areas USER_RIGHTS
Select-String -Path 'C:\Windows\Temp\lab20-security.cfg' `
  -Pattern 'SeRemoteInteractiveLogonRight|SeDenyRemoteInteractiveLogonRight'
```

Observed:

```text
SeRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-555
```

These SIDs represent **BUILTIN\Administrators** and **BUILTIN\Remote Desktop Users**. No explicit deny assignment was shown in the exported result. Because Jordan was not in either authorized local group, the evidence supported a missing RDP logon authorization as the root cause.

## Phase 3 — Least-privilege remediation and validation

On `WIN11-CLIENT01`:

```powershell
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'CORP\jordan.lee'
Get-LocalGroupMember -Group 'Remote Desktop Users' |
  Select-Object Name, ObjectClass, PrincipalSource
```

Verified membership:

```text
CORP\jordan.lee  User  ActiveDirectory
```

Retested RDP from DC01 as `CORP\jordan.lee`. **The user confirmed the checkpoint passed.** This validation is recorded as user-confirmed rather than as a pasted `hostname`/`whoami` transcript. No administrator privileges were granted to Jordan.

## Phase 4 — Rollback and security verification

1. Removed Jordan from the local Remote Desktop Users group; verified the group returned no members.
2. Deleted the temporary firewall rule `LAB20-RDP-DC01`; verified it was absent.
3. Restored `fDenyTSConnections = 1` and verified the value.
4. Verified all four built-in `RemoteDesktop*` firewall rules were disabled.
5. Checked `TermService`: **Running / Manual**, whereas the initial baseline had been **Stopped / Manual**.
6. Attempted `Stop-Service TermService -ErrorAction Stop`; Windows refused because dependent services were running. Did **not** use `-Force`.
7. Identified `UmRdpService` (Remote Desktop Services UserMode Port Redirector) as a **Running / Manual** dependent service; left both services running.
8. From DC01, ran `Test-NetConnection 192.168.100.20 -Port 3389` and observed:

```text
ComputerName     : 192.168.100.20
RemotePort       : 3389
InterfaceAlias   : Ethernet 2
SourceAddress    : 192.168.100.10
PingSucceeded    : False
TcpTestSucceeded : False
```

The failed TCP test confirms that DC01 could not establish a TCP connection to port 3389 at the end of the exercise. The ping result is not used as evidence of RDP access control.

## Outcome

**Completed.** Restricted RDP access was configured and validated; a standard-user authorization failure was reproduced, diagnosed, corrected through least-privilege group membership, and retested. Temporary user access and firewall configuration were removed. RDP was disabled again, and a final TCP 3389 connection test failed as expected.

**Documented exception:** `TermService` remained Running (Manual) rather than its initial Stopped (Manual) state because the dependent `UmRdpService` was running. This is not, by itself, evidence that inbound RDP access remains enabled.

## Skills demonstrated

Remote Desktop configuration, NLA, Windows Defender Firewall scoping, Active Directory account verification, local group authorization, user-rights policy analysis, Event Viewer troubleshooting, PowerShell diagnostics, least-privilege remediation, rollback, and incident documentation.

> **Portfolio note:** All identities and incidents are simulated in a private learning environment. No production systems were accessed.
