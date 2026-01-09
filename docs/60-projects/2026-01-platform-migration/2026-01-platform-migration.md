# 🚀 Project: 2026 Storage & Platform Upgrade

**Date:** January 2026  
**Status:** 🚧 In Progress  
**Objective:** Migration to Intel platform and implementation of All-Flash storage for VMs to improve IOPS, retiring HDD usage for active workloads.

## 🛠️ Hardware Changes
*   **Platform:** Migration to **Intel LGA1200** with **ASRock B560M** motherboard.
*   **Storage Expansion:** Adding 4x NVMe drives.
*   **Legacy Hardware:** Retaining existing 5x HDD RAIDZ array for bulk storage.

## 🎯 Target Storage Topology
*   **Tier 1 (System):** 2x NVMe (Mirror) -> Proxmox OS + ISOs + Critical LXCs.
*   **Tier 2 (Hot Data):** 2x NVMe (Mirror via PCIe x1 adapters) -> VM Disks, Docker Appdata, Databases.
*   **Tier 3 (Cold Data):** 5x HDD (RAIDZ1) -> Media, Archives.
*   **Backup:** 1x SATA SSD -> Local Proxmox Backup Server (PBS) datastore.

## 🛡️ Migration Strategy
**Philosophy:** "Non-destructive migration." The old HDD pool (`tank`) remains untouched until all data is verified on the new NVMe storage.

1.  **Fresh Install:** Clean Proxmox installation on the new NVMe mirror (`rpool`).
2.  **ZFS Replication:** Use `zfs send` | `zfs recv` to migrate datasets. This preserves snapshots, permissions, and compression settings better than file-level copying.
3.  **Import:** Import the old HDD pool (`tank`) into the new installation.

## 📋 Execution Plan (Runbook)

### Phase 1: Hardware & OS Setup
- [ ] Assemble hardware (Intel CPU, B560M, mount NVMe drives).
- [ ] Install Proxmox VE on NVMe Pair #1 (ZFS Mirror -> `rpool`).
- [ ] Create `pool_hot` on NVMe Pair #2:
  ```bash
  # NVMe connected via PCIe x1 adapters
  zpool create -o ashift=12 pool_hot mirror /dev/disk/by-id/nvme-ID3 /dev/disk/by-id/nvme-ID4
  ```

### Phase 2: Data Migration
- [ ] Import the existing HDD pool:
  ```bash
  zpool import -f tank
  ```
- [ ] Stop all containers/VMs on the old installation.
- [ ] Migrate Datasets (Example flow):
  ```bash
  # 1. Snapshot
  zfs snapshot tank/vm-100-disk-0@migration
  # 2. Send to new NVMe pool
  zfs send -v tank/vm-100-disk-0@migration | zfs recv pool_hot/vm-100-disk-0
  ```
- [ ] Update VM config files (`/etc/pve/qemu-server/`) to point to the new storage.

### Phase 3: Backup & Cleanup
- [ ] Mount SATA SSD and configure as a Directory or dedicated partition for PBS.
- [ ] Configure backup jobs for `rpool` and `pool_hot`.
- [ ] Verify all services are running from NVMe.
- [ ] **Optional:** Clean up old VM disks from `tank` to reclaim space for cold storage.

## 📝 Engineering Notes & "Gotchas"
*   **PCIe x1 Limitation:** The secondary NVMe mirror runs on PCIe x1 adapters. Sequential throughput is capped (~1GB/s), but **random IOPS** (critical for VMs) remains superior to SATA SSDs/HDDs.
*   **No Special VDEV:** Decided *against* using NVMe as Metadata/L2ARC for the HDD pool. Losing a special vdev can kill the whole pool. Keeping pools separate is safer for a homelab environment.