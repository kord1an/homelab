# 🔀 Tailscale User & Admin Onboarding

## Purpose

Standard operating procedure to grant access to homelab resources via Tailscale Identity-Based Access Control (IBAC).

---

## Prerequisites

- Device has Tailscale client installed.
- Tailscale Subnet Router (`ts-gw`) is running and advertising routes.
- Access to the Tailscale Admin Console.

---

## Architecture

```text
External Traffic (Remote)
    ↓
[ Tailscale Tunnel ]
    ↓
[ Subnet Router LXC (ts-gw) ]
    ↓
[ Internal LAN / Internal DNS / Reverse Proxy ]
```

---

## Procedure 1: Onboarding an Application User (Standard Access)

Standard users only require access to web applications via Reverse Proxy. They do not get SSH or hypervisor (PVE) access.

1. Send a Tailscale invite link to the user's email.
2. Add the user's email to `group:users` in the `policy.hujson` repository.
3. Commit and sync the policy to Tailscale.
4. Instruct the user to ensure **"Use Tailscale subnets"** is toggled ON in their mobile/desktop client settings.

---

## Procedure 2: Elevating to Admin (Break Glass / Daily Driver)

Admins use standard accounts for daily tasks but require physical device verification for infrastructure access (Least Privilege).

1. Ensure the admin is logged into the Tailscale client.
2. Open Tailscale Admin Console -> **Machines**.
3. Locate the admin's device (e.g., dedicated laptop).
4. Select **Edit ACL tags** and apply `tag:admin-workstation`.
5. The device now has full internal subnet access (e.g., `10.0.0.0/16`) and bypasses interactive SSH checks.

*Note: To revoke privileges, simply remove the tag from the machine in the Admin Console.*

---

## Troubleshooting

| Symptom | Check | Fix |
| :--- | :--- | :--- |
| Cannot resolve internal domains | Split-DNS settings | Ensure Custom DNS is set to LAN IP with "Restrict to domain" |
| Ping works, HTTP fails | Reverse Proxy IP | Verify Traefik/NPM is running on the correct local IP and port 443 is open |
| Complete connection drop | LXC `ip_forward` | Ensure `net.ipv4.ip_forward = 1` in `/etc/sysctl.conf` on `ts-gw` |