# PBS Storage Strategy via Virtualized ZFS

## Context
Attached a 1TB SSD to the Proxmox Backup Server VM for storing backups. The options were:
1. **PCI/Disk Passthrough:** Giving the VM direct control over the physical device.
2. **Virtualized Disk (Zvol):** Creating a ZFS volume on the host and attaching it as a virtual disk.

## Decision
**Option 2 (Virtualized Disk)** with a size limit of 800 GiB.

## Rationale
1. **Flexibility:** Allows the host (Proxmox VE) to manage the physical storage pool, enabling easy migration or storage expansion in the future.
2. **Safety:** Leaving ~15% of physical space unallocated on the host ensures ZFS Copy-on-Write performance and prevents "pool full" lockups.
3. **Features:** PBS handles compression and integrity checks internally (ZFS-on-ZFS), while the host handles physical health monitoring (SMART).

## Consequences
- **Trade-off:** Losing approximately 100-130 GB of usable raw capacity compared to Passthrough.
- **Mitigation:** The 800 GiB limit is strictly enforced to prevent host-level fragmentation.

---

# Proxmox Backup Server (PBS) Configuration

**Status:** Production
**VM ID:** 205
**Node:** PVE1

## 1. Storage Architecture
Utilized a nested ZFS approach for data integrity and flexibility.

- **Physical Layer (PVE Host):**
  - ZFS Pool: `pbs-store` (Single Disk)
  - Disk: 1TB SSD
  - Configuration: Thin Provisioning enabled on PVE storage layer.
- **Virtual Layer (PBS VM):**
  - Device: `scsi0` (VirtIO SCSI)
  - Options: `Discard=on`, `SSD Emulation=on`, `IO Thread=on`
  - Size: 800 GiB (leaves ~10-15% headroom on host ZFS for CoW/Performance)
  - Filesystem: ZFS (`datastore0`) with LZ4 compression.

## 2. Backup Strategy
Backups are performed via Proxmox VE integration using the `pbs-local` storage backend.

### Schedule & Retention
- **Backup Schedule:** Daily at 02:00 AM
- **Retention Policy (Prune):**
  - `keep-last`: 7 (Daily)
  - `keep-weekly`: 4
  - `keep-monthly`: 12
- **Garbage Collection:** Scheduled every Saturday at 05:15 AM.
- **Verification:** Scheduled Weekly (Sunday at 4:00 AM) with 30-day re-verify interval.

## 3. Network Configuration
- **Internal Interface:** `vmbr0` (Management)
- **Direct Link (Planned):** `vmbr1` (10.10.10.x) for high-speed backups from PVE2.

## 4. Disaster Recovery (DR)
In case of PVE1 failure:
1. Reinstall Proxmox VE.
2. Import the `pbs-store` ZFS pool (`zpool import -f pbs-store`).
3. Restore PBS VM configuration or reinstall PBS and mount the existing ZFS datastore.
4. **Critical:** Encryption keys are stored in [Safe G lication and Password Manager].
