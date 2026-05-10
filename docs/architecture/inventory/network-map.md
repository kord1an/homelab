# 🌐 Network Architecture

## Topology Overview

The network infrastructure follows a **Zero Trust principles** approach with strict segmentation using VLANs to isolate IoT devices and Guest traffic from the Management Plane. A dedicated physical interconnect (Backbone) links the compute nodes for high-performance storage and cluster synchronization.

### Segmentation Strategy

* **Management VLAN:** Dedicated to administrative interfaces such as Proxmox VE Cluster, Backup Server, and Network Controller. Access is restricted via ACLs.
* **Services VLAN:** Hosts containerized applications like Docker Swarm and Databases, as well as Virtual Machines.
* **IoT VLAN:** Totally isolated subnet for Smart Home devices. Internet access is blocked by default; communication with the Automation Hub is allowed only via specific ports.

### Direct Link Interconnect (Backbone)

A dedicated, physical point-to-point connection between compute nodes ensures high-speed data transfer and low-latency cluster traffic.

* **Purpose:**
  * **Shared Storage:** High-speed NFS mounting of storage resources.
  * **Cluster Traffic:** Low-latency communication for redundancy.
  * **Migration:** Fast Live Migration of VMs without network congestion.

### DNS & Addressing

* **IPAM:** Critical infrastructure uses static DHCP reservations, while client devices use dynamic pools.
* **DNS Strategy:** Split-DNS architecture with a local resolver for ad-blocking and local domain resolution, with upstream fallback to public DNS during maintenance.

### Remote Access (OOB)

* **VPN:** Remote management is handled via a secure Mesh VPN.
* **Implementation:** A dedicated Subnet Router node provides internal access without exposing ports on the WAN firewall.