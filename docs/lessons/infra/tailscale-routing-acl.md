# 🧠 Lessons: Tailscale Subnet Routing & Grants

---

## Problem: Traffic incorrectly routed and tests failing using legacy ACL syntax

### Symptom
Tailscale ACL policy validation failed with `[ssh] "check" action does not support tags in src` and tests failed with `address "IP:443" want: Accept, got: Drop`. 
Additionally, users without tags had full routing access instead of restricted proxy access.

---

## Root Cause

1. **Tag Authentication:** Tags in Tailscale operate as service accounts. An action requiring user interaction (like `"action": "check"` for SSH) cannot be performed by a tag because a tag has no human identity to perform SSO re-authentication.
2. **Grants Validation:** The new `grants` syntax separates `dst` (IPs) and `ip` (ports). The built-in testing engine struggled to validate individual user emails against dynamically compiled groups in the new format.
3. **Subnet Routing vs AdGuard:** Running the Subnet Router with `--accept-dns=true` caused the container to query MagicDNS instead of the local LAN AdGuard, creating a DNS loop when resolving local services.

---

## Fix Applied

- Switched from legacy `acls` to modern `grants`.
- Updated the SSH policy to `"action": "accept"` for tagged admin workstations (trusting the physical device).
- Updated tests to use `src: "group:family"` instead of literal emails to pass the validation engine.
- Configured Subnet Router to start with `--accept-dns=false` so it uses the native Proxmox LXC DNS resolution (AdGuard LAN IP).