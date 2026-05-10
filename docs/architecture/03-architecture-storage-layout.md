# 🏗️ Storage Architecture

**Last Updated:** January 2026  
**Host:** Proxmox VE (Intel i5-11400 B560M Platform)

## Overview
The storage subsystem is designed around **ZFS** with a tiered approach. High-performance workloads (VMs, Databases) run entirely on NVMe, while bulk data remains on mechanical HDDs.

## 💾 Physical & Logical Layout

### 1. `rpool` (System & Critical Services)
*   **Physical:** 2x NVMe SSD (ZFS Mirror)
*   **Mount Point:** `/` (Root)
*   **Purpose:**
    *   Proxmox VE Host OS
    *   LXC Container Templates & ISOs
    *   Critical Infrastructure Containers (e.g., DNS, Gateway)
*   **Rationale:** Ensures the host OS and core network services survive a single drive failure.

### 2. `hot` (Application Data)
*   **Physical:** 2x NVMe SSD (ZFS Mirror) connected via PCIe x1
*   **Purpose:**
    *   Virtual Machine shares/mountpoints from ZFS
    *   Docker Appdata / Volumes
    *   Databases (PostgreSQL/MariaDB)
*   **Performance Note:** While bandwidth is limited by PCIe x1 lanes, the low latency and high IOPS of NVMe make this ideal for random I/O workloads typical of virtualization.

### 3. `tank` (Cold / Bulk Storage)
*   **Physical:** 5x HDD (ZFS RAIDZ1)
*   **Purpose:**
    *   Media Libraries (Jellyfin)
    *   Nextcloud File Storage
    *   Software Archives / Installers
    *   Backup Archives
*   **Strategy:** Optimized for capacity and sequential reads. No SSD caching (L2ARC/SLOG) is currently used to minimize failure points.

### 4. `pbs-store` (Rapid Recovery)
*   **Physical:** 1x SATA SSD
*   **Purpose:** Proxmox Backup Server (PBS) Datastore.
*   **Strategy:** Provides fast local restores in case of configuration errors ("fat finger" protection). This is NOT a disaster recovery solution; it is complemented by an off-site backup push.

## 🔄 Backup Strategy (3-2-1)
| Data Source | Local Copy | Remote Copy | Frequency |
| :--- | :--- | :--- | :--- |
| **VMs/CTs** | PBS on SATA SSD | Cloud Storage (Encrypted) | Daily |
| **Documents** | `tank` (ZFS) | External HDD (Offline) | Weekly |

## Data Protection Strategy (Sanoid)

Apart from off-site backups (PBS), this environment utilizes **Sanoid** for local, rapid recovery (Time Machine style).

### Policy 1: Production (High Frequency)
**Applied to:** `hot/docker` (Configs, Stacks), `tank/users` (Documents)

| Schedule | Frequency | Retention | Purpose |
| :--- | :--- | :--- | :--- |
| **Frequently** | Every 15 mins | 4 snapshots (Last 1h) | Immediate "Undo" for configuration mistakes |
| **Hourly** | Every 1 hour | 24 snapshots (Last 24h) | Recovery from accidental file deletion within the last day |
| **Daily** | Once a day | 14 snapshots (2 weeks) | Short-term history for project rollback |
| **Monthly** | Once a month | 3 snapshots (3 months) | Quarterly checkpoints |

### Policy 2: Media (Low Frequency)
**Applied to:** `tank/data` (Media, Archives) - *Process Children Only*

| Schedule | Frequency | Retention | Purpose |
| :--- | :--- | :--- | :--- |
| **Daily** | Once a day | 7 snapshots (1 week) | Protection against accidental mass deletion |
| **Monthly** | Once a month | 2 snapshots (2 months) | Minimal history for static data |

**Configuration:** `/etc/sanoid/sanoid.conf`
**Recovery Procedure:** See `docs/10-runbooks/sanoid-zfs-data-snapshot-automation.md`
