# Lab 06 — Windows Server 2025 Installation and Initial Configuration

**Project:** Windows IT Service Desk Home Lab  
**Phase:** 2 — Windows Server and Active Directory  
**Status:** Completed  
**Server:** DC01  
**Operating System:** Windows Server 2025 Standard Evaluation (Desktop Experience)

## 1. Objective

Deploy and configure a Windows Server 2025 virtual machine to establish the server infrastructure for future Active Directory, DNS, identity management, and enterprise troubleshooting labs.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Host operating system | Windows 10 Home |
| Host processor | AMD Ryzen 7 9700X |
| Host memory | 32 GB installed |
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Virtual machine | DC01 |
| Guest operating system | Windows Server 2025 Standard Evaluation |
| VM memory | 4 GB |
| Virtual processors | 2 |
| Virtual disk | 80 GB |
| Network Adapter 1 | NAT |
| Network Adapter 2 | Internal Network (`AD-LAB`) |

## 3. Implementation

### 3.1 Virtual Machine Deployment

Installed Oracle VirtualBox and created the `DC01` virtual machine using the Windows Server 2025 evaluation ISO.

Configured the VM with 4 GB RAM, two virtual processors, an 80 GB virtual disk, and two network adapters.

### 3.2 Windows Server Installation

Installed **Windows Server 2025 Standard Evaluation (Desktop Experience)** using the graphical installation wizard.

Configured the built-in Administrator account and successfully signed in to Server Manager.

### 3.3 Server Identification

Renamed the default Windows computer name to `DC01` and restarted the server.

Verified the change using PowerShell:

```powershell
hostname
```

**Result:** `DC01`

### 3.4 Network Configuration

Configured two virtual network adapters to separate external connectivity from internal lab communication.

| Adapter | Network | Purpose |
|---|---|---|
| Ethernet | NAT | Internet connectivity |
| Ethernet 2 | AD-LAB | Internal domain network |

Assigned the internal adapter the following static configuration:

| Property | Value |
|---|---|
| IPv4 address | `192.168.100.10` |
| Subnet mask | `255.255.255.0` |
| Default gateway | None |
| DNS server | `192.168.100.10` |

The internal DNS address was configured in preparation for the DNS Server role, which will be configured in a subsequent lab.

### 3.5 Network Verification

Verified the static IPv4 configuration using PowerShell:

```powershell
Get-NetIPAddress -InterfaceAlias "Ethernet 2" -AddressFamily IPv4 |
    Select-Object InterfaceAlias, PrefixLength, PrefixOrigin, AddressState
```

**Result:** Prefix length 24, manual configuration, preferred address state.

Verified the intended internal IPv4 address and DNS configuration using filtered PowerShell queries.

Tested external connectivity:

```powershell
Test-Connection 1.1.1.1 -Count 2 -Quiet

[bool](Resolve-DnsName microsoft.com -ErrorAction SilentlyContinue)
```

**Results:** Both tests returned `True`.

## 4. Verification Summary

| Verification | Result |
|---|---|
| Windows Server installation | Passed |
| Administrator sign-in | Passed |
| Server renamed to DC01 | Passed |
| Both network adapters detected | Passed |
| Static internal IPv4 configuration | Passed |
| Internal DNS client configuration | Passed |
| External network connectivity | Passed |
| Public DNS resolution | Passed |

## 5. Issues and Observations

- The host operating system is Windows 10 Home, so Oracle VirtualBox was used instead of Hyper-V.
- NAT and internal networking were configured separately to isolate future Active Directory lab traffic.
- The internal DNS address was configured before deployment of the DNS Server role; this is a preparatory configuration rather than confirmation of an operational DNS service.
- VirtualBox Guest Additions installation was initiated to support improved guest integration and bidirectional clipboard sharing. Successful clipboard operation was not formally verified as part of this lab.

## 6. Skills Demonstrated

- Virtual machine deployment and resource allocation
- Windows Server installation and initial administration
- Server naming and system configuration
- VirtualBox network configuration
- Static IPv4 addressing and DNS client configuration
- PowerShell network diagnostics
- Connectivity testing and verification

## 7. Outcome

Successfully deployed Windows Server 2025 as `DC01`, configured the isolated `AD-LAB` network, and verified network connectivity.

The server is prepared for Active Directory Domain Services deployment.

**Next Lab:** Lab 07 — Active Directory Domain Services Installation and Domain Controller Configuration.