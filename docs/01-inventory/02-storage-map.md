# 💾 Storage Layout

Storage architecture is designed to balance performance (IOPS) for VMs and capacity for media, leveraging ZFS features.

### Physical Allocation
| Pool Name | Media Type | Topology | Use Case |
|---|---|---|---|
| **rpool** | NVMe SSD | Mirror (RAID1) | Proxmox OS, VM Root Disks, LXC Rootfs |
| **hot** | NVMe SSD | Mirror (RAID1) | Docker Volumes, Databases, High-IOPS Data |
| **tank** | HDD SATA | RAIDZ1 | Media Library, ISO Images, Backups Archive |
| **backup** | SATA SSD | Single Disk | Dedicated Proxmox Backup Server (PBS) Datastore |

### Key Configurations
*   **Filesystem:** ZFS on Linux (ZoL) for all data pools; EXT4 for the dedicated backup drive (Passthrough).
*   **Optimization:** `ashift=12` enforced for all SSD pools; `compression=lz4` enabled globally.
*   **Sharing:** Datasets from `tank` and `hot` are exported via **NFS** to the secondary node (PVE2) to facilitate shared storage access.
