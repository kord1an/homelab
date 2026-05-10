# 🏗️ Storage Model

**Last Updated:** January 2026

> This document describes the conceptual storage architecture of the homelab.
> Physical implementation details (disk layout, hardware models, pool names) are maintained in private infrastructure documentation.

---

## Overview

The storage architecture is designed around **ZFS** and follows a tiered model to separate workloads by performance, capacity, and recovery requirements.

The primary goal is:
- predictable performance
- data integrity
- fast recovery from operational mistakes
- clear separation of workload types

---

## Storage Design Principles

- **Tiered storage model** based on workload characteristics
- **ZFS-first approach** for data integrity and snapshots
- **Separation of performance and capacity workloads**
- **Fast local recovery prioritized over long-term retention**
- **Failure domain isolation between tiers**

---

## Storage Tiers

### ⚡ Performance Tier

Used for workloads requiring low latency and high IOPS.

Typical workloads:
- Virtual machines
- Container volumes
- Databases
- Active application data

Characteristics:
- optimized for random I/O
- redundancy through mirroring
- low-latency access is the priority

---

### 📦 Capacity Tier

Used for large, sequential, and less latency-sensitive data.

Typical workloads:
- Media libraries
- File storage
- Archives
- User data

Characteristics:
- optimized for storage density
- redundancy through parity-based layouts
- cost efficiency over performance

---

### 💾 Backup Tier

Dedicated to backup and recovery systems.

Typical workloads:
- system backups
- VM snapshots
- disaster recovery datasets

Characteristics:
- optimized for restore speed
- independent from primary workload tiers
- not a substitute for off-site backups

---

## Backup Strategy (3-2-1 Model)

The system follows a simplified 3-2-1 backup strategy:

- **3 copies of data**
- **2 different storage mediums**
- **1 off-site or external copy**

### Layers

- **Local backups:** fast restore for operational mistakes
- **Remote backups:** protection against infrastructure failure
- **Primary storage:** production workloads

---

## Snapshot Strategy

ZFS snapshots are used as a near-instant recovery mechanism for critical datasets.

Key properties:
- frequent snapshots for short-term rollback
- scheduled retention policies
- independent from backup system

Snapshots are treated as:
> operational safety layer, not a backup replacement

---

## Recovery Philosophy

The system prioritizes:

1. fast rollback of accidental changes
2. service continuity over perfect retention
3. simple recovery workflows
4. minimal manual intervention during recovery

---

## Failure Domain Isolation

Storage tiers are intentionally separated to ensure:

- workload failures do not propagate across tiers
- backup systems remain independent from production loads
- high-performance workloads are not impacted by bulk storage behavior

---

## Summary

This storage model is designed to balance:
- performance (VMs, services)
- capacity (media, archives)
- resilience (snapshots + backups)

The system is intentionally split into layers to reduce coupling between workloads and improve operational safety.