# 🚀 Runbook: NFS Server (role: nfs_server)

## Purpose

Configure the storage host as an NFS server exposing selected datasets to the internal network.

Used to provide shared storage for compute and standalone systems.

---

## Prerequisites

- Storage host present in inventory under `pve1` (or equivalent group)
- ZFS datasets already created on the host (not managed by Ansible)
- User with sudo access available for Ansible execution
- Internal storage network configured and reachable from clients

---

## Variables (`group_vars/pve1/vars.yml`)

- `nfs_client_network` – allowed client subnet
- `nfs_export_options` – global export options template
- `nfs_exports` – list of exported paths

---

## Current Exports

| Path                 | Network        | Options                  |
|----------------------|----------------|--------------------------|
| /hot/swarm           | internal net   | rw, sync, no_root_squash |
| /hot/standalone      | internal net   | rw, sync, no_root_squash |
| /tank/data/nextcloud | internal net   | rw, sync, no_root_squash |
| /tank/data/immich    | internal net   | rw, sync, no_root_squash |
| /tank/data/media     | internal net   | rw, sync, no_root_squash |
| /tank/users          | internal net   | rw, sync, no_root_squash |

---

## Run

```bash
ansible-playbook -i inventories/prod/hosts.yml site.yml --limit pve1
````

---

## Verify

```bash id="nfs_v1"
exportfs -v
```

```bash id="nfs_v2"
showmount -e <storage_host>
```

---

## Re-apply exports (manual recovery)

```bash
exportfs -ra
```

---

## Adding New Export

1. Create dataset or directory on storage host
2. Add entry to `nfs_exports` in:

   - `group_vars/pve1/vars.yml`
3. Re-run Ansible playbook

---

## Key Insight

NFS server configuration is declarative, but **storage layout is not**.

> Ansible manages exposure of data, not creation of datasets.
