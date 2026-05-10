# 💾 Storage Layout

Storage architecture is designed to balance performance (IOPS) for VMs and capacity for media, leveraging ZFS features. The system is divided into four main pools.

### Physical Allocation
| Pool Name | Media Type | Topology | Use Case |
|---|---|---|---|
| **rpool** | NVMe SSD | Mirror (RAID1) | Proxmox OS, VM Root Disks, LXC Rootfs |
| **hot** | NVMe SSD | Mirror (RAID1) | Docker Volumes, Databases, High-IOPS Data |
| **tank** | HDD SATA | RAIDZ1 | Media Library, ISO Images, Archive |
| **pbs-store** | SATA SSD | Single Disk (ZFS) | Dedicated Proxmox Backup Server (PBS) Datastore |

### Key Configurations
*   **Filesystem:** ZFS on Linux (ZoL) is used for all pools, including the backup drive.
*   **Optimization:** `ashift=12` enforced for all SSD pools; `compression=lz4` enabled globally.
*   **Sharing:** Datasets from `tank` and `hot` are exported via **NFS** to the secondary node (PVE2) to facilitate shared storage access.

**PBS Datastore Details:**
  - **Pool Name:** `pbs-store`
  - **Model:** Samsung SSD 870 QVO 1TB
  - **Type:** Single Disk ZFS Pool (Managed directly by PVE or passed to PBS)
  - **Size:** ~931 GB (Physical)
  - **Purpose:** Primary target for nightly Proxmox Backup Server deduplicated backups (`datastore0`).

### Storage Datasets & Protection Policies

Local ZFS snapshots are managed by **Sanoid** (check `docs/10-runbooks/sanoid-zfs-data-snapshot-automation.md` for more information) to provide rapid "Time Machine" recovery.

- **hot/docker** `[NVMe]` `[Policy: Production]`
  - **Content:** Docker `volumes`, `stacks`, `prod` configurations.
  - **Protection:** Granular history (15min / Hourly / Daily) for quick rollbacks.

- **tank/users** `[HDD]` `[Policy: Production]`
  - **Content:** User home directories, Nextcloud data.
  - **Protection:** Granular history (15min / Hourly / Daily) to protect user work.

- **tank/data** `[HDD]` `[Policy: Media]`
  - **Content:** Movies, TV Shows, ISO Archives.
  - **Protection:** Low frequency (Daily / Monthly) to prevent accidental mass deletion without wasting space.