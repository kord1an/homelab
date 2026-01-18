# Runbook: ZFS Data Snapshot Recovery (Sanoid)

**Last updated:** 2026-01-18  
**Frequency:** On-demand (File/Folder Recovery)

## Purpose

This procedure outlines the steps for recovering lost or corrupted files/folders from ZFS datasets (`tank`, `hot`) using local snapshots managed by Sanoid. It serves as a "Time Machine" for user data, allowing granular restoration without rolling back entire systems.

## Context

- **Environment:** Homelab
- **Target Storage:** ZFS Pools `tank` (Cold/Large Storage) & `hot` (Fast/NVMe Storage)
- **Scope:** Shared folders, Docker volumes, User documents
- **Impact:** **Zero downtime**.Recovery is performed on live datasets via the hidden .zfs directory.


## Prerequisites

- [ ] SSH root access to the Proxmox host or NAS VM
- [ ] Read access to the target dataset
- [ ] Knowledge of the file/folder path that needs recovery

## Steps

### 1. Preparation (Locate Snapshot)

Data snapshots are accessible live via a hidden directory. No need to stop services.

1.  Navigate to the dataset root.
    *Example: Recovering a file in `tank/users`*
    ```bash
    cd /tank/users
    ```

2.  Enter the hidden `.zfs/snapshot` directory:
    ```bash
    cd .zfs/snapshot
    ```
    *(Note: This directory is invisible to `ls -a` but accessible via `cd`)*

3.  List available time points:
    ```bash
    ls -lt
    ```
    *Output example:*
    ```text
    drwxr-xr-x 1 root root 0 Jan 18 18:00 autosnap_2026-01-18_18:00:00_hourly
    drwxr-xr-x 1 root root 0 Jan 18 17:00 autosnap_2026-01-18_17:00:00_hourly
    ```

### 2. Execution (Restore Files)

Copy the missing data from the snapshot back to the live file system.

1.  **Enter the chosen snapshot:**
    ```bash
    cd autosnap_2026-01-18_17:00:00_hourly
    ```

2.  **Locate the file:**
    Browse the directory structure (it mirrors the live filesystem state at that time).
    ```bash
    ls -l path/to/lost/file.txt
    ```

3.  **Restore (Copy):**
    Copy the file/folder to the live location. **Do not overwrite** unless certain. Restore with a suffix first.
    ```bash
    # Restore a single file
    cp path/to/lost/file.txt /tank/users/path/to/lost/file_restored.txt
    
    # Restore a folder (Recursive)
    rsync -av path/to/folder/ /tank/users/path/to/folder_restored/
    ```

### 3. Verification

1.  Check the restored file:
    ```bash
    ls -l /tank/users/path/to/lost/file_restored.txt
    ```
2.  Verify integrity (open the file/document).
3.  Replace the corrupted original (if applicable):
    ```bash
    mv /tank/users/path/to/lost/file_restored.txt /tank/users/path/to/lost/file.txt
    ```

## Rollback (Full Dataset Revert)

**WARNING:** Use ONLY if the entire dataset is corrupted (e.g., Ransomware encryption). This **destroys** all data created after the snapshot.

1.  **Stop services** using this dataset (e.g., Samba, Docker containers).
    ```bash
    systemctl stop smbd docker
    ```
2.  **Execute Rollback:**
    ```bash
    zfs rollback -r tank/documents@autosnap_2026-01-18_17:00:00_hourly
    ```
3.  **Restart services:**
    ```bash
    systemctl start smbd docker
    ```

## Notes / Troubleshooting

- **Permissions:** Restored files retain the ownership/permissions from the snapshot. You might need to `chown` them if users have changed.
- **Windows/SMB Access:**
    - If configured (`zfs set snapdir=visible`), users can access snapshots directly in Windows Explorer via "Previous Versions" tab on mapped drives. This enables self-service recovery.
- **Sanoid Config:** Ensure `recursive = yes` is set for parent datasets (`tank`, `hot`) to cover all sub-volumes.