# Traefik in Docker Swarm — Overlay Network vs Compose Bridge

## Symptoms

- Containers deployed via `docker stack deploy` cannot reach services from `docker-compose up`
- Internal Traefik not routing traffic despite correct labels
- Traefik dashboard shows router as "active" but no attached services
- `Host()` rule not matching any service despite correct domain

## Root Cause

`docker-compose` creates **bridge** networks (scope: `local`).
`docker stack deploy` creates **overlay** networks (scope: `swarm`).
These two network types are incompatible — containers in different scopes
cannot communicate by service name.

Separate issue: Traefik `Host()` rule uses Go regexp syntax, not glob patterns.
Wildcard `*` is not valid — causes silent rule mismatch.

## Fix

Pre-create the overlay network and declare it as `external: true` in all stack files:

```bash
docker network create --driver overlay --attachable traefik-public
```

```yaml
networks:
  traefik-public:
    external: true
```

For Traefik routing rules — use explicit host or Go regexp, never glob wildcard:

```yaml
# WRONG:
rule: "Host(`*.homelab-x.example.com`)"

# CORRECT — explicit:
rule: "Host(`dozzle.homelab-x.example.com`)"

# CORRECT — regexp:
rule: "HostRegexp(`{subdomain:[a-z0-9-]+}.homelab-x.example.com`)"
```

## Notes

- `docker network ls` → check `SCOPE` column: `local` = bridge, `swarm` = overlay
- Labels for Swarm services must be under `deploy.labels`, not top-level `labels`
- Wildcard cert `*.domain.com` covers one subdomain level only — nested subdomains need explicit SANs
- Validate rules in Traefik Dashboard → Routers tab: shows parsed rule + matched services
- Ref: [Traefik Routers docs](https://doc.traefik.io/traefik/routing/routers/)
