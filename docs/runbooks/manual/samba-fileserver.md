# Runbook: Samba Fileserver (Manual Setup)

## Overview
Temporary Samba fileserver running on a Debian 12 LXC on pve1.
Provides SMB shares backed by ZFS dataset via bind mount.
Intended for home user file access (Windows/Linux/Android).

**Status:** Temporary — planned migration to Docker Swarm in the future.

## Infrastructure

- **Host:** pve1 (Proxmox)
- **LXC type:** Unprivileged (UID offset: +100000)
- **ZFS dataset:** tank/users → bind mounted to /mnt/users in LXC
- **Shares:** bob, alice (private), public (group)

## Users & Groups

| Linux user | Samba share | UID (LXC) | UID (host) |
|------------|-------------|-----------|------------|
| user_bob | bob       | 1002      | 101002     |
| user_alice   | alice         | 1003      | 101003     |
| -          | public      | group: samba_users | GID (host) 101004 |

## Directory Permissions (on pve1 host)

```bash
chown -R 101002:101002 /tank/users/bob
chown -R 101003:101003 /tank/users/alice
chown root:101004 /tank/users/public  # GID of samba_users
chmod 2770 /tank/users/public
```

## Adding a New User

```bash
# On LXC
useradd -M -s /sbin/nologin user_xxx
smbpasswd -a user_xxx
smbpasswd -e user_xxx

# Add to group if needs public access
usermod -aG samba_users user_xxx

# On pve1 host — fix permissions
chown -R 10xxxx:10xxxx /tank/users/xxx
```

## Connecting from Clients

**Windows:** Map network drive → `\\<LXC-IP>\bob`

**Linux (Nautilus):** Connect to server → `smb://<LXC-IP>/bob`

**Android:** Cx File Explorer / Solid Explorer → SMB → `<LXC-IP>`

## Pika Backup (SSH)

Pika Backup connects via SMB to LXC as backup target.
Borg repository stored under `/mnt/users/<user>/<backup-name>/` or dedicated path.
Password stored in Vaultwarden.

## Known Issues / Lessons

- Unprivileged LXC requires UID offset (+100000) for chown on pve1 host
- `smbpasswd` requires system user to exist before setting Samba password - stored in Vaultwarden

## Future

- Migrate shares to Docker Swarm stack
- Add Authentik OIDC/LDAP integration for SSO