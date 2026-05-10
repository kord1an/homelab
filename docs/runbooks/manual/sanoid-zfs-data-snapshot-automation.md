# 💾 Runbook: ZFS Snapshot Recovery (Sanoid)

**Last updated:** 2026-01-18
**Scope:** ZFS datasets (`tank`, `hot`)
**Tooling:** Sanoid snapshots
**Impact:** No downtime (file-level restore)

---

## Purpose

Restore individual files or directories from ZFS snapshots without rolling back entire datasets.

---

## Snapshot access

ZFS snapshots are accessible via:

```bash
/path/to/dataset/.zfs/snapshot/
```

Example:

```bash
cd /tank/users/.zfs/snapshot
```

List snapshots:

```bash
ls -lt
```

---

## File-level recovery

### 1. Locate snapshot

```bash
cd autosnap_<timestamp>_<frequency>
```

Example:

```bash
cd autosnap_2026-01-18_17:00:00_hourly
```

---

### 2. Locate file

```bash
ls -l path/to/file
```

---

### 3. Restore file or directory

#### Single file

```bash
cp path/to/file /tank/users/path/to/file.restored
```

#### Directory

```bash
rsync -av path/to/dir/ /tank/users/path/to/dir.restored/
```

---

### 4. Replace original (optional)

```bash
mv file.restored file
```

---

## Full dataset rollback (destructive)

⚠️ This operation removes all changes after selected snapshot.

### 1. Stop dependent services

```bash
systemctl stop smbd docker
```

### 2. Rollback dataset

```bash
zfs rollback -r tank/documents@autosnap_<timestamp>_hourly
```

### 3. Start services

```bash
systemctl start smbd docker
```

---

## Notes

* Snapshot ownership and permissions are preserved
* Permission fixes may be required after restore (`chown`)
* SMB clients may access snapshots if `snapdir=visible` is enabled in ZFS dataset properties
* Snapshot policy is managed via Sanoid (`recursive = yes` on parent datasets)

---

## Key principle

Snapshots are the primary recovery mechanism for user-level data.

> Backups (PBS) = disaster recovery
> Snapshots (ZFS) = fast operational recovery
