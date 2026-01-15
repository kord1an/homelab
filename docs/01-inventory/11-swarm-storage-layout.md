# Docker Swarm Storage Layout

**Last updated:** 2025-12-13  
**Purpose:** Document the directory structure for persistent data on Swarm nodes.

## Overview

All persistent data for Docker Swarm services is stored under `/srv/swarm` on the NFS mount.

The layout follows a convention:

    /srv/swarm
    ├─ prod/
    │   └─ <service-name>/
    │       └─ <service-name>-prod-<slot>/
    │            └─ (service-specific subdirectories)
    └─ demo/
    │   └─ <service-name>/
    │       └─ <service-name>-demo-<slot>/
    │            └─ (service-specific subdirectories)

## Naming Convention

- **Service name** (lowercase): `traefik`, `gitea`, `authentik`, `vaultwarden`, `jellyfin`.
- **Slot number** (prod-N): `prod-1`, `prod-2` and `demo-1`, `demo-2`.
- **Example paths:**

        /srv/swarm/prod/traefik/traefik-prod-1/
        /srv/swarm/demo/whoami/whoami-demo-1/

## Volume Mapping in Stack Files

In `opt/swarm/prod/gitea/gitea-prod-1-stack.yml`:

volumes:
  - /srv/swarm/prod/gitea/gitea-prod-1/data:/data
  - /srv/swarm/prod/gitea/gitea-prod-1/repos:/home/git/repositories

## Backup Strategy

- **Prod data:** backed up regularly from /srv/swarm/prod/.
- **Demo data:** optional, can be discarded after testing.