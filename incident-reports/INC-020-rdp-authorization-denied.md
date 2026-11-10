# INC-020 — Remote Desktop Authorization Denied

| Field | Value |
|---|---|
| Ticket ID | INC-020 (portfolio lab identifier) |
| Classification | Incident — access / remote support |
| Status | Resolved; temporary access removed after validation |
| Impact | Simulated standard user unable to establish RDP session |
| Affected account | `CORP\jordan.lee` |
| Affected endpoint | `WIN11-CLIENT01` (`192.168.100.20`) |
| Connection source | `DC01` (`192.168.100.10`) |
| Related lab | [Lab 20 — Remote Desktop and Remote Support](../docs/lab20-remote-desktop-support.md) |

## Reported symptom

An RDP attempt from DC01 to WIN11-CLIENT01 using `CORP\jordan.lee` was rejected:

> The connection was denied because the user account is not authorized for remote login

A separate RDP session using `CORP\Administrator` had succeeded, and TCP 3389 connectivity was confirmed while the temporary restricted firewall rule was active.

## Troubleshooting and evidence

| Check | Evidence | Interpretation |
|---|---|---|
| Account enabled | AD lookup returned `jordan.lee`, `Enabled = True` | Account not disabled |
| Domain groups | `Domain Users` only | No relevant elevated membership identified |
| Local RDP group | `Get-LocalGroupMember 'Remote Desktop Users'` returned no members | User not locally authorized through this group |
| Security log | No matching 4625 in queried 30-minute window | No matching event found; not proof of no failure |
| RemoteConnectionManager | 1149 successful authentication for `CORP\Administrator`; connection listener events | RDP connectivity and admin authentication worked |
| LocalSessionManager | Jordan session arbitration (IDs 41/42) and disconnection activity | Session activity observed, but no confirmed desktop logon |
| Logon right | `SeRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-555` | Administrators and Remote Desktop Users authorized |
| Deny logon right | No matching `SeDenyRemoteInteractiveLogonRight` line in export | No explicit deny shown in inspected export |

## Root cause

The simulated user's account lacked membership in a group granted **Allow log on through Remote Desktop Services** on the workstation. The local Remote Desktop Users group was empty, and Jordan was not an administrator.

## Resolution

On WIN11-CLIENT01:

```powershell
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'CORP\jordan.lee'
Get-LocalGroupMember -Group 'Remote Desktop Users' |
  Select-Object Name, ObjectClass, PrincipalSource
```

Verified `CORP\jordan.lee` as an Active Directory user in the local Remote Desktop Users group. The follow-up RDP test was **confirmed passed by the lab operator**; no transcript of the remote `hostname`/`whoami` output was provided. No administrator role was granted.

## Post-resolution cleanup

```powershell
Remove-LocalGroupMember -Group 'Remote Desktop Users' -Member 'CORP\jordan.lee'
Remove-NetFirewallRule -Name 'LAB20-RDP-DC01'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' `
  -Name 'fDenyTSConnections' -Value 1
```

Verification showed the local RDP group empty, temporary firewall rule absent, `fDenyTSConnections = 1`, built-in RDP firewall rules disabled, and final DC01-to-workstation TCP 3389 test **False**. `TermService` remained Running / Manual because `UmRdpService` was running; no force-stop was performed.

## Closure

**Resolved and closed for the lab.** The authorization failure was corrected and tested, then the temporary access was revoked. The workstation's incoming RDP security settings were restored. The remaining service-state difference is documented in the lab report.

## Prevention / service desk takeaway

For a user who can authenticate but cannot sign in via RDP, check both the effective remote-interactive logon rights and local Remote Desktop Users membership before granting elevated privileges. Scope firewall access to trusted sources and remove temporary permissions when support work ends.

> All account names, incident details, and service desk actions are simulated portfolio exercises.
