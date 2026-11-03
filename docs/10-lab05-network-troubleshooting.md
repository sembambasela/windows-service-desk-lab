# Lab 05 — Network Connectivity and DNS Troubleshooting

## Objective

Diagnose and resolve network connectivity issues in a Windows 11 ARM64 virtual machine using Device Manager, PowerShell, and VirtualBox network configuration.

## Lab Environment

| Component | Configuration |
|---|---|
| Host | Apple M1 MacBook |
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Guest OS | Windows 11 Pro ARM64 |
| Virtual Machine | WIN11-CLIENT01 |
| Network Mode | NAT |
| Final Network Adapter | Paravirtualized Network (virtio-net) |
| Driver | Red Hat VirtIO Ethernet Adapter (NetKVM) |

## Incident Reference

**Incident ID:** INC-001  
**Issue:** Windows virtual machine unable to establish network connectivity  
**Final Status:** Resolved

## Troubleshooting and Investigation

### 1. Initial Network Adapter Failure

Device Manager identified the **UsbNcm Host Device** with error **Code 10**, indicating that the device could not start.

The installed Microsoft driver was identified as `UsbNcm.sys`.

Changing the VirtualBox network attachment from Bridged Adapter to NAT did not resolve the issue. Disabling and re-enabling the device was also unsuccessful.

PowerShell's `ipconfig /all` output showed no usable network interface, IPv4 address, default gateway, or DNS configuration.

### 2. Alternative Network Adapter Testing

Changed the VirtualBox adapter type to **Paravirtualized Network (virtio-net)** while retaining NAT networking.

Windows detected an Ethernet Controller under **Other devices**, but Device Manager reported **Code 28**, indicating that no compatible driver was installed.

The hardware ID was identified as:

`PCI\VEN_1AF4&DEV_1000`

### 3. Driver Installation

Obtained a VirtIO Windows driver ISO containing Windows 11 ARM64 NetKVM drivers.

Mounted the ISO through VirtualBox and located:

`NetKVM\w11\ARM64`

Installed the driver using **Device Manager → Update driver → Browse my computer for drivers**.

Windows confirmed successful installation of the **Red Hat VirtIO Ethernet Adapter**.

## Resolution Verification

The following PowerShell commands were used to verify the network connection:

```powershell
Get-NetAdapter | Select-Object Name, Status, LinkSpeed
Test-Connection 1.1.1.1 -Count 2 -Quiet
[bool](Resolve-DnsName example.com -ErrorAction SilentlyContinue)
```

| Verification | Result |
|---|---|
| Adapter | Red Hat VirtIO Ethernet Adapter |
| Adapter Status | Up |
| Reported Link Speed | 10 Gbps |
| External IP Connectivity | True |
| DNS Resolution | True |

All connectivity verification tests passed. Network access was successfully restored without reinstalling Windows.

## Outcome

**INC-001 was resolved** by replacing the nonfunctional USB NCM virtual network adapter with a VirtIO network adapter and installing a compatible Windows 11 ARM64 NetKVM driver.

The underlying reason for the original USB NCM Code 10 failure was not conclusively established.

## Evidence

Screenshots are stored in `screenshots/lab05/`.

| Screenshot | Description |
|---|---|
| `lab05-01-network-adapter-code10.png` | Initial USB NCM adapter failure |
| `lab05-03-ipconfig-no-adapter.png` | No usable network interface detected |
| `lab05-06-powershell-device-status.png` | Network device status investigation |
| `lab05-08-device-problem-status.png` | USB NCM device start failure details |
| `lab05-10-ethernet-controller-missing-driver.png` | VirtIO Ethernet Controller missing driver |
| `lab05-11-virtio-hardware-ids.png` | VirtIO hardware identification |
| `lab05-12-network-connectivity-restored.png` | Successful network and DNS verification |

## Skills Demonstrated

- Windows network adapter troubleshooting
- Device Manager error diagnosis (Codes 10 and 28)
- VirtualBox NAT and virtual network configuration
- Windows ARM64 driver installation
- PowerShell network diagnostics
- TCP/IP connectivity and DNS verification
- Incident troubleshooting and resolution documentation
