# 🖥️ Compute Nodes

This section describes the logical compute architecture of the homelab, consisting of a primary compute node, an edge/core node, and a planned quorum device for high availability.

---

## 🟢 Primary Compute Node

Main compute and storage node responsible for heavy workloads, storage aggregation, and container orchestration.

### Hardware Overview

* Intel Core i5 (6C/12T class, with integrated graphics for media acceleration)
* 64GB DDR4 RAM
* Mixed storage:

  * NVMe-based ZFS mirror for system and hot workloads
  * HDD-based ZFS pool for bulk storage

### Network Architecture

* Management network for administration and VM traffic
* Dedicated backend network for storage and cluster communication

### Responsibilities

* Docker Swarm primary manager
* Media processing and transcoding workloads
* Primary storage provider (ZFS-based NAS)
* Backup target for Proxmox Backup Server

---

## 🔵 Edge / Core Node

Low-power always-on node responsible for infrastructure stability, identity, monitoring, and remote access.

### Hardware Overview

* Low-power x86 CPU (energy-efficient class)
* 16GB RAM
* NVMe storage for system and services

### Responsibilities

This node acts as the **control and resilience layer** of the homelab:

* Reverse proxy (edge ingress)
* Identity provider (SSO / authentication)
* Monitoring and alerting
* DNS resolution redundancy
* Remote access gateway (VPN-based)
* Lightweight container services for infrastructure tooling

### Design Goal

Ensures core infrastructure remains available even if the primary compute node is offline.

---

## 🟡 Quorum / Witness Node (Planned)

Lightweight external node used to improve cluster reliability and prevent split-brain scenarios in HA configurations.

### Hardware Overview

* Ultra-low power thin client class device
* Minimal CPU/RAM footprint
* Always-on availability

### Role

* Cluster quorum witness
* Tie-breaker for distributed systems
* Ensures safe failover decisions
