# ADR-0015: traefik-kop + Redis for Multi-Host Service Discovery

## Status

Proposed

## Context

ADR-0011 established a two-Traefik architecture: Edge Traefik (no Docker socket) +
Internal Traefik running inside Docker Swarm, discovering services via the Swarm
provider. This solved the Docker socket security concern but introduced a hard
constraint: only services deployed inside the Swarm cluster were discoverable.

The homelab workload model is intentionally hybrid:
- **Swarm** — experimental, lab-grade services; ephemeral by design
- **Standalone Docker Compose** — stable, production-grade workloads on dedicated
  hosts; not part of the Swarm cluster

Internal Traefik (Swarm provider) cannot discover standalone Compose containers on
other hosts. Every new standalone service required manual static configuration on
Edge Traefik — defeating the goal of declarative, label-driven routing.

Additionally, the Internal Traefik layer introduced an unnecessary network hop
(Edge → Internal Traefik → service) for Swarm services, adding latency and
operational complexity with no security benefit once kop-based discovery is available.

## Decision

Remove Internal Traefik from the Swarm cluster. Replace Swarm-based service discovery
with **traefik-kop** — a sidecar daemon that runs on each Docker host, reads container
labels, and publishes routing rules to a shared **Redis** instance. Edge Traefik
consumes routing rules directly from Redis via the Redis provider.

### Architecture

```
[Docker Host A — standalone Compose]
  └── traefik-kop  ──┐
                     ▼
[Docker Host B — Swarm node]          Redis (core host)
  └── traefik-kop  ──┤                     │
                     └──→  Redis  ←────────┤
[Docker Host C — Swarm node]               │
  └── traefik-kop  ──┘              Edge Traefik (core host)
                                          │
                                    Authentik (ForwardAuth)
                                          │
                                    [All services]
```

- **traefik-kop** runs as a standalone container on every Docker host (manager,
  worker, and non-Swarm hosts alike)
- **Redis** runs on the core host alongside Edge Traefik; not exposed externally
- **Edge Traefik** gains a Redis provider pointing to the core Redis instance
- Container labels remain unchanged — same `traefik.*` label syntax as before
- Docker socket access is local only (kop reads socket on its own host, never
  exposed over network)

## Consequences

### Positive

- **Unified discovery** — Swarm services and standalone Compose containers are
  discovered through the same mechanism, no special-casing per host type
- **No extra routing hop** — Edge Traefik routes directly to service containers,
  Internal Traefik layer eliminated
- **Docker socket stays local** — kop reads `/var/run/docker.sock` only on the
  host it runs on; socket never crosses network boundary (ADR-0011 security
  requirement preserved)
- **Declarative, label-driven** — adding a new service on any host requires only
  container labels; no static config changes on Edge Traefik
- **Ansible-friendly** — kop deployment is a repeatable role applicable to all
  hosts regardless of Swarm membership

### Trade-offs

- **Redis as new dependency** — Redis becomes a critical infrastructure component;
  if Redis is unavailable, Edge Traefik loses all dynamically discovered routes.
  Mitigation: Redis runs on the core host (same host as Edge Traefik), single point
  of failure is acceptable in homelab context. Redis persistence (`appendonly yes`)
  required to survive restarts.
- **kop must run on every host** — new Docker hosts require kop deployment before
  their services are discoverable. Ansible role enforces this.
- **Swarm services need label adjustment** — services previously discovered via
  Swarm provider labels may need `traefik.docker.network` label added explicitly,
  since kop uses the bridge/overlay network visible on the local node.
- **traefik-kop is a community project** — not officially maintained by Traefik
  team. Pin to a specific release tag; do not use `latest`.

## Rejected Alternatives

- **Swarm-internal Traefik** (ADR-0011, removed in feature/traefik-dashboard-auth)
  — only discovered Swarm services; standalone Compose hosts required manual static
  config on Edge Traefik.
- **Traefik File Provider (static)** — manual `routers` and `services` entries per
  service; not declarative, high maintenance burden, does not scale.
- **Consul catalog provider** — would solve the same problem but introduces Consul
  cluster as a dependency; operationally heavier than Redis for homelab scale.

## Related

- `docs/adr/ADR-0011-traefik-edge-internal-proxy.md` — superseded by this decision