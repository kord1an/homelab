# Homelab Overview

**Status:** Active  
**Last Updated:** 2025-12-16

## Goal

The homelab serves as a production-grade environment for self-hosted services, built with an "Ops-first" mindset:

- **Infrastructure as Code (IaC):** Ansible for baseline configuration.
- **Orchestration:** Docker Swarm for service management.
- **Security:** Zero Trust principles via Authentik (SSO) and Tailscale.
- **Storage:** Centralized NFS on ZFS with a standardized directory layout.

## High-Level Architecture

### Compute
- **Docker Swarm Cluster:** 3 nodes (1 Manager, 2 Workers) running on Proxmox VMs.
- **Virtualization:** Proxmox VE managing underlying resources.

### Networking
- **Ingress:** Traefik as the central reverse proxy handling TLS (Let's Encrypt) and routing.
- **Access:** Administrative access secured via Tailscale VPN; public services protected by Cloudflare and local firewalls (UFW/Sophos).
- **Segmentation:** VLANs separating Management, IoT, and Trusted traffic.

### Storage
- **Protocol:** NFS mounted on all Swarm nodes.
- **Backend:** ZFS datasets providing snapshots and data integrity.
- **Backup:** Proxmox Backup Server for VM-level backups.

## Key Design Decisions

- **Git-driven Workflow:** Operational stacks are pulled from a private Gitea repo; this GitHub repo serves as a template source and documentation hub.
- **Secret Management:** No `.env` files in public repos; secrets are injected via Docker Secrets at runtime.
- **Standardized Storage:** All persistent data resides in mounted shared storage from ZFS, ensuring portability between nodes.
