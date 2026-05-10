# ADR-0006: Exclude mgmt Group from Automated Update Strategy

## Status

Accepted

## Context

Ansible Control Node is running in a dedicated LXC.
Including it in any automated update group risks interrupting playbook
execution mid-run if the node reboots during an upgrade.

## Decision

The [mgmt] group is excluded from safe_to_update and critical_services.
Updates are applied manually via `--limit` from local machine only.

## Consequences

- No automated updates on Ansible control node
- Operator must remember to update manually on a regular basis
- No risk of playbook interruption during upgrades
