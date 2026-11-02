# INC-001 — Network Adapter Not Working

**Type:** Incident  
**System:** WIN11-CLIENT01 / DESKTOP-0200R7P  
**Status:** Open  
**Impact:** VM cannot access network; Windows installation was completed offline.

## Symptoms
- Windows OOBE requested a network driver.
- USB network device previously reported Code 10.
- Connectivity tests failed.
- Current `systeminfo`: `UsbNcm Host Device`, Ethernet, `Hardware not present`.

## Troubleshooting
VirtualBox adapter settings reviewed; USB Ethernet and virtio-net options investigated; VM reinstalled for a clean baseline.

## Resolution
Not resolved. Do not mark ticket closed until a working interface, IP address, internet routing, and DNS have been verified.
