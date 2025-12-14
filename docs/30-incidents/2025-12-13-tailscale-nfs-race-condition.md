# Incident: NFS mount instability on Swarm nodes upon boot

## Date
2025-12-13

## Context
- Docker Swarm cluster using mounted NFS storage.
- Mount defined in `/etc/fstab` using LAN IP of the NFS server.
- Some Swarm nodes mounted the share correctly on boot, others failed with network-related errors.

## Symptoms
- On part of the nodes NFS mount failed during boot with errors like "Network unreachable".
- At least one node mounted the same share successfully with identical configuration.
- Docker services depending on the NFS mount behaved inconsistently between reboots.

## Hypothesis (not confirmed)
- Race condition between `tailscaled.service` starting and systemd attempting to mount the NFS share during early boot.
- Proposed mitigation: custom `.mount` unit with `After/Requires=tailscaled.service` and retry logic, plus `RequiresMountsFor=` in `docker.service`.

## Actions taken
- Tested modified `/etc/fstab` and systemd overrides for the NFS mount and Docker.
- Observed that the solution did not reliably fix the issue across all nodes.
- Reverted to the previous, default configuration to restore a known-good state.

## Current status
- Problem considered **open / unresolved**.
- Cluster is back on the original configuration; further investigation postponed.

## Next steps (planned)
- Revisit the issue with fresh tests:
  - Collect exact boot logs for `tailscaled`, NFS mount, and `docker.service`.
  - Experiment with alternative approaches (e.g. automount units, `x-systemd.automount`, or local NFS reachability checks before mount).
- Update this document once a stable, repeatable solution is found.
