# Windows IT Service Desk Home Lab

A hands-on IT Service Desk portfolio project demonstrating Windows 11 administration, troubleshooting, user account management, NTFS permissions, network diagnostics, and ITIL-aligned incident documentation.

The project uses a virtualized Windows environment to simulate common IT support scenarios, investigate technical issues, implement solutions, and document verified results.

## Lab Environment

| Component | Configuration |
|---|---|
| Host | Apple M1 MacBook, macOS Sonoma 14.8.2 |
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Virtual Machine | WIN11-CLIENT01 |
| Windows Hostname | DESKTOP-0200R7P |
| Operating System | Windows 11 Pro ARM64 |
| VM Resources | 2 vCPUs, 4 GB RAM, 80 GB virtual disk |
| Network Configuration | NAT with VirtIO network adapter |
| Network Driver | Red Hat VirtIO Ethernet Adapter (NetKVM) |

## Project Progress

**5 of 5 practical labs completed.**

| Lab | Description | Status |
|---|---|---|
| [Lab 01](docs/06-lab01-system-diagnostics.md) | Windows System Diagnostics | Completed |
| [Lab 02](docs/07-lab02-user-account-administration.md) | Local User Account Administration | Completed |
| [Lab 03](docs/08-lab03-file-permissions.md) | File Permissions and Access Control | Completed |
| [Lab 04](docs/09-lab04-windows-services.md) | Windows Services and Event Viewer | Completed |
| [Lab 05](docs/10-lab05-network-troubleshooting.md) | Network Connectivity and DNS Troubleshooting | Completed |

## Completed Labs

### Lab 01 — Windows System Diagnostics

Collected operating system information, identified the computer hostname and current user, and examined Windows services and network configuration.

**Tools:** `winver`, `systeminfo`, `hostname`, `whoami`, PowerShell, Services.

[View Lab 01 Documentation](docs/06-lab01-system-diagnostics.md)

### Lab 02 — Local User Account Administration

Simulated employee onboarding by creating a standard Windows user account, verifying security group membership, testing sign-in, and confirming User Account Control restrictions.

**Skills:** User provisioning, local security groups, least privilege, UAC.

[View Lab 02 Documentation](docs/07-lab02-user-account-administration.md)

### Lab 03 — File Permissions and Access Control

Investigated a simulated Access Denied incident involving departmental files. Inspected NTFS permissions and inheritance, applied read-only access using `icacls`, and verified that unauthorized modifications were restricted.

**Skills:** NTFS permissions, ACLs, inheritance, access troubleshooting, least privilege.

[View Lab 03 Documentation](docs/08-lab03-file-permissions.md)

### Lab 04 — Windows Services and Event Viewer

Simulated a Windows Search service interruption, investigated service status and relevant Service Control Manager events, and restored the service.

**Skills:** Windows Services, Event Viewer, service recovery, incident troubleshooting.

[View Lab 04 Documentation](docs/09-lab04-windows-services.md)

### Lab 05 — Network Connectivity and DNS Troubleshooting

Investigated a real network connectivity failure affecting the Windows 11 ARM64 virtual machine.

Identified a USB NCM adapter failure (Code 10), tested VirtualBox network configurations, and diagnosed a missing VirtIO network driver (Code 28).

Installed a compatible ARM64 NetKVM driver and verified successful network connectivity and DNS resolution using PowerShell.

**Skills:** Network diagnostics, driver troubleshooting, VirtualBox networking, TCP/IP, DNS, PowerShell.

[View Lab 05 Documentation](docs/10-lab05-network-troubleshooting.md)

## Incident and Service Request Tracking

| ID | Type | Description | Status |
|---|---|---|---|
| [INC-001](incident-reports/INC-001-network-adapter.md) | Incident | Windows network adapter connectivity failure | Resolved |
| [SR-002](incident-reports/SR-002-user-provisioning.md) | Service Request | Standard user account provisioning | Resolved |
| [INC-003](incident-reports/INC-003-folder-access-denied.md) | Incident | Department folder access denied | Resolved |
| [INC-004](incident-reports/INC-004-windows-search-service.md) | Incident | Windows Search service interruption | Resolved |

Each report documents the issue, investigation, corrective action, and verification.

## Repository Structure

```text
windows-service-desk-lab/
├── README.md
├── docs/
│   ├── 01-lab-planning.md
│   ├── 02-virtual-machine-setup.md
│   ├── 03-windows-installation.md
│   ├── 04-windows-configuration.md
│   ├── 05-troubleshooting-labs.md
│   ├── 06-lab01-system-diagnostics.md
│   ├── 07-lab02-user-account-administration.md
│   ├── 08-lab03-file-permissions.md
│   ├── 09-lab04-windows-services.md
│   └── 10-lab05-network-troubleshooting.md
├── incident-reports/
│   ├── INC-001-network-adapter.md
│   ├── SR-002-user-provisioning.md
│   ├── INC-003-folder-access-denied.md
│   └── INC-004-windows-search-service.md
└── screenshots/
    ├── lab01/
    ├── lab02/
    ├── lab03/
    ├── lab04/
    └── lab05/
```

## Technical Skills Demonstrated

- **Windows Administration:** System diagnostics, local users, security groups, and Windows Services.
- **Identity and Access Management:** User provisioning, access restrictions, and least-privilege permissions.
- **File System Security:** NTFS permissions, ACL inheritance, and `icacls`.
- **Network Troubleshooting:** Virtual adapters, driver errors, TCP/IP connectivity, and DNS resolution.
- **Technical Tools:** PowerShell, Command Prompt, Device Manager, Event Viewer, and VirtualBox.
- **IT Service Management:** Incident investigation, service requests, troubleshooting documentation, and resolution verification.

## Documentation and Security

This is a personal learning environment. User identities and support scenarios are simulated unless explicitly identified as actual lab issues.

Passwords, private IP addresses, sensitive network configuration, and personal credentials are excluded from published documentation.

All troubleshooting results are supported by lab evidence and screenshots.

## Project Status

**Phase 1 — Windows 11 Service Desk Fundamentals: Completed**

Five practical labs and four incident/service request records have been completed.

Future expansion may include Windows Server, Active Directory, Group Policy, and enterprise identity administration.
