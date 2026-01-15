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
    *   Media Libraries (Plex/Jellyfin)
    *   Nextcloud File Storage
    *   Software Archives / Installers
    *   Backup Archives
*   **Strategy:** Optimized for capacity and sequential reads. No SSD caching (L2ARC/SLOG) is currently used to minimize failure points.

### 4. `backup-local` (Rapid Recovery)
*   **Physical:** 1x SATA SSD
*   **Purpose:** Proxmox Backup Server (PBS) Datastore.
*   **Strategy:** Provides fast local restores in case of configuration errors ("fat finger" protection). This is NOT a disaster recovery solution; it is complemented by an off-site backup push.

## 🔄 Backup Strategy (3-2-1)
| Data Source | Local Copy | Remote Copy | Frequency |
| :--- | :--- | :--- | :--- |
| **VMs/CTs** | PBS on SATA SSD | Cloud Storage (Encrypted) | Daily |
| **Documents** | `tank` (ZFS) | External HDD (Offline) | Weekly |