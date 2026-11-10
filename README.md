
# Windows IT Service Desk Home Lab

A hands-on IT Service Desk portfolio project demonstrating Windows 11 administration, Windows Server, Active Directory Domain Services (AD DS), DNS, Group Policy, identity and access management, network troubleshooting, remote support, Windows Update management, and ITIL-aligned service desk documentation.

The project uses virtualized Windows environments to simulate common enterprise IT support scenarios, investigate technical issues, implement solutions, and document verified results.

## Lab Environment

This project has used two virtualized lab environments.

### Environment 1 — Windows 11 Fundamentals

| Component | Configuration |
|---|---|
| Host | Apple M1 MacBook, macOS Sonoma 14.8.2 |
| Hypervisor | Oracle VirtualBox 7.2.22 |
| Operating System | Windows 11 Pro ARM64 |
| VM Resources | 2 vCPUs, 4 GB RAM, 80 GB virtual disk |
| Networking | VirtualBox NAT |
| Network Driver | Red Hat VirtIO Ethernet Adapter (NetKVM) |

This environment supported the initial Windows administration and troubleshooting labs.

### Environment 2 — Windows Server and Active Directory

| Component | Configuration |
|---|---|
| Host | Windows 10 PC, AMD Ryzen 7 9700X |
| Host RAM | 32 GB |
| Hypervisor | Oracle VirtualBox |
| Domain Controller | DC01 |
| Server OS | Windows Server 2025 Standard Evaluation |
| Domain | corp.example.test |
| NetBIOS Domain | CORP |
| Client | WIN11-CLIENT01 |
| Client OS | Windows 11 Pro |
| Networking | NAT and Internal Network (AD-LAB) |
| Domain Services | AD DS, DNS, Group Policy |

This environment supports enterprise-style domain administration, client troubleshooting, remote support, and patch management.

## Project Progress

**20 practical labs completed through Lab 21, with original lab numbering retained.**

The project roadmap was consolidated into 21 practical labs. Original lab identifiers are preserved for consistency with existing documentation.

### Phase 1 — Windows 11 Service Desk Fundamentals

| Lab | Description | Status |
|---|---|---|
| [Lab 01](docs/06-lab01-system-diagnostics.md) | Windows System Diagnostics | Completed |
| [Lab 02](docs/07-lab02-user-account-administration.md) | Local User Account Administration | Completed |
| [Lab 03](docs/08-lab03-file-permissions.md) | File Permissions and Access Control | Completed |
| [Lab 04](docs/09-lab04-windows-services.md) | Windows Services and Event Viewer | Completed |
| [Lab 05](docs/10-lab05-network-troubleshooting.md) | Network Connectivity and DNS Troubleshooting | Completed |

### Phase 2 — Windows Server and Enterprise Administration

| Lab | Description | Status |
|---|---|---|
| Lab 06 | Windows Server Installation and Configuration | Completed |
| Lab 07 | Active Directory Domain Services and DNS | Completed |
| Lab 08 | DNS Reverse Lookup and PTR Records | Completed |
| Lab 09 | Windows 11 Domain Join | Completed |
| Lab 10 | Active Directory User and Group Administration | Completed |
| Lab 11 | Group Policy Management | Completed |
| Lab 12 | Domain File Sharing and NTFS Permissions | Completed |
| Lab 13 | Active Directory Account and Access Management | Completed |
| Lab 14 | Windows Enterprise Administration | Completed |
| Lab 15 | Windows Troubleshooting and Administration | Completed |

### Phase 3 — Advanced Service Desk Troubleshooting

| Lab | Description | Status |
|---|---|---|
| Lab 16 | Windows Service Troubleshooting | Completed |
| Lab 17 | Domain Login and User Profile Troubleshooting | Completed |
| [Lab 18](docs/18-lab18-group-policy-troubleshooting.md) | Group Policy Troubleshooting | Completed |
| Lab 20 | Remote Desktop and Remote Support | Completed |
| [Lab 21](docs/21-lab21-windows-update-patch-management.md) | Windows Update and Patch Management | Completed |

