# Lessons: NFS Client Role

## NFS Mount Configuration

**Symptom:** `Error mounting: mount.nfs: remote share not in 'host:dir' format`
**Cause:** Incorrect format for the `src` parameter.
**Fix:** Ensure the `src` is set as `"{{ nfs_server_address }}:{{ item.path }}"`.

## Understanding NFS Common Package

**Symptom:** Handler `Restart NFS client` fails – service not found.
**Cause:** `nfs-common` is a library package, not a daemon – no service to restart.
**Fix:** Remove the handler entirely; no need to notify after installing the package.

## Key Takeaways

- Properly format NFS mount sources to avoid common errors.
- Understand the difference between library packages and daemons in Linux systems.
