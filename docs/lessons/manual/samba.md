# 🧠 Lessons: Samba Fileserver (Manual Setup)

---

## Problem: Incorrect file ownership between host and LXC

### Symptom
Files created inside a Samba share appeared correctly owned inside the LXC,
but showed incorrect ownership on the Proxmox host.  
Writes sometimes failed silently or behaved inconsistently.

---

## Root Cause

The container is an **unprivileged LXC**, which means UID/GID mapping is applied.

Inside the container:
- user UID: `1001`

On the host:
- mapped UID: `101001` (offset +100000)

So ownership appears shifted when viewed from the host namespace.

---

## Fix

Always apply UID/GID mapping when operating from the host side:

```bash id="8p2l9c"
chown -R 101001:101001 /shared/storage/users/alice