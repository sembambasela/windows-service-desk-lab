# INC-001 — Windows Network Adapter Failure

## Incident Overview

| Field | Details |
|---|---|
| Incident ID | INC-001 |
| Category | Network Connectivity / Device Driver |
| Affected System | WIN11-CLIENT01 |
| Operating System | Windows 11 Pro ARM64 |
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Priority | Medium (Lab Classification) |
| Status | Resolved |
| Resolution Date | November 2, 2026 |

## Issue Description

The Windows 11 ARM64 virtual machine was unable to establish network connectivity.

Device Manager reported **Code 10** for the USB NCM network adapter, preventing Windows from initializing the device. Network diagnostics showed no usable network interface or assigned IP configuration.

## Investigation

1. Identified the **UsbNcm Host Device** failure in Device Manager and reviewed the installed Microsoft `UsbNcm.sys` driver.
2. Tested both Bridged Adapter and NAT networking in VirtualBox. The Code 10 error persisted.
3. Disabled and re-enabled the USB NCM device without resolving the failure.
4. Reviewed device events, which confirmed that the USB NCM device had failed to start.
5. Changed the virtual network adapter to **Paravirtualized Network (virtio-net)**.
6. Windows detected an Ethernet Controller but reported **Code 28**, indicating a missing driver.
7. Identified the VirtIO network device using hardware ID `PCI\VEN_1AF4&DEV_1000`.

## Root Cause and Findings

The original USB NCM adapter could not initialize successfully despite having a Windows driver installed. The underlying cause of this Code 10 failure was not conclusively determined.

The alternative VirtIO network adapter initially lacked a compatible Windows ARM64 driver, resulting in Code 28.

## Resolution

Mounted a VirtIO Windows driver ISO and located the Windows 11 ARM64 network driver at:

`NetKVM\w11\ARM64`

Installed the **Red Hat VirtIO Ethernet Adapter** driver through Device Manager.

Windows successfully initialized the new network adapter, restoring network connectivity.

## Resolution Verification

Executed the following PowerShell commands:

```powershell
Get-NetAdapter | Select-Object Name, Status, LinkSpeed
Test-Connection 1.1.1.1 -Count 2 -Quiet
[bool](Resolve-DnsName example.com -ErrorAction SilentlyContinue)
```

| Verification | Result |
|---|---|
| Network Adapter | Red Hat VirtIO Ethernet Adapter |
| Adapter Status | Up |
| Reported Link Speed | 10 Gbps |
| External IP Connectivity | True |
| DNS Resolution | True |

**Resolution confirmed:** The virtual machine successfully established network connectivity and resolved DNS queries.

## Supporting Evidence

Screenshots are available in `screenshots/`.

- `lab05-01-network-adapter-code10.png` — Initial USB NCM failure.
- `lab05-03-ipconfig-no-adapter.png` — Missing network interface.
- `lab05-08-device-problem-status.png` — Device start failure details.
- `lab05-10-ethernet-controller-missing-driver.png` — VirtIO Code 28 issue.
- `lab05-11-virtio-hardware-ids.png` — VirtIO hardware identification.
- `lab05-12-network-connectivity-restored.png` — Successful connectivity verification.

## Incident Closure

**Final Status:** Resolved

**Resolution:** Reconfigured VirtualBox networking to use a VirtIO network adapter and installed the compatible Windows 11 ARM64 NetKVM driver.

**Related Lab:** [Lab 05 — Network Connectivity and DNS Troubleshooting](../docs/10-lab05-network-troubleshooting.md)
