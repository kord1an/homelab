# ADR-0008: Samba Fileserver — Manual Setup, Not IaC

## Status

Accepted

## Date

2026-03-18

## Context

A temporary fileserver was needed to provide SMB shares for home users
(Windows, Linux, Android) backed by ZFS datasets on pve1.
The solution was identified as temporary, with a planned future migration
to Docker Swarm.

## Decision

Samba was set up manually on a Debian 12 LXC instead of being managed
by Ansible role. Writing and maintaining an Ansible role for a short-lived, temporary service was considered overhead without proportional value.

## Consequences

- Faster delivery, no IaC overhead for temporary service
- Configuration is not reproducible via Ansible — documented in runbook instead
- When migrating to Swarm, a proper Docker Compose stack + Ansible role
  will be written from scratch
- Runbook: `docs/runbooks/manual/samba-fileserver.md`

## Alternatives Considered

- **Ansible role `samba`** — rejected, too much overhead for temporary solution
- **Nextcloud** — rejected, overkill for current needs; revisit in future
