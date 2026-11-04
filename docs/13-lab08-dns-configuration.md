# Lab 08 — DNS Configuration and Verification

## Objective

Configure and troubleshoot DNS services in a Windows Server 2025 Active Directory environment. Verify forward and reverse DNS resolution, correct DNS registration issues, and validate domain controller discovery.

## Lab Environment

| Component | Configuration |
|---|---|
| Virtualization | Oracle VirtualBox 7.2.22 |
| Operating System | Windows Server 2025 Standard Evaluation |
| Server Hostname | DC01 |
| Active Directory Domain | corp.example.test |
| Internal Network | AD-LAB |
| Internal IPv4 Address | 192.168.100.10/24 |
| DNS Server | 192.168.100.10 |
| Forward Lookup Zone | corp.example.test |
| Reverse Lookup Zone | 100.168.192.in-addr.arpa |

## Implementation and Troubleshooting

### 1. Inspect Existing DNS Records

Queried the forward lookup zone using PowerShell:

```powershell
Get-DnsServerResourceRecord -ZoneName "corp.example.test" -Name "dc01" -RRType "A" |
    Select-Object HostName, RecordType, @{Name="IPv4Address";Expression={$_.RecordData.IPv4Address.IPAddressToString}}
```

**Initial findings:**

| Hostname | Record Type | IPv4 Address |
|---|---|---|
| dc01 | A | 192.168.100.10 |
| dc01 | A | 10.0.2.15 |

The server had registered both its internal Active Directory address and its VirtualBox NAT address.

The NAT address was unsuitable for domain controller discovery by clients on the internal lab network.

### 2. Correct DNS Registration

Disabled DNS registration on the NAT adapter during Lab 07:

```powershell
Set-DnsClient -InterfaceAlias "Ethernet" -RegisterThisConnectionsAddress $false
```

Verified the adapter configuration:

| Adapter | DNS Registration |
|---|---|
| Ethernet (NAT) | False |
| Ethernet 2 (AD-LAB) | True |

Removed the unwanted NAT address from the forward lookup zone:

```powershell
Remove-DnsServerResourceRecord `
    -ZoneName "corp.example.test" `
    -Name "dc01" `
    -RRType "A" `
    -RecordData "10.0.2.15"
```

Confirmed that the remaining A record was:

`dc01.corp.example.test → 192.168.100.10`

### 3. Verify Forward DNS Resolution

Executed:

```powershell
Resolve-DnsName -Name "dc01.corp.example.test" -Type A -Server 192.168.100.10
```

The initial lookup still returned both IPv4 addresses.

Cleared the DNS server cache:

```powershell
Clear-DnsServerCache -Force
```

Repeated the lookup:

```powershell
Resolve-DnsName -Name "dc01.corp.example.test" -Type A -Server 192.168.100.10 -DnsOnly
```

**Verified result:**

```text
Name                    Type TTL  Section IPAddress
----                    ---- ---  ------- ---------
dc01.corp.example.test  A    1200 Answer  192.168.100.10
```

**Result:** Forward DNS resolution succeeded, returning only the intended internal IPv4 address.

### 4. Configure Reverse Lookup Zone

Opened DNS Manager and created a new reverse lookup zone with the following settings:

| Setting | Configuration |
|---|---|
| Zone Type | Primary |
| Storage | Active Directory-integrated |
| Replication Scope | All DNS servers on domain controllers in corp.example.test |
| IP Version | IPv4 |
| Network ID | 192.168.100 |
| Zone Name | 100.168.192.in-addr.arpa |
| Dynamic Updates | Secure only |

The reverse lookup zone was created successfully.

### 5. Create and Verify PTR Record

Created a Pointer (PTR) record in DNS Manager.

| Property | Value |
|---|---|
| IP Address | 192.168.100.10 |
| Hostname | dc01.corp.example.test |
| Record Type | PTR |

Verified reverse DNS resolution:

```powershell
Resolve-DnsName -Name "192.168.100.10" -Type PTR -Server 192.168.100.10
```

**Verified output:**

```text
Name                          Type TTL  Section NameHost
----                          ---- ---  ------- --------
10.100.168.192.in-addr.arpa   PTR  3600 Answer  dc01.corp.example.test
```

**Result:** Reverse DNS resolution succeeded.

### 6. Verify Active Directory Domain Controller Discovery

Queried the DNS SRV record used for domain controller discovery:

```powershell
Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.corp.example.test" -Type SRV -Server 192.168.100.10 -DnsOnly |
    Where-Object Type -eq "SRV" |
    Select-Object Name, Type, NameTarget, Port
```

**Verified result:**

```text
Name                                   Type NameTarget             Port
----                                   ---- ----------             ----
_ldap._tcp.dc._msdcs.corp.example.test SRV  dc01.corp.example.test  389
```

**Result:** DNS successfully advertised DC01 as a domain controller providing LDAP services.

## Troubleshooting Summary

**Issue:** Incorrect DNS registration on a multi-homed domain controller.

**Symptoms:**
- Multiple A records existed for DC01.
- DNS returned both internal and NAT IPv4 addresses.
- The NAT address could cause connectivity problems for future domain-joined clients.

**Corrective Actions:**
1. Disabled DNS registration on the NAT adapter.
2. Removed the unwanted NAT A record.
3. Cleared the DNS server cache.
4. Repeated forward DNS resolution tests.

**Resolution:** DNS queries returned the correct internal IPv4 address, `192.168.100.10`.

## Verification Results

| Test | Result |
|---|---|
| Inspect forward DNS records | Passed |
| Remove incorrect NAT record | Passed |
| Forward DNS resolution | Passed |
| Reverse lookup zone creation | Passed |
| PTR record verification | Passed |
| Active Directory SRV record verification | Passed |

**Lab Status: Complete**

## Skills Demonstrated

- Windows Server DNS administration
- Active Directory-integrated DNS configuration
- Forward and reverse lookup zones
- DNS A, PTR, and SRV record management
- PowerShell troubleshooting
- DNS cache management
- Network adapter DNS registration
- Domain controller discovery verification
- Technical incident documentation

## Next Lab

**Lab 09 — Windows 11 Domain Join**

Configure a Windows 11 client on the internal AD-LAB network, verify connectivity with DC01, and join the workstation to the corp.example.test domain.