# ADR-0003: NFS Server on PVE Host (not LXC)

## Status

Accepted

## Context

Docker Swarm nodes require shared storage for stateful workloads.
Two options were considered: NFS from a dedicated LXC container,
or NFS directly from the Proxmox VE host.

## Decision

NFS server runs directly on the PVE host, not in a dedicated LXC.

## Reasons

- Full access to ZFS pool without virtualization overhead
- Simpler management – no additional LXC to maintain
- ZFS ARC cache available directly to NFS server
- Snapshot management at pool level without extra indirection

## Consequences

- PVE host is now in Ansible inventory as `pve_hosts` group
- Role `common` must NOT run on `pve_hosts` (site.yml scoped accordingly)
- NFS export is scoped to dedicated storage network