**Next priority: Lab 26 — Service Desk Ticketing and SLA Management**

## Completed Lab Highlights

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

Investigated network connectivity problems affecting the original Windows 11 ARM64 virtual machine.

Diagnosed USB NCM adapter and driver issues, investigated VirtualBox networking configurations, and performed network connectivity and DNS troubleshooting.

**Skills:** Network diagnostics, driver troubleshooting, VirtualBox networking, TCP/IP, DNS, PowerShell.

[View Lab 05 Documentation](docs/10-lab05-network-troubleshooting.md)

### Lab 06–09 — Enterprise Infrastructure Setup

Deployed Windows Server 2025 and configured the foundation for an Active Directory environment.

Key activities included:

- Installing Windows Server 2025 Standard Evaluation.
- Configuring domain controller DC01.
- Deploying Active Directory Domain Services.
- Creating the `corp.example.test` domain.
- Configuring DNS forward and reverse lookup zones.
- Verifying DNS A, SRV, and PTR records.
- Deploying a Windows 11 client virtual machine.
- Joining WIN11-CLIENT01 to the domain.
- Verifying domain connectivity and authentication.

**Skills:** Windows Server, AD DS, DNS, domain join, PowerShell, enterprise networking.

### Lab 10–15 — Active Directory and Enterprise Administration

Practiced administration and troubleshooting tasks involving domain users, security groups, access control, Group Policy, and Windows enterprise management.

**Skills:** Identity and access management, Active Directory administration, least privilege, Windows troubleshooting, documentation.

### Lab 16 — Windows Service Troubleshooting

Investigated Windows service configuration and operational problems using administrative tools and diagnostic commands.

**Skills:** Windows services, PowerShell, troubleshooting, service recovery.

### Lab 17 — Domain Login and User Profile Troubleshooting

Practiced investigating authentication and user profile issues in a domain environment.

**Skills:** Domain authentication, account troubleshooting, user profiles, Active Directory.

### Lab 18 — Group Policy Troubleshooting

Simulated a workstation Group Policy issue by creating a temporary troubleshooting GPO.

Investigated why the policy was not applying, identified a missing GPO link, corrected the configuration, and verified successful policy application.

Removed the temporary GPO and restored the original workstation configuration.

**Skills:** Group Policy Management, GPO linking, `gpupdate`, `gpresult`, registry verification, root cause analysis, rollback.

[View Lab 18 Documentation](docs/18-lab18-group-policy-troubleshooting.md)

### Lab 20 — Remote Desktop and Remote Support

Practiced Windows remote administration and support in a domain-based lab environment.

**Skills:** Remote Desktop, remote connectivity, Windows administration, support troubleshooting.

### Lab 21 — Windows Update and Patch Management

Investigated Windows Update installation and pending-restart behavior on WIN11-CLIENT01.

Identified a .NET Framework security update (KB5127694) that remained in an `InstallPending` state.

Used PowerShell, DISM, Windows Update services, servicing logs, and Windows Update APIs to investigate the issue.

Performed a controlled restart using Windows Update and verified that the update installed successfully.

Installed the Windows Malicious Software Removal Tool (KB890830) and verified its successful installation.

Confirmed that Windows Update reported zero applicable uninstalled software updates.

**Verified results:**

- KB5127694 successfully installed.
- KB890830 installation returned ResultCode 2.
- Windows Defender security intelligence version verified.
- Pending restart indicators cleared.
- Final Windows Update scan returned zero applicable uninstalled software updates.
- Optional preview update intentionally excluded.

**Skills:** Windows Update, patch management, PowerShell, DISM, Windows servicing, event logs, update troubleshooting, incident resolution.

[View Lab 21 Documentation](docs/21-lab21-windows-update-patch-management.md)

## Incident and Service Request Tracking

