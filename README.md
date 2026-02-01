# Homelab Infrastructure

Documentation and Infrastructure as Code for my home lab environment focused on learning system administration and DevOps practices.

## 📖 Repository Contents

- **Runbooks** - operational procedures (deployment, troubleshooting, recovery)
- **Inventory** - hardware, network, and VM documentation
- **Swarm** - Docker Swarm stack definitions
- **Ansible** - automation playbooks
- **Knowledge base** - design decisions, how-tos, references

## 🛠️ Tech Stack

- **Virtualization:** Proxmox VE
- **OS:** Debian/Ubuntu (VMs)
- **Orchestration:** Docker Swarm (multi-node)
- **Storage:** ZFS pools
- **Reverse Proxy:** Traefik
- **Automation:** Ansible (work in progress)

## 🚧 Project Status

Currently in the active phase of migrating from standalone LXC containers to a tiered Docker architecture:

- **Phase 1 (Complete):** Established "Guardian Node" (PVE2) running critical core services (DNS, Auth, Monitoring) in an independent Docker environment.
- **Phase 2 (In Progress):** Constructing the High-Availability Cluster (PVE1 + PVE2) and migrating main applications to Docker Swarm.
- **Current State:** Services are transitioning from legacy LXC/VMs to the new architecture. Shared NFS storage (ZFS-backed) is configured.
- **Next Steps:** Finalizing Authentik SSO integration and deploying the primary application stack (Media, Home Automation) to Swarm.
- **Automation:** Ansible playbooks are being developed in parallel to standardize configuration across nodes.

---

**Last update:** 2026-02-01
