# Incident: <short problem description>

## Date
YYYY-MM-DD

## Context
- System / component: <e.g. Docker Swarm cluster with NFS-backed storage>.
- Scope: <which hosts / services / environment are affected>.
- Brief description of the state before the incident (what was working, key dependencies).

## Symptoms
- What exactly stopped working (technical symptoms, error messages, log excerpts).
- On how many / which nodes or services the issue appeared.
- Frequency: always, intermittent, only on reboot, only under load, etc.

## Initial hypothesis
- First guesses about the root cause (e.g. race condition, misconfiguration, network issue).
- Which dependencies might be involved (e.g. network-online, VPN, NFS, Docker, database).

## Actions taken (attempts)
- Step-by-step list of diagnostic and remediation actions.
- What was changed (high level – configuration, code, architecture), without full file dumps.
- Outcome of each attempt (partial success / no effect / made things worse, then reverted).

## Current status (if not yet resolved)
- Whether the problem is still reproducible.
- Whether the system was reverted to a known-good configuration as a temporary measure.
- Current most likely root-cause assumption.
- Links to any additional logs, dashboards or notes.

## Final fix (when resolved)

### Change summary
- Final configuration/code/architecture changes that addressed the issue.
- Where the changes were applied (which hosts, repositories, services).

### Verification
- How the fix was validated:
  - which commands/tests were executed,
  - how many times (e.g. multiple reboots, load tests),
  - which metrics or logs were checked.

### Outcome
- Final status: **resolved** / **mitigated** / **accepted risk**.
- Any remaining risks or follow-up items to monitor.
- See also: links to related runbooks, design decisions, diagrams, or KB articles.
