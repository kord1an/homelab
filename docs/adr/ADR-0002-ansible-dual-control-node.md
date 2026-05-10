# ADR-0002: Dual Ansible Control Node (LXC + Laptop)

**Status:** Accepted | **Date:** 2026-03-03

## Context

Initial architecture used only a dedicated LXC Control Node. This slowed down development (writing code locally required `git push` -> SSH to LXC -> `git pull` -> run).

## Decision

Use a dual-node approach:

1. **Laptop:** For development, testing, and writing playbooks. Provides immediate execution loop.
2. **LXC Node:** For production, automated, and scheduled runs.

## Consequences

- **Positive:** Fast iteration local development; LXC remains the source of truth for cron jobs.
- **Negative:** Requires managing `.ansible_vault_pass` on two machines manually.
- **Security:** Vault password files must be kept out of Git (`.gitignore`) and have `chmod 600`.
Both nodes use the same Git repository, inventory, and encrypted vault file.
