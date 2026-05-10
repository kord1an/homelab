# ADR-0009: ZFS Storage Layout

## Status

Accepted

## Context

A virtualization host requires persistent storage for containerized services, standalone containers,
and user data. Two ZFS pools are available: one optimized for performance and another for capacity.

## Decision

- **Performance Pool**: Used for shared volumes across multiple nodes.
- **Capacity Pool**: Used for bulk data storage and user home directories.
- Directories within datasets instead of separate datasets per service.

## Consequences

- Simplified snapshot management (one snapshot per dataset covers all services).
- Reduced ZFS overhead (fewer datasets).
- Less granular per-service quota control.
