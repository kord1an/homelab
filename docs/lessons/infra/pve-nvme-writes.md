# PVE NVMe Excessive Writes — Root Cause

**Date:** 2026-05-08
**Relates to:** Issue: Reduce NVMe wear on Proxmox nodes

## Symptom
iostat showed regular write spikes on NVMe drives (peaks 1–6 MB/s).
Assumption was that journald or system logs were the cause.

## Investigation
Ran `iotop -ao` for 60 seconds on both hosts.

## Root Cause
Primary writers were **KVM VMs via ZFS zvol** and **pmxcfs** — not logging.
journald + rrdcached combined were <100 KB/s — negligible.

## Lesson
**iostat does not distinguish between hypervisor, VM, and system writes.**
Always run `iotop -ao` before assuming logs are the problem on a PVE host.
On a KVM/ZFS hypervisor, VM disk IO is the dominant write source — this is expected behavior.

## NVMe Wear Context
- Wear rate: ~1.5%/month
- Projected lifetime: 4-5 years
- ZFS mirror provides redundancy — single drive failure is not data loss

## Applied Fix
Journald size cap as hygiene only — not a solution to NVMe wear.
See runbook: `docs/runbooks/infra/pve-journald-optimization.md`