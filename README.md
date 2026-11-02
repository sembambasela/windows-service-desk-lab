# Windows IT Service Desk Home Lab

A hands-on IT Service Desk portfolio project focused on Windows 11 administration, troubleshooting, Identity and Access Management (IAM), and IT service request documentation.

The project simulates real-world IT support scenarios using a Windows 11 Pro virtual machine running in Oracle VirtualBox.

## Lab Environment

| Component | Configuration |
|---|---|
| Host | Apple M1 MacBook, macOS Sonoma 14.8.2 |
| Hypervisor | Oracle VirtualBox |
| Virtual Machine | WIN11-CLIENT01 |
| Windows Hostname | DESKTOP-0200R7P |
| Operating System | Windows 11 Pro ARM64, 26H2 |
| Memory | 4 GB |
| Processors | 2 vCPUs |
| Storage | 80 GB |
| Security | TPM 2.0, EFI, Secure Boot |

## Project Progress

| Lab / Activity | Status |
|---|---|
| Windows 11 VM Setup and Installation | Completed |
| Lab 01 — Windows System Diagnostics | Completed |
| Lab 02 — Local User Account Administration | Completed |
| Lab 03 — File Permissions and Access Control | Planned |
| INC-001 — Network Connectivity Troubleshooting | Open |

## Completed Labs

### Lab 01 — Windows System Diagnostics

Performed baseline Windows workstation diagnostics using built-in administration tools.

**Skills demonstrated:**
- Windows system information gathering
- Command Prompt diagnostics
- Windows service inspection
- Operating system verification
- Technical documentation

[View Lab 01 Documentation](docs/06-lab01-system-diagnostics.md)

### Lab 02 — Local User Account Administration

Simulated a new employee onboarding request by provisioning and verifying a standard Windows user account.

**Activities completed:**
- Created local employee account `jdoe`
- Verified membership in the Users security group
- Confirmed absence of administrator group membership
- Successfully tested account sign-in
- Verified account identity using `whoami`
- Inspected security groups using `whoami /groups`
- Confirmed UAC required administrator credentials for elevation
- Documented service request SR-002

**Skills demonstrated:**
- Identity and Access Management (IAM)
- Windows user provisioning
- Local security group administration
- Principle of least privilege
- User Account Control (UAC)
- Service request resolution

[View Lab 02 Documentation](docs/07-lab02-user-account-administration.md)

## Incident and Service Request Tracking

| Ticket | Description | Status |
|---|---|---|
| INC-001 | Windows network adapter connectivity issue | Open |
| SR-002 | New employee account provisioning | Resolved |

The network connectivity issue remains unresolved and is documented separately.

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
│   └── 07-lab02-user-account-administration.md
├── incident-reports/
│   ├── INC-001-network-adapter.md
│   └── SR-002-user-provisioning.md
└── screenshots/
```

## Next Steps

**Lab 03 — File Permissions and Access Control**

Simulate file access requests and troubleshoot NTFS permission issues using standard Windows user accounts.

## Security Considerations

All activities are performed in an isolated learning environment. No real employee credentials, passwords, or sensitive organizational information are included in this repository.