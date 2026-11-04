# Lab 09 — Windows 11 Domain Join and Active Directory Authentication

**Project:** Windows Enterprise IT Service Desk Home Lab  
**Phase:** 2 — Windows Server and Active Directory  
**Status:** Completed  
**Environment:** Oracle VirtualBox, Windows Server 2025, Windows 11 Pro

## 1. Objective

Configure a Windows 11 Pro workstation to communicate with a Windows Server 2025 domain controller, join an Active Directory domain, and verify successful domain authentication.

This lab demonstrates workstation provisioning, TCP/IP configuration, DNS troubleshooting, Active Directory integration, and domain membership verification.

## 2. Lab Environment

| Component | Configuration |
|---|---|
| Hypervisor | Oracle VirtualBox |
| Domain controller | DC01 |
| Server operating system | Windows Server 2025 Standard Evaluation |
| Client workstation | WIN11-CLIENT01 |
| Client operating system | Windows 11 Pro |
| Active Directory domain | corp.example.test |
| NetBIOS domain | CORP |
| Internal network | AD-LAB |
| Domain controller IPv4 | 192.168.100.10/24 |
| Client IPv4 | 192.168.100.20/24 |
| Client DNS server | 192.168.100.10 |

The client virtual machine was configured with 4 GB RAM, 2 virtual CPUs, a 64 GB virtual disk, and two network adapters:

- **Adapter 1 — NAT:** Internet connectivity.
- **Adapter 2 — Internal Network (AD-LAB):** Communication with the domain controller.

## 3. Windows 11 Workstation Setup

Installed Windows 11 Pro in VirtualBox and completed the initial operating system setup.

Created a local administrator account, `LabAdmin`, for workstation configuration and troubleshooting.

Configured the computer hostname as:

```text
WIN11-CLIENT01
```

Verified the hostname using:

```powershell
hostname
```

## 4. Network Configuration

Verified that both virtual network adapters were operational:

```powershell
Get-NetAdapter |
    Select-Object Name, InterfaceDescription, Status, LinkSpeed
```

Both `Ethernet` and `Ethernet 2` reported an operational status of `Up`.

Assigned a static IPv4 address to the internal network adapter:

```powershell
New-NetIPAddress `
    -InterfaceAlias "Ethernet 2" `
    -IPAddress "192.168.100.20" `
    -PrefixLength 24
```

Configured the internal adapter to use the domain controller for DNS:

```powershell
Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet 2" `
    -ServerAddresses "192.168.100.10"
```

Verified the network configuration:

```powershell
Get-NetIPConfiguration -InterfaceAlias "Ethernet 2"
```

Confirmed that the internal adapter had no default gateway and used `192.168.100.10` for DNS.

### IPv4 Address State Verification

During initial configuration, Windows reported temporary `Tentative` and `Invalid` address states.

Rechecked the address using:

```powershell
Get-NetIPAddress -InterfaceAlias "Ethernet 2" -AddressFamily IPv4 |
    Select-Object IPAddress, PrefixLength, AddressState
```

Verified the final result:

```text
IPAddress      PrefixLength AddressState
---------      ------------ ------------
192.168.100.20           24 Preferred
```

## 5. Domain Controller Connectivity

Tested communication from WIN11-CLIENT01 to DC01:

```powershell
Test-Connection -ComputerName 192.168.100.10 -Count 4
```

**Result:** Four successful responses from the domain controller.

This verified basic IPv4 connectivity across the isolated AD-LAB network.

## 6. DNS Troubleshooting

Queried the domain controller's DNS A record:

```powershell
Resolve-DnsName `
    -Name "dc01.corp.example.test" `
    -Type A `
    -Server 192.168.100.10 `
    -DnsOnly
```

### Issue Identified

DNS returned two IPv4 addresses for DC01:

```text
192.168.100.10
10.0.2.15
```

The `10.0.2.15` address belonged to DC01's VirtualBox NAT adapter and was not the intended address for communication over AD-LAB.

This could cause domain clients to attempt connections through an unsuitable network interface.

### Investigation

On DC01, inspected the DNS records:

```powershell
Get-DnsServerResourceRecord `
    -ZoneName "corp.example.test" `
    -Name "dc01" `
    -RRType "A"
```

Confirmed that both A records existed in the DNS zone.

### Resolution

Removed the unwanted NAT address:

```powershell
Remove-DnsServerResourceRecord `
    -ZoneName "corp.example.test" `
    -Name "dc01" `
    -RRType "A" `
    -RecordData "10.0.2.15"
```

Verified that only the correct internal address remained.

Checked DNS registration settings:

