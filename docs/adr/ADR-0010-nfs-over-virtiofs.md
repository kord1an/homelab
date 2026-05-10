# ADR-0010: NFS as Shared Storage Mechanism

## Status

Accepted

## Context

VMs on PVE need access to ZFS storage. Alternatives considered: virtiofs, iSCSI, NFS.

## Decision

Use NFS exports from PVE host to VMs over dedicated storage network.

## Consequences

- Compatible with ZFS snapshots (no open file issues)
- Single consistent mechanism for all VMs
- Slight overhead vs virtiofs, acceptable for homelab workloads
- Requires NFS client configuration on all Swarm nodes
