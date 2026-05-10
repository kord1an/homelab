# 💾 Storage Architecture

Storage architecture is designed to balance performance, capacity, and data resilience using ZFS-based tiering.

The system separates workloads into dedicated storage tiers based on performance and retention requirements.

---

## Storage Tiers

### ⚡ Performance Tier
Optimized for low-latency and high IOPS workloads.

Typical use cases:
- Virtual machines
- Container volumes
- Databases
- Active application data

Design characteristics:
- ZFS mirrored configuration
- optimized for random I/O performance
- prioritizes latency and consistency

---

### 📦 Capacity Tier
Optimized for large-scale and sequential data storage.

Typical use cases:
- Media libraries
- ISO archives
- User files
- Long-term storage

Design characteristics:
- parity-based redundancy
- optimized for storage density
- cost-efficient capacity scaling

---

### 💾 Backup Tier
Dedicated storage layer for backup systems.

Typical use cases:
- system backups
- VM backups
- restore points

Design characteristics:
- optimized for restore performance
- isolated from production workloads
- supports deduplicated backup systems

---

## Dataset Strategy

Storage is logically divided into datasets aligned with workload types.

### Production Data
Used for actively changing workloads requiring rollback capability.

Examples:
- container data
- application configurations
- user working directories

Characteristics:
- frequent snapshotting
- short retention window for fast recovery
- optimized for operational safety

---

### Media & Archive Data
Used for large, mostly immutable datasets.

Examples:
- media libraries
- backups of static content
- archives

Characteristics:
- low-frequency snapshot policy
- optimized for storage efficiency
- reduced snapshot overhead

---

## Snapshot Strategy

ZFS snapshots are used as a near-instant recovery mechanism for critical datasets.

Key properties:
- frequent snapshots for production datasets
- low-frequency snapshots for static data
- independent from backup systems

Snapshots are treated as:
> fast operational rollback mechanism, not a replacement for backups

---

## Backup Strategy (3-2-1 Model)

The system follows a 3-2-1 backup principle:

- 3 copies of important data
- 2 different storage systems or layers
- 1 external or off-site backup copy

### Layers:
- Primary storage (production workloads)
- Local backup layer (fast restore capability)
- External backup layer (disaster recovery)

---

## Design Principles

- separation of compute and storage workloads
- isolation between performance and capacity tiers
- fast recovery over long-term local retention
- redundancy at storage level (ZFS)
- backups treated as an independent system layer

---

## Summary

The storage system is designed as a layered architecture separating performance, capacity, and backup workloads to ensure reliability, scalability, and fast operational recovery.