```powershell
Get-DnsClient |
    Select-Object InterfaceAlias, RegisterThisConnectionsAddress
```

Confirmed:

| Adapter | DNS Registration |
|---|---|
| Ethernet (NAT) | False |
| Ethernet 2 (AD-LAB) | True |

Cleared the DNS server cache:

```powershell
Clear-DnsServerCache -Force
```

Repeated the DNS lookup from WIN11-CLIENT01.

**Final result:**

```text
dc01.corp.example.test    A    192.168.100.10
```

**Follow-up:** The unwanted NAT record had reappeared after being removed in an earlier lab. Although the record was removed again and normal adapter registration settings were correct, the exact source of its re-registration was not established. Further investigation may be required if it returns.

## 7. Active Directory DNS Discovery

Verified the LDAP service location record:

```powershell
Resolve-DnsName `
    -Name "_ldap._tcp.dc._msdcs.corp.example.test" `
    -Type SRV `
    -Server 192.168.100.10
```

Confirmed:

| Property | Result |
|---|---|
| Service | LDAP |
| Domain controller | dc01.corp.example.test |
| Port | 389 |
| IPv4 address | 192.168.100.10 |

Also tested DNS resolution without specifying a DNS server:

```powershell
Resolve-DnsName -Name "dc01.corp.example.test" -Type A
```

The workstation successfully resolved DC01 to `192.168.100.10`.

## 8. Active Directory Domain Join

Joined the Windows 11 workstation to the domain using an authorized domain account:

```powershell
Add-Computer `
    -DomainName "corp.example.test" `
    -Credential "CORP\Administrator" `
    -Restart
```

The domain join completed successfully, and the workstation restarted.

Verified domain membership:

```powershell
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name, Domain, PartOfDomain
```

**Result:**

```text
Name           Domain            PartOfDomain
----           ------            ------------
WIN11-CLIENT01 corp.example.test         True
```

## 9. Domain Controller Discovery

Executed:

```powershell
nltest /dsgetdc:corp.example.test
```

Confirmed that the workstation discovered:

```text
DC:          \\DC01.corp.example.test
Address:     \\192.168.100.10
Dom Name:    corp.example.test
Forest Name: corp.example.test
```

The domain controller advertised services including:

- LDAP — Lightweight Directory Access Protocol
- KDC — Kerberos Key Distribution Center
- GC — Global Catalog
- DNS — Active Directory DNS services

## 10. Domain Authentication

Signed in to the Windows 11 workstation using an Active Directory account.

Verified the authenticated identity:

```powershell
whoami
```

**Result:**

```text
corp\administratore
```

Verified the DNS domain environment:

```powershell
echo $env:USERDNSDOMAIN
```

**Result:**

```text
CORP.EXAMPLE.TEST
```

These results confirmed successful domain account authentication.

## 11. Active Directory Computer Account Verification

On DC01, queried the workstation's computer object:

```powershell
Get-ADComputer `
    -Identity "WIN11-CLIENT01" `
    -Properties DNSHostName, Enabled |
    Select-Object Name, DNSHostName, Enabled
```

**Result:**

```text
Name           DNSHostName                      Enabled
----           -----------                      -------
WIN11-CLIENT01 WIN11-CLIENT01.corp.example.test True
```

This confirmed that Active Directory contained an enabled computer account for the workstation.

## 12. Results

Successfully completed the following tasks:

- Installed and configured a Windows 11 Pro virtual workstation.
- Configured NAT and isolated internal network adapters.
- Assigned and verified static IPv4 and DNS settings.
- Established network connectivity with a Windows Server domain controller.
- Identified and corrected an unwanted DNS A record.
- Verified Active Directory LDAP service discovery.
- Joined the workstation to the Active Directory domain.
- Authenticated using a domain account.
- Confirmed domain controller discovery and computer account registration.

## 13. Skills Demonstrated

- Windows 11 workstation provisioning
- VirtualBox networking
- TCP/IP and DNS configuration
- PowerShell administration
- DNS record investigation and troubleshooting
- Active Directory Domain Services
- Domain joining and authentication
- Domain controller discovery
- Active Directory computer account verification
- Technical troubleshooting and documentation

## 14. Conclusion

Successfully integrated a Windows 11 Pro workstation into a Windows Server 2025 Active Directory environment.

The workstation was configured with an isolated internal network connection, successfully joined the `corp.example.test` domain, and authenticated using domain credentials.

This lab established the foundation for subsequent exercises involving Active Directory user administration, security groups, organizational units, and domain-based access management.

**Lab Status: Completed**

**Next Lab:** Lab 10 — Active Directory User and Group Administration
