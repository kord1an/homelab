# Dozzle — Missing Nodes in Distributed Monitoring

**Date:** 2026-04-26

## Symptom

In a distributed container environment, the monitoring UI only displayed a single node instead of the full cluster.

System logs indicated duplicate agent registrations being rejected.

---

## Root Cause

The monitoring agents were deployed behind a service mesh layer that performed load balancing across nodes.

As a result:
- multiple physical nodes appeared as a single logical endpoint
- agent identity collisions were triggered
- only one node remained registered in the monitoring system

---

## Fix

The issue was resolved by ensuring that each node exposes its monitoring agent directly at the host network level, bypassing the load balancing layer.

This ensures:
- stable per-node identity
- correct agent registration
- accurate cluster visibility

---

## Key Insight

Distributed monitoring agents must have **direct node-level network identity**.

Any abstraction layer that merges traffic across nodes can break identity-sensitive systems such as:
- log aggregation agents
- metrics collectors
- monitoring exporters

---

## Takeaway

When working with distributed systems:
> Any component that relies on node identity must bypass load-balanced or shared network entry points.

---

## Related Architecture

- Monitoring & Observability Layer (see system architecture docs)
- Distributed Service Mesh behavior considerations