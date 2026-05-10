# PVE Journald Optimization

**Apply to:** All PVE hosts on fresh install or when /var/log grows unexpectedly.

## Steps

1. Create drop-in config (never edit journald.conf directly):
   
        mkdir -p /etc/systemd/journald.conf.d/
        nano /etc/systemd/journald.conf.d/pve-optimization.conf

2. Paste:

        [Journal]
        SystemMaxUse=200M
        MaxRetentionSec=3day

3. Apply and verify:

        systemctl restart systemd-journald
        journalctl --disk-usage

## Expected result
Disk usage drops from ~1G+ to <50MB.

## Notes
- Drop-in file survives package updates, direct edits to journald.conf do not
- This is hygiene only — on PVE the dominant write source is VMs, not logs
- See lesson: `docs/lessons/infra/pve-nvme-writes.md`