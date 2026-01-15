# 🌐 Network Architecture

## Topology Overview
The network infrastructure follows a **Zero Trust principles** approach with strict segmentation using VLANs to isolate IoT devices and Guest traffic from the Management Plane. A dedicated physical interconnect (Backbone) links the compute nodes for high-performance storage and cluster synchronization.

### Segmentation Strategy
*   **Management VLAN:** Dedicated to administrative interfaces (Proxmox VE Cluster, Backup Server, Network Controller). Access is restricted via ACLs.
*   **Services VLAN:** Hosts containerized applications (Docker Swarm, Databases) and Virtual Machines.
*   **IoT VLAN:** Totally isolated subnet for Smart Home devices. Internet access is blocked by default; communication with the Automation Hub is allowed only via specific ports.

### Direct Link Interconnect (Backbone)
A dedicated, physical point-to-point connection between PVE1 and PVE2, completely isolated from the main LAN/Omada switching fabric.
*   **Purpose:**
    *   **Shared Storage:** High-speed NFS mounting of NVMe resources from PVE1 to PVE2.
    *   **Cluster Traffic:** Low-latency Corosync heartbeat communication (Redundant Ring).
    *   **Migration:** Fast Live Migration of VMs without congesting the main router/switch.
*   **Configuration:** Implemented via a dedicated Linux Bridge (`vmbr1`) on a separate physical interface, using a private, non-routable subnet with no default gateway. VMs requiring direct storage access attach a secondary interface to this bridge.

### DNS & Addressing
*   **IPAM:** Critical infrastructure (Hypervisors, NAS, DNS) uses static DHCP reservations enforced by the Omada Controller. Client devices utilize dynamic pools.
*   **DNS Strategy:** Split-DNS architecture using **AdGuard Home** as the primary local resolver for ad-blocking and local domain resolution (`.lab`), with upstream fallback to public DNS (8.8.8.8) during maintenance.

### Remote Access (OOB)
*   **VPN:** Remote management is handled via **Tailscale** (Mesh VPN).
*   **Implementation:** A dedicated Subnet Router node provides access to internal subnets without exposing any ports on the WAN firewall (CGNAT friendly).