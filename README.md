# Windows IT Service Desk Home Lab

A hands-on Windows 11 ARM64 service desk portfolio project, using Oracle VirtualBox on an Apple M1 MacBook. Exercises cover workstation diagnostics, account provisioning, troubleshooting, and evidence-based ticket documentation.

## Lab environment

- Host: Apple M1 MacBook, macOS Sonoma 14.8.2, 8 GB unified RAM
- Hypervisor: Oracle VirtualBox
- VM name: `WIN11-CLIENT01` (VirtualBox); Windows hostname: `DESKTOP-0200R7P`
- Guest: Windows 11 Pro ARM64, version 26H2, build 26300.9457
- VM resources: 2 virtual CPUs, 4096 MB RAM, 80 GB virtual disk
- EFI / Secure Boot enabled, TPM 2.0
- Network: USB Ethernet adapter via NAT; **connectivity not working at last verification**

## Progress

| Activity | Status |
|---|---|
| VM setup and Windows installation | Completed |
| Lab 01 — Windows System Diagnostics | Completed |
| Incident 001 — Network connectivity | Open |
| Lab 02 — Local User Account Administration | Planned / instructions prepared |

## Repository guide

- `docs/01-lab-planning.md` — goals and lab scope
- `docs/02-virtual-machine-setup.md` — virtual machine configuration
- `docs/03-windows-installation.md` — Windows installation and offline OOBE
- `docs/04-windows-configuration.md` — baseline Windows configuration
- `docs/05-troubleshooting-labs.md` — incident troubleshooting journal
- `docs/06-lab01-system-diagnostics.md` — completed diagnostic lab
- `docs/07-lab02-user-account-administration.md` — user provisioning exercise (pending execution)
- `incident-reports/INC-001-network-adapter.md` — network incident record
- `incident-reports/SR-002-user-provisioning.md` — account provisioning service request
- `screenshots/` — evidence captured during Lab 01

## Safety and accuracy

This is a personal lab, not a production environment. No passwords, license keys, or personal credentials should be committed. Findings marked pending or unresolved have not been verified as successful.
