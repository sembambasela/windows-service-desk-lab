# Lab 07 — Active Directory Domain Services Installation and Domain Controller Configuration

## Objective

Install and configure Active Directory Domain Services (AD DS) on Windows Server 2025, promote the server to a domain controller, and establish a new Active Directory forest for a simulated enterprise environment.

## Lab Environment

| Component | Configuration |
|---|---|
| Virtualization Platform | Oracle VirtualBox 7.2.22 |
| Server Operating System | Windows Server 2025 Standard Evaluation |
| Server Hostname | DC01 |
| Active Directory Domain | corp.example.test |
| NetBIOS Domain Name | CORP |
| Forest Functional Level | Windows Server 2025 |
| Domain Functional Level | Windows Server 2025 |
| Internal Network | AD-LAB |
| Domain Controller IPv4 | 192.168.100.10/24 |
| Network Configuration | NAT + Internal Network |

## Implementation

### 1. Install Active Directory Domain Services

Used Server Manager to install the following server roles and management tools:

- Active Directory Domain Services (AD DS)
- Group Policy Management
- Active Directory PowerShell module
- Active Directory Administrative Center
- AD DS management tools

The installation completed successfully and required additional configuration to promote the server.

### 2. Create a New Active Directory Forest

Launched the Active Directory Domain Services Configuration Wizard and selected **Add a new forest**.

Configured the root domain name as:

`corp.example.test`

### 3. Configure Domain Controller Options

Applied the following configuration:

| Setting | Value |
|---|---|
| Forest Functional Level | Windows Server 2025 |
| Domain Functional Level | Windows Server 2025 |
| DNS Server | Enabled |
| Global Catalog | Enabled |
| Read-Only Domain Controller | Disabled |
| Directory Services Restore Mode | Password configured |

The DSRM password was stored securely and excluded from project documentation.

### 4. Configure DNS and Domain Settings

- Left DNS delegation disabled because the lab uses a new, isolated Active Directory forest.
- Accepted the automatically generated NetBIOS name `CORP`.
- Retained the default Active Directory database, log, and SYSVOL locations.

| Component | Path |
|---|---|
| AD DS Database | `C:\Windows\NTDS` |
| AD DS Logs | `C:\Windows\NTDS` |
| SYSVOL | `C:\Windows\SYSVOL` |

### 5. Validate Prerequisites and Promote the Server

Ran the Active Directory prerequisite checks.

Two warnings were reported:

1. A network adapter did not have a static IP address.
2. DNS delegation could not be created.

The first warning was associated with the lab's dual-adapter configuration, which uses DHCP for NAT connectivity and a static IPv4 address for the internal network.

The DNS delegation warning was expected because no authoritative parent DNS zone was configured for the isolated lab domain.

**Result:** All prerequisite checks passed successfully.

Started domain controller promotion. The server restarted, and domain sign-in was successful.

## Verification

### 1. Verify Active Directory Domain Configuration

Executed:

```powershell
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, PDCEmulator
```

Verified output:

```text
DNSRoot           NetBIOSName PDCEmulator
-------           ----------- -----------
corp.example.test CORP        DC01.corp.example.test
```

This confirmed that the domain was created and `DC01` held the PDC Emulator role.

### 2. Verify Essential Domain Controller Services

Executed:

```powershell
Get-Service NTDS, DNS, Netlogon, KDC |
    Select-Object Name, Status, StartType
```

Verified results:

| Service | Status | Startup Type |
|---|---|---|
| DNS | Running | Automatic |
| KDC | Running | Automatic |
| Netlogon | Running | Automatic |
| NTDS | Running | Automatic |

All four essential services were operational.

### 3. Verify Active Directory DNS Discovery

Executed:

```powershell
Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.corp.example.test" -Type SRV -Server 192.168.100.10
```

Confirmed that the DNS SRV record identified:

`dc01.corp.example.test`

The DNS response also included the correct internal IPv4 address:

`192.168.100.10`

This verified that DNS was publishing a domain controller discovery record.

### 4. Identify and Correct DNS Registration Configuration

During verification, DNS returned an additional IPv4 address belonging to the VirtualBox NAT adapter:

`10.0.2.15`

This could cause domain-joined clients to receive an address that is not reachable from the internal lab network.

Inspected DNS client registration settings:

```powershell
Get-DnsClient |
    Select-Object InterfaceAlias, RegisterThisConnectionsAddress
```

Both adapters initially had DNS registration enabled.

Disabled DNS registration on the NAT adapter:

```powershell
Set-DnsClient -InterfaceAlias "Ethernet" -RegisterThisConnectionsAddress $false
```

Verified the updated configuration:

| Adapter | Register in DNS |
|---|---|
| Ethernet (NAT) | False |
| Ethernet 2 (AD-LAB) | True |

**Result:** The NAT adapter was configured to stop registering its address in DNS. Cleanup of the existing unwanted DNS record remains pending and will be addressed in Lab 08.

## Results

**Lab Status: Complete**

- AD DS installed successfully.
- New Active Directory forest created.
- DC01 promoted to domain controller.
- Domain and NetBIOS names verified.
- Essential Active Directory services confirmed running.
- Domain controller DNS discovery verified.
- Unwanted NAT adapter DNS registration disabled.

## Skills Demonstrated

- Windows Server administration
- Active Directory Domain Services deployment
- Domain controller promotion
- Active Directory forest configuration
- DNS and SRV record verification
- PowerShell administration
- Domain controller service validation
- Troubleshooting multi-homed domain controller DNS registration

## Next Lab

**Lab 08 — DNS Configuration and Verification**

Validate DNS records, remove the unwanted NAT adapter address, and verify reliable name resolution for future domain-joined Windows clients.