# 🚀 Runbook: Initialize Docker Swarm via Ansible

## When to use

First-time setup of a Docker Swarm cluster on a set of nodes where Swarm is not yet initialized.

Playbook is idempotent — safe to re-run.

## Prerequisites

- `docker` role applied to all nodes:
  - `swarm_managers`
  - `swarm_workers`
- Inventory contains groups:
  - `swarm_managers`
  - `swarm_workers`
- SSH access to all nodes is working
- Docker daemon is running on all targets

## Run

```bash
ansible-playbook site.yml
```

## Verification

- `failed=0` across all hosts
- `Debug Swarm Nodes` outputs expected cluster membership
- `Assert Swarm Active` passes

Optional manual check:

```bash
docker node ls
```

## Related files

- `ansible/roles/swarm/tasks/main.yml`
- `docs/adr/ADR-0001-swarm-token-source.md`
