# Lab 01 — Windows System Diagnostics

**Status: Completed** (network issue documented separately)

## Objective
Identify and document the operating system, computer identity, hardware allocation, logged-in account, services, and observed issues using built-in Windows tools.

## Environment
- Hypervisor: Oracle VirtualBox on Apple M1 MacBook
- VM: WIN11-CLIENT01
- Guest: Windows 11 Pro 26H2, build 26300.9457
- Architecture: ARM64; 2 virtual CPUs; 4096 MB allocated RAM; 80 GB virtual disk

## Commands and findings

| Tool | Verified finding |
|---|---|
| `winver` | Windows 11 Pro, version 26H2, OS build 26300.9457 |
| `hostname` | `DESKTOP-0200R7P` |
| `whoami` | `desktop-0200r7p\labadmin_01` |
| `systeminfo` | Manufacturer ORCL; model VBOXSDT; ARM64-based PC |
| `systeminfo` | Physical memory 4,089 MB; available memory 1,659 MB at capture |
| `systeminfo` | WORKGROUP; Eastern Time (US & Canada) |
| `systeminfo` | Four installed hotfixes: KB5126052, KB5121794, KB5129195, KB5124007 |
| `systeminfo` | UsbNcm Host Device, Ethernet, `Hardware not present` |

## Services inspection
| Service | Observed status | Startup type |
|---|---|---|
| Windows Event Log | Running | Automatic |
| Windows Update | Not running | Manual |

No service configurations were changed during the inspection.

## Outcome
Successfully identified OS and VM properties, local user, domain membership, and service configuration. The network adapter issue remains open in Incident 001.

## Evidence
- `../screenshots/virtualbox-manager-config.png`
- `../screenshots/lab01-windows-version.png`
- `../screenshots/lab01-systeminfo-01.png`
- `../screenshots/lab01-systeminfo-02.png`
- `../screenshots/lab01-systeminfo-03.png`
- `../screenshots/lab01-windows-event-log.png`
- `../screenshots/lab01-windows-update.png`

## Skills demonstrated
Windows administration, command-line diagnostics, system inventory, Windows Services inspection, evidence collection, and issue documentation.
