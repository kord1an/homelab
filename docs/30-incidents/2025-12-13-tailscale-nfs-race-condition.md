# Incident: NFS mount instability on Swarm nodes upon boot

## Date
2025-12-13

## Context

- Docker Swarm cluster using shared NFS storage for `/srv/swarm`.
- NFS share defined in `/etc/fstab` using the LAN IP of the storage server.
- Some Swarm nodes mounted the share correctly on boot, others failed with network-related errors.

## Symptoms

- On a subset of Swarm nodes, the NFS mount for `/srv/swarm` failed during boot with errors such as `Network unreachable`.
- At least one node mounted the same share successfully with an identical `/etc/fstab` configuration.
- Docker services depending on the NFS mount behaved inconsistently between reboots (sometimes starting with storage available, sometimes not).

## Initial hypothesis (not confirmed)

- Race condition between network/VPN initialization and systemd attempting to mount the NFS share during early boot.
- Initial mitigation attempt: custom `.mount` unit with `After/Requires=` on the VPN service and retry logic, plus `RequiresMountsFor=` in `docker.service`.

## Actions taken (failed attempt)

- Adjusted `/etc/fstab` options and added systemd overrides for the NFS mount and Docker to wait on the VPN service.
- Observed that the solution did not reliably fix the issue across all Swarm nodes.
- Reverted to the previous, simpler configuration to restore a known-good state.
- Left the incident open for further investigation.

## Final fix (2025-12-14)

### Change summary

- Switched from a direct boot-time NFS mount to a systemd automount for `/srv/swarm` on all Swarm nodes.
- Updated the `/etc/fstab` entry to use a generic NFS export and automount:

        <nfs-server>:/tank/docker-swarm-data /srv/swarm nfs defaults,nofail,_netdev,x-systemd.automount 0 0

- Added a systemd override for Docker so that it only starts after `/srv/swarm` is mounted:

        [Unit]
        RequiresMountsFor=/srv/swarm

### Verification

- On all Swarm nodes:
- `systemctl status srv-swarm.automount` reports `active (waiting)`.
- First access to `/srv/swarm` (for example `ls /srv/swarm`) triggers a successful NFS mount.
- `df -h` and `mount` show `/srv/swarm` as an NFS mount from the storage server export.
- `systemctl status docker` is `active (running)` after reboot.
- Multiple reboots of each node confirmed that the NFS mount is established reliably without `Network unreachable` errors and that Docker starts with storage available.

### Outcome

- The suspected race between network bring-up and early NFS mount is effectively mitigated by using a systemd automount and an explicit Docker dependency on the mount.
- Incident is considered **resolved**; no further action is required unless similar symptoms reappear.