| ID | Type | Description | Status |
|---|---|---|---|
| [INC-001](incident-reports/INC-001-network-adapter.md) | Incident | Windows network adapter connectivity failure | See report |
| [SR-002](incident-reports/SR-002-user-provisioning.md) | Service Request | Standard user account provisioning | Resolved |
| [INC-003](incident-reports/INC-003-folder-access-denied.md) | Incident | Department folder access denied | Resolved |
| [INC-004](incident-reports/INC-004-windows-search-service.md) | Incident | Windows Search service interruption | Resolved |
| [INC-018](incident-reports/INC-018-group-policy-not-applying.md) | Incident | Workstation Group Policy not applying | Resolved |
| [INC-021](incident-reports/INC-021-windows-update-pending-restart.md) | Incident | Windows Update pending-restart issue | Resolved |

Additional service requests and incident reports are documented in the `incident-reports/` directory.

Each report records the issue, investigation, corrective actions, verification, and outcome.

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
│   ├── 10-lab05-network-troubleshooting.md
│   ├── ...additional lab documentation...
│   ├── 18-lab18-group-policy-troubleshooting.md
│   └── 21-lab21-windows-update-patch-management.md
├── incident-reports/
│   ├── INC-001-network-adapter.md
│   ├── SR-002-user-provisioning.md
│   ├── INC-003-folder-access-denied.md
│   ├── INC-004-windows-search-service.md
│   ├── ...additional incident and request reports...
│   ├── INC-018-group-policy-not-applying.md
│   └── INC-021-windows-update-pending-restart.md
└── screenshots/
    └── ...lab screenshots...
```

## Technical Skills Demonstrated

### Windows Administration

- Windows 11 and Windows Server 2025
- Operating system diagnostics
- Local and domain user administration
- Windows Services and Event Viewer
- Windows Update and patch management
- PowerShell and Command Prompt

### Identity and Access Management

- Active Directory Domain Services
- User and group administration
- Account provisioning and access management
- Group Policy configuration and troubleshooting
- Least-privilege access controls
- Domain authentication troubleshooting

### Networking and Infrastructure

- VirtualBox networking
- TCP/IP and DNS troubleshooting
- DNS forward and reverse lookup zones
- Domain controller configuration
- Domain join and connectivity verification
- Network adapter and driver troubleshooting

### Remote Support and Troubleshooting

- Remote Desktop
- Windows service troubleshooting
- User profile and login troubleshooting
- Windows Update diagnostics
- DISM and servicing logs
- Incident investigation and root cause analysis

### IT Service Management

- Incident management
- Service request fulfillment
- Troubleshooting documentation
- Resolution verification
- Change and rollback documentation
- ITIL-aligned service desk practices

## Documentation and Security

This is a personal learning environment designed to simulate enterprise IT support activities.

User identities and support scenarios are simulated unless explicitly identified as actual lab issues.

Passwords, credentials, product keys, and sensitive personal information are excluded from published documentation.

All troubleshooting outcomes are documented using observed lab results. Screenshots and diagnostic evidence are reviewed before publication.

## Project Status

**Phase 1 — Windows 11 Service Desk Fundamentals: Completed**

**Phase 2 — Windows Server and Active Directory Administration: Completed**

**Phase 3 — Advanced Service Desk Troubleshooting: In Progress**

The project currently includes completed Windows administration, enterprise infrastructure, identity management, troubleshooting, remote support, and patch management exercises.

### Next Planned Lab

**Lab 26 — Service Desk Ticketing and SLA Management**

The next lab will focus on ticket classification, prioritization, incident and service request lifecycles, SLA tracking, escalation, and resolution documentation.

## Career Relevance

This project demonstrates practical experience relevant to entry-level IT positions, including:

- IT Service Desk Analyst
- Help Desk Technician
- IT Support Technician
- Desktop Support Analyst
- Junior Systems Administrator
- Identity and Access Management Support Analyst

The lab provides documented examples of troubleshooting, system administration, customer support processes, and technical problem resolution in a simulated enterprise environment.
