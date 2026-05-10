# ADR: PBS Storage Strategy via Virtualized ZFS

## Context

Proxmox Backup Server requires persistent storage for backups. The storage backend is a single 1TB SSD attached to the Proxmox VE host.

Two options were evaluated:

- PCI/Disk passthrough to VM
- Virtual disk (ZFS-backed zvol on host)

## Decision

Selected virtual disk (ZFS zvol) with an 800 GiB limit.

## Rationale

- Preserves host-level storage control and flexibility
- Enables easier migration and storage reconfiguration
- Maintains ZFS integrity and monitoring at host layer
- Avoids tight coupling of physical device to VM

## Consequences

- Reduced usable capacity compared to passthrough
- Requires strict allocation discipline on host ZFS pool
