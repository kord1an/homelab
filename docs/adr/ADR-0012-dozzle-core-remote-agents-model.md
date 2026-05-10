# ADR-0012: Dozzle Deployment Model — Core + Remote Agents vs Swarm-Native

## Status

Accepted

## Context

Dozzle supports two deployment models on Docker Swarm:

1. **Swarm-native mode** — single Dozzle instance with Docker socket mount,
   discovers all nodes automatically via Swarm API.
2. **Core + remote agents** — central Dozzle Core (no socket) connects to
   lightweight agents deployed globally across all nodes.

The native Swarm mode requires mounting Docker socket on a globally-deployed
service, exposing it on every node — an unnecessary security surface.
The Core + agents model limits socket exposure to agent containers only,
while Core itself remains socket-free.

## Decision

Deploy Dozzle as **Core + explicit remote agents** (`mode: global`).
Core runs on `[swarm_managers]`, constrained via placement.
Agents run on all nodes, port published with `mode: host` to bypass
Swarm ingress routing mesh (required for correct Agent ID resolution —
see `docs/lessons/docker/swarm/dozzle-swarm-nodes-visibility.md`).

## Consequences

**Gained:**

- Docker socket not exposed on Core container
- Each node independently identified by Agent ID
- All nodes visible and stable in Dozzle UI

**Trade-offs:**

- Port 7007 must be free on every Swarm node (host port conflict risk)
- Agents not reachable via Swarm ingress VIP — direct node IP required
- Additional service to manage vs single-container native mode

## References

- Lessons: `docs/lessons/docker/swarm/dozzle-swarm-nodes-visibility.md`
- Related: # ADR-0011: Traefik as Edge + Internal Proxy in Docker Swarm
