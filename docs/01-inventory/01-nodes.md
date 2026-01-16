# 🖥️ Compute Nodes Inventory

## 🟢 PVE1 (Main Node)
The primary workhorse of the homelab, handling heavy workloads (media, storage, compute) and hosting the main ZFS pools.

### Hardware Specs
- **CPU:** Intel Core i5-11400 (6C/12T, Rocket Lake, iGPU UHD 730)
- **RAM:** 64GB DDR4 (2x 32GB 3200MHz, Non-ECC UDIMM)
- **Motherboard:** ASRock B560M-PRO4 (mATX)
- **Networking:**
  - `vmbr0` (LAN): 1GbE Intel I219-V (Onboard) → Management/VM Traffic
  - `vmbr1` (Direct): 1GbE PCIe Adapter → Storage Backbone (10.10.10.1)
- **Storage Configuration:**
  - **Boot/System:** 2x 512GB NVMe (ZFS Mirror `rpool`)
  - **Hot Data:** 2x 512GB NVMe (ZFS Mirror `hot`)
  - **Bulk Storage:** 5x 1TB HDD (ZFS RAIDZ1 `tank`)
  - **Backup Storage:** 1x TB SSD (ZFS Single `pbs-store`)
- **Power:** Chieftec 350W GPA-350S (Mod: SPC Sigma Pro Fan Swap for silence)
- **Case:** Midi Tower (Generic)

### Roles & Services
- **Cluster Role:** Vote 1/2 (Primary Compute)
- **Key Services:**
  - Docker Swarm Manager (Leader)
  - Jellyfin (Hardware Transcoding via iGPU Passthrough)
  - NAS File Server (Samba/NFS)
  - Proxmox Backup Server (VM)

***

## 🔵 PVE2 (Edge Node)
A low-power secondary node providing high availability for critical services (DNS, Routing) and acting as a replication target.

### Hardware Specs
- **CPU:** Intel N6005 (4C/4T, Jasper Lake, low TDP)
- **RAM:** 16GB DDR4 SODIMM
- **Form Factor:** Mini PC / NUC
- **Networking:**
  - `vmbr0` (LAN): 1GbE Realtek RTL8111 (Onboard) → Management/VM Traffic
  - `vmbr1` (Direct): 1GbE Realtek RTL8111 (M.2 Ethernet Adapter) → Storage Backbone (10.10.10.2)
- **Storage Configuration:**
  - **Boot/System:** 1x 256GB NVMe (ZFS Single `rpool`)
  - **Shared Storage:** Mounts NFS `/hot/shared` from PVE1 via Direct Link
- **Power:** 12V DC External Brick

### Roles & Services
- **Cluster Role:** Vote 1/2 (Secondary Compute / Failover Target)
- **Key Services:**
  - AdGuard Home / Pi-hole (Primary DNS)
  - Omada Controller (LXC)
  - Traefik Ingress (Replica)
  - ZFS Replication Target (Warm Standby for PVE1 VMs)

***

## 🟡 QDevice (Planned - Q1 2026)
External quorum device to enable automatic High Availability (HA) and prevent split-brain scenarios.

### Hardware Specs
- **Model:** Dell Wyse 3040 Thin Client
- **CPU:** Intel Atom x5-Z8350 (4C/4T)
- **RAM:** 2GB DDR3L
- **Storage:** 8GB eMMC
- **OS:** Debian 12 (Bookworm) Minimal
- **Networking:** 1GbE LAN
- **Power:** ~3W (MicroUSB 5V)

### Role
- **Cluster Role:** Vote 1/3 (Tie-breaker)
- **Service:** `corosync-qnetd` daemon