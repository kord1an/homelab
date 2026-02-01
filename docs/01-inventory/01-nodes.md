# 🖥️ Compute Nodes Inventory

## 🟢 PVE1 (Main Node)
The primary workhorse of the homelab, handling heavy workloads (media, storage, compute) and hosting the main ZFS pools.

### Hardware Specs
- **CPU:** Intel Core i5-11400 (6C/12T, Rocket Lake, iGPU UHD 730)
- **RAM:** 64GB DDR4 (2x 32GB 3000MHz, Non-ECC UDIMM)
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

## 🔵 PVE2 (Edge Node / Core Guardian)
A dedicated, low-power node designed as an independent "Guardian" for critical infrastructure. It hosts essential services that must remain operational even during a complete PVE1 failure, ensuring network access, monitoring, and remote management capabilities.

### Hardware Specs
- **CPU:** Intel N6005 (4C/4T, Jasper Lake, efficient low TDP)
- **RAM:** 16GB DDR4 SODIMM
- **Form Factor:** Mini PC
- **Networking:**
  - `vmbr0` (LAN): 1GbE Realtek RTL8111 (Onboard) → Management & VM Traffic
  - `vmbr1` (Direct): 1GbE Realtek M.2 (Secondary) → Cluster Heartbeat (10.10.10.2)
- **Storage Configuration:**
  - **Boot/System:** 256GB NVMe (ZFS Single `rpool`)
  - **Local Storage:** Used for "Core" Docker volumes (no dependency on PVE1 NFS for critical apps)
- **Power:** 19V DC External Brick

### Roles & Services
- **Cluster Role:** Vote 1/2 (Quorum member & Independent Watchdog)
- **Primary Role:** "Life Support System" for the Homelab (Edge Services)

### 🐳 Core Services Stack (Docker LXC)
This node runs `core` Docker Compose stacks isolated from the main Swarm, ensuring autonomy.
* **Traefik (Edge):** Independent Reverse Proxy with Let's Encrypt (DNS Challenge) for secure local access.
* **Authentik:** Centralized Identity Provider (IDP) & SSO protecting all core services.
* **Uptime Kuma:** External monitoring of PVE1, WAN availability, and critical paths.
* **Gotify + Apprise:** Centralized Notification Hub (push alerts via local/Tailscale).
* **Portainer:** Local container management UI.
* **Dozzle:** Real-time log viewer for debugging startup issues without SSH.
* **Homepage:** A lightweight, fast dashboard acting as the central landing page for the core infrastructure.
* **Tailscale (LXC):** Emergency remote access gateway & Subnet Router (running in a separate LXC container).
* **AdGuard Home (LXC):** Secondary DNS server ensuring internet resolution during PVE1 maintenance (running in a separate LXC container).


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