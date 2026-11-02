# Virtual Machine Setup

## Host
- Apple M1 MacBook, macOS Sonoma 14.8.2, 8 GB unified memory
- Hypervisor: Oracle VirtualBox

## Current VM configuration (verified from screenshots)
- VM: `WIN11-CLIENT01`
- Guest type: Windows 11 on ARM (64-bit)
- Base memory: 4096 MB
- CPUs: 2
- Virtual disk: `WIN11-CLIENT01.vdi`, 80 GB
- EFI: Enabled
- Secure Boot: Enabled
- TPM: 2.0
- Network: Ethernet over USB, NAT
- ISO: `Windows11_Client_arm64_en-us_26300_9457.iso`

## Boot process
The first boot displayed the UEFI firmware menu. Boot Manager was used to boot the optical installation media and launch Windows Setup.

## Evidence
- `../screenshots/virtualbox-uefi-boot.png`
- `../screenshots/virtualbox-manager-config.png`

## Notes
The VM was recreated after earlier network driver troubleshooting. The current VM configuration and successful OS installation are confirmed; internet access is not.
