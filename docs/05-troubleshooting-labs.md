# Troubleshooting Journal

## Incident 001 — Windows 11 ARM64 Network Connectivity

**Status:** Open / unresolved

### Symptoms
- Windows OOBE asked to install a network driver.
- `UsbNcm Host Device` initially showed Device Manager Code 10: `This device cannot start. The request failed due to a fatal device hardware error.`
- `ping 1.1.1.1` returned `General failure`.
- `ipconfig` showed no configured Ethernet interface during an earlier troubleshooting attempt.
- `ncpa.cpl` showed an empty Network Connections window during an earlier attempt.
- On the recreated VM, `systeminfo` reports one NIC: `UsbNcm Host Device`, `Connection Name: Ethernet`, `Status: Hardware not present`.

### Actions taken
1. Inspected VirtualBox network configuration.
2. Tried Ethernet over USB (usbnet) and Paravirtualized Network (virtio-net) during earlier troubleshooting.
3. Attempted NAT and considered Bridged mode.
4. Completed Windows OOBE offline.
5. Recreated the VM and captured a fresh system baseline.

### Assessment
The guest has no verified working internet connection. Virtual hardware/driver compatibility is suspected, but root cause is **not confirmed**.

### Next steps
Confirm VirtualBox cable/adapter settings, Device Manager status, and whether Windows exposes a usable Ethernet interface. Test `ipconfig /all`, `ping 1.1.1.1`, and `nslookup microsoft.com` after any change. Record actual results.

### Outcome
Unresolved. See `../incident-reports/INC-001-network-adapter.md`.
