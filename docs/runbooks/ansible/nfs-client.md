# 🚀 Runbook: NFS Client (role: nfs_client)

## Purpose
Mount NFS exports from the storage host on Swarm nodes and standalone VMs.

Used for shared storage access across the homelab.

---

## Prerequisites

- NFS server configured and running (see `runbooks/ansible/nfs-server.md`)
- Network connectivity between clients and storage network
- NFS server IP defined in:
  - `group_vars/all/vars.yml` → `nfs_server_address`
- Export mappings defined in:
  - `group_vars/swarm/vars.yml` or `host_vars/<host>/`

---

## Variables

- `nfs_server_address` – IP address of the NFS server
- `nfs_exports` – list of mount definitions:
  - source path
  - target mount point

---

## Run

```bash
ansible-playbook -i inventories/prod/hosts.yml site.yml \
  --limit swarm_managers,swarm_workers,<standalone_group>
````

---

## Verify

Check mounts:

```bash id="m3kq9x"
mount | grep nfs
```

Check disk visibility:

```bash id="k2v8lp"
df -h | grep <nfs_server_address>
```

---

## Adding New Mount

1. Add entry to `nfs_exports` in appropriate:

   * `group_vars/`
   * or `host_vars/<host>/`

2. Re-run playbook

No manual unmount required — configuration is idempotent.

---

## Key Insight

NFS mounts are fully declarative in this setup.

> State is defined in Ansible inventory, not on the host itself.
