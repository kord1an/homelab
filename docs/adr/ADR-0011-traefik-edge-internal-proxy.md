# ADR-0011: Traefik as Edge + Internal Proxy in Container Orchestration

## Status

Accepted

## Context

The homelab required an internal reverse proxy for services deployed in a container orchestration environment and a bridge between edge and internal proxies. Exposing the Docker socket to a container was identified as an unacceptable security risk (privilege escalation vector). Traefik was chosen as the reverse proxy solution due to its robust features and ease of configuration.

## Decision

Deploy **two separate Traefik instances**:

1. **Edge Traefik** – handles external HTTPS traffic, wildcard certificate via DNS challenge. Has NO access to the container orchestration socket.
2. **Internal Traefik** – runs inside the orchestration environment, discovers services via labels. Routing between layers is managed by orchestration tools via a shared network.

## Consequences

**Positive:**

- New services deployed via orchestration commands are automatically discovered without any proxy reconfiguration.
- The container orchestration socket is not reachable from outside the environment even if the edge container is compromised.
- Declarative configuration (labels in service definitions) — ready for IaC/Ansible automation.

**Trade-offs:**

- Two Traefik instances instead of one — higher resource usage (acceptable in a homelab setting).
- More complex network topology (shared network, two routing layers).
- Labels do not work natively at the edge level — explicit domain configuration required per new wildcard entry.

## Related

- `docs/runbooks/ansible/traefik-orchestration-deploy.md`


## Superseded By
ADR-0015: traefik-kop + Redis for multi-host service discovery

Internal Traefik removed from Swarm. Edge Traefik handles all routing
via kop-based discovery. Docker socket security concern remains valid
and is addressed in ADR-0015.