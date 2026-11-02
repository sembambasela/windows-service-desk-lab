# Windows 11 ARM64 Installation

## Installation media
`Windows11_Client_arm64_en-us_26300_9457.iso`

## Procedure and observations
1. Booted VM using the UEFI Boot Manager and the attached ARM64 ISO.
2. Started Windows 11 Setup and selected Windows 11 Pro.
3. Chose the option to proceed without entering a product key during setup. **Activation/licensing has not been verified.**
4. Installed Windows to the virtual disk.
5. During Out-of-Box Experience (OOBE), Windows requested a network driver and could not establish connectivity.
6. Continued with offline setup using the available `I don't have internet` / `Continue with limited setup` flow.
7. Created a local administrator lab account, `LabAdmin_01`, and reached the Windows desktop.

## Verified installed system
- Windows 11 Pro, version 26H2, build 26300.9457
- ARM64-based PC
- Hostname `DESKTOP-0200R7P`

## Evidence
- `../screenshots/lab01-windows-version.png`

## Open issue
Network adapter detected in diagnostics as `UsbNcm Host Device`, status `Hardware not present`. See Incident 001.
