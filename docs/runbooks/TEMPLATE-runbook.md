# Runbook: <Operation Name>

**Last updated:** YYYY-MM-DD  
**Frequency:** One-time / On-demand / Recurring

## Purpose

Short description of what this procedure does and why it is needed.

## Context

- **Environment:** prod / lab / test
- **Target system:** host / cluster / service
- **Related components:** stacks, services, dependencies

## Prerequisites

- [ ] SSH access to the target system
- [ ] User allowed to run `docker` / `docker stack` (if applicable)
- [ ] Backup completed (if applicable)
- [ ] No conflicting maintenance in progress

## Steps

### 1. Preparation

Checks to perform before making any changes (current status, health, free ports, etc.).

### 2. Execution

Main actions, in numbered order.  
Each step should be small enough to execute and verify safely.

### 3. Verification

How to confirm success:

- Commands to run
- Expected output / behaviour
- Any monitoring or dashboards to check

## Rollback

Actions to restore the previous state if this procedure fails or must be reverted.

## Notes / Troubleshooting

Known issues, common pitfalls, useful log locations, and links to related docs.
