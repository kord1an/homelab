# ADR-0005: Store NFS Variables in host_vars Instead of group_vars

## Status

Accepted

## Context

NFS server role is deployed on a single PVE node directly on bare
metal, backed by ZFS. Variables were initially placed in
group_vars/pve_hosts/ which applies to all PVE nodes.

## Decision

Move NFS-related variables to host_vars to scope them
to the only host that runs the NFS server role.

## Consequences

- Variables are scoped correctly — node02 is not affected
- If a second NFS node is added in the future, create a [nfs_servers]
  group and migrate variables to group_vars/nfs_servers/
