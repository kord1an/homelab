# ADR-0001: Join Token Source for Swarm Workers

## Status

Accepted

## Context

The `swarm` role initializes the manager and joins workers in a single playbook run.
The join token must be available after manager initialization.

## Decision

Token is sourced from `swarm_info_fresh` — a dedicated
`community.docker.docker_swarm_info` task executed after manager init,
scoped to `swarm_managers[0]` via `delegate_to` + `run_once`.

## Rejected Alternatives

- `swarm_info` (pre-init) — `swarm_facts` is empty when node is not yet in a swarm
- `swarm_init` (register from `docker_swarm`) — module does not return `swarm_facts`

## Consequences

One extra task in the role, but the logic is explicit and idempotent.
