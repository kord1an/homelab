# ADR-0004: NFS Exports Per Dataset Path (not root pool)

## Status

Accepted

## Context

Two ZFS pools available (SSD and HDD). Decision needed on export granularity.

## Decision

Export individual dataset paths (e.g. /tank/swarm) rather than pool root (/tank).

## Reasons

- Granular access control per workload
- Independent snapshot management per dataset
- Principle of least privilege – Swarm nodes access only what they need
- Role supports list of exports (nfs_exports) – easily extensible

## Consequences

- Each new workload requiring shared storage needs its own dataset and export entry
- nfs_exports list in `group_vars/pve_hosts/vars.yml` must be updated manually
