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
- **Storage:** NFS on ZFS (shared across nodes)
- **Reverse Proxy:** Traefik
- **Automation:** Ansible (work in progress)

## 🚧 Project Status

Currently migrating services to Docker Swarm:
- Services are scattered across Proxmox hosts and individual VMs
- Goal: unified multi-node Swarm environment with shared NFS storage
- Building Ansible automation in parallel

---

**Last update:** 2025-12-12
