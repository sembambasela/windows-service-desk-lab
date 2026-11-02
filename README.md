# Windows IT Service Desk Home Lab

A hands-on IT Service Desk portfolio project demonstrating practical experience in **Windows 11 administration, Identity and Access Management (IAM), NTFS file permissions, system diagnostics, and incident troubleshooting**.

The project simulates real-world IT support scenarios using a Windows 11 Pro virtual machine running in Oracle VirtualBox.

Each lab follows a structured Service Desk workflow: identifying an issue or request, investigating the environment, implementing a solution, verifying the results, and documenting the outcome.

## Lab Environment

| Component | Configuration |
|---|---|
| Host Machine | Apple M1 MacBook |
| Host Operating System | macOS Sonoma 14.8.2 |
| Hypervisor | Oracle VirtualBox |
| Virtual Machine | WIN11-CLIENT01 |
| Windows Hostname | DESKTOP-0200R7P |
| Guest Operating System | Windows 11 Pro ARM64, 26H2 |
| Memory | 4 GB |
| Processors | 2 vCPUs |
| Storage | 80 GB |
| Security | TPM 2.0, EFI, Secure Boot |
| Administrative Account | LabAdmin_01 |
| Standard User Account | jdoe |

## Project Progress

| Lab | Description | Status |
|---|---|---|
| Environment Setup | Windows 11 VM installation and configuration | Completed |
| Lab 01 | Windows System Diagnostics | Completed |
| Lab 02 | Local User Account Administration | Completed |
| Lab 03 | Windows File Permissions and Access Control | Completed |
| Lab 04 | Windows Services and Event Viewer Troubleshooting | Planned |
| Lab 05 | Network Connectivity and DNS Troubleshooting | Planned |

## Completed Labs

### Lab 01 — Windows System Diagnostics

**Objective:** Inspect and document the configuration and operational status of a Windows 11 workstation.

Activities completed:
- Verified Windows version and build information using `winver`.
- Identified the workstation hostname using `hostname`.
- Collected operating system and hardware information using `systeminfo`.
- Verified the current user identity using `whoami`.
- Inspected Windows services using `services.msc`.
- Identified a network adapter connectivity issue for further troubleshooting.

**Skills demonstrated:** Windows diagnostics, system administration, service inspection, command-line troubleshooting, technical documentation.

[View Lab 01 Documentation](docs/06-lab01-system-diagnostics.md)

### Lab 02 — Local User Account Administration

**Service Request:** SR-002 — New Employee Account Provisioning

**Objective:** Provision a standard Windows user account and verify appropriate access restrictions.

Activities completed:
- Created local user account `jdoe` for simulated employee Jordan Doe.
- Verified membership in the local Users group.
- Confirmed that the account was not a member of Administrators.
- Successfully tested interactive Windows sign-in.
- Verified account identity using `whoami`.
- Inspected security group memberships using `whoami /groups`.
- Confirmed that User Account Control required administrator credentials for elevated access.

**Outcome:** Successfully provisioned a standard user account following the principle of least privilege.

**Skills demonstrated:** IAM, user provisioning, Windows security groups, access verification, UAC, service request documentation.

[View Lab 02 Documentation](docs/07-lab02-user-account-administration.md)

### Lab 03 — Windows File Permissions and Access Control

**Incident:** INC-003 — Department Folder Access Denied

**Objective:** Diagnose and resolve an NTFS permissions issue affecting an employee's access to departmental files.

Activities completed:
- Created a test departmental folder at `C:\DepartmentFiles`.
- Created a sample department policy document.
- Inspected NTFS permissions and inheritance using Windows Advanced Security Settings.
- Identified inherited Modify permissions assigned to Authenticated Users.
- Configured restricted folder access to simulate an Access Denied incident.
- Reproduced the access issue using the standard user account `jdoe`.
- Investigated folder-level and file-level permissions using `icacls`.
- Encountered and investigated an error when applying security changes.
- Configured read-only access while preserving administrator and SYSTEM permissions.
- Verified that the employee could read the policy document but could not save unauthorized modifications.

**Key commands:**

```cmd
icacls "C:\DepartmentFiles"
icacls "C:\DepartmentFiles\DepartmentPolicy.txt"
icacls "C:\DepartmentFiles\DepartmentPolicy.txt" /grant "jdoe:(R)"
```

**Outcome:** Restored appropriate read-only access while maintaining the principle of least privilege.

**Skills demonstrated:** NTFS permissions, access control lists (ACLs), permission inheritance, `icacls`, Windows security troubleshooting, incident resolution.

[View Lab 03 Documentation](docs/08-lab03-file-permissions.md)

## Incident and Service Request Tracking

| Ticket | Type | Description | Status |
|---|---|---|---|
| INC-001 | Incident | Windows network adapter connectivity issue | Open |
| SR-002 | Service Request | New employee account provisioning | Resolved |
| INC-003 | Incident | Department folder access denied | Resolved |

## Technical Skills Demonstrated

**Windows Administration**
- Windows 11 installation and configuration
- Local user and group management
- Windows service inspection
- System diagnostics and troubleshooting

**Identity and Access Management**
- User account provisioning
- Security group verification
- Least-privilege access
- User Account Control

**File System Security**
- NTFS permissions
- Access control lists
- Permission inheritance
- Read-only access configuration
- File access troubleshooting

**IT Service Management**
- Incident investigation
- Service request fulfillment
- Root cause analysis
- Resolution verification
- Technical documentation

**Tools and Technologies**

`Windows 11` · `VirtualBox` · `Command Prompt` · `Computer Management` · `Event Viewer` (planned) · `icacls` · `Git` · `GitHub`

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
│   └── 08-lab03-file-permissions.md
├── incident-reports/
│   ├── INC-001-network-adapter.md
│   ├── SR-002-user-provisioning.md
│   └── INC-003-folder-access-denied.md
└── screenshots/
    ├── lab03/
    │   ├── lab03-01-department-folder.png
    │   ├── lab03-02-initial-file-permissions.png
    │   ├── lab03-03-initial-folder-permissions.png
    │   ├── lab03-04-permission-inheritance.png
    │   ├── lab03-05-access-denied.png
    │   ├── lab03-06-permission-configuration-error.png
    │   ├── lab03-07-updated-ntfs-permissions.png
    │   ├── lab03-08-icacls-investigation.png
    │   ├── lab03-09-icacls-permission-fix.png
    │   └── lab03-10-read-only-verification.png
    └── [Lab 01 and Lab 02 evidence]
```

## Next Steps

### Lab 04 — Windows Services and Event Viewer Troubleshooting

Simulate a Windows service failure, investigate the issue using Event Viewer and Services, restore service functionality, and document the resolution.

### Lab 05 — Network Connectivity and DNS Troubleshooting

Investigate Windows network configuration, IP addressing, DNS resolution, and connectivity issues using built-in diagnostic commands.

## Security and Documentation

All activities are performed in a controlled learning environment using simulated employee accounts and test resources.

No real employee credentials, passwords, or confidential organizational information are stored in this repository.

Screenshots, command outputs, and incident reports are maintained as evidence of completed troubleshooting activities.