Here is the incident report formatted exactly according to your template.

***

# Incident: Intel I219-V Network Interface "Hardware Unit Hang"

## Date
2026-01-17

## Context
- **System / component:** Proxmox VE Host (PVE) running on ASRock B560M Pro4 hardware.
- **Scope:** Primary network interface (`nic1` / Intel I219-V), affecting the host and all hosted VMs/LXC containers.
- **Brief description of the state before the incident:** The system was undergoing a platform migration. The onboard NIC (Intel I219-V rev 11) utilizes the standard `e1000e` kernel driver.

## Symptoms
- **What exactly stopped working:** Intermittent loss of network connectivity ("flapping"). VMs and containers became unreachable from the LAN.
- **Log excerpts:** System logs (`dmesg` / `syslog`) repeatedly showed the critical driver error:
  ```text
  e1000e 0000:00:1f.6 nic1: Detected Hardware Unit Hang
  e1000e 0000:00:1f.6 nic1: Reset adapter unexpectedly
  ```
- **Frequency:** Intermittent, often triggered by network load or interrupt spikes.

## Initial hypothesis
- **Root cause:** A known "race condition" between the Linux `e1000e` driver and the aggressive power management features (ASPM, EEE) inherent to the Intel B560 chipset.
- **Dependencies:** The issue is tied to the PVE Kernel version and motherboard chipset settings (BIOS).

## Actions taken (attempts)
1.  **Hardware Identification:** Verified NIC model via `lspci -nn` to confirm it was I219-V (rev 11) and not the physically defective I225-V.
2.  **Driver Configuration:** Attempted to disable Energy Efficient Ethernet (EEE) via `ethtool` runtime commands (insufficient persistence).
3.  **BIOS Adjustment:** Located specific power-saving settings in the ASRock UEFI (Chipset and Network configuration sections).

## Current status (if not yet resolved)
- *Resolved (see below).*

## Final fix (when resolved)

### Change summary
A three-layer configuration change was applied to permanently disable power-saving features that cause the hardware hang:

1.  **Driver Level (`/etc/modprobe.d/e1000e.conf`):**
    - Created config to force specific driver options on boot:
    ```bash
    options e1000e EEE=0 InterruptThrottleRate=3000
    ```
    - Regenerated initramfs (`update-initramfs -u`).

2.  **Kernel Level (`/etc/default/grub`):**
    - Added boot parameter to disable PCIe Active State Power Management:
    ```bash
    GRUB_CMDLINE_LINUX_DEFAULT="quiet pcie_aspm=off"
    ```
    - Updated bootloader (`update-grub`).

3.  **BIOS/UEFI Level:** (to consider in case of any further issues)
    - Disable **PCI Express ASPM** (Advanced \> Chipset).
    - Disable **Energy Efficient Ethernet** (Advanced \> Network).
    - Disable **CPU C-States** (Advanced \> CPU Configuration).
    - Disable **VT-d** (Hardware passthrough not required for this node).

### Verification
- **Commands executed:**
  - `update-initramfs -u` and `update-grub` to apply software changes.
  - Full system `reboot`.
  - `dmesg | grep -i e1000e` checked post-boot.
- **Results:**
  - No "Hardware Unit Hang" messages appeared in the kernel ring buffer.
  - Network connectivity remained stable under load test.

### Outcome
- **Final status:** **Resolved**.
- **Remaining risks:** Major Proxmox Kernel updates might revert or alter driver behavior. If symptoms return, a dedicated PCIe NIC (Intel i210/i350 or Realtek RTL8125) will be installed as a hardware workaround.