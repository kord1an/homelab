# Homelab Lab

A curated collection of architecture notes, infrastructure patterns and operational lessons from my personal homelab.

This repository focuses on:
- infrastructure design decisions
- Docker Swarm experiments
- edge/core/lab separation
- Ansible automation patterns
- networking and storage concepts
- operational lessons learned

Production deployments, sensitive configuration and day-to-day operational state remain private.

---

## Architecture Philosophy

The homelab is separated into three logical layers:

### Edge / Core Infrastructure
Always-on infrastructure responsible for routing, authentication and operational visibility.

Examples:
- Traefik
- Authentik
- Uptime Kuma
- Dozzle

### Workloads
User-facing and household services running primarily on standalone Docker hosts.

Examples:
- media services
- game servers
- personal applications

### Lab / Experiments
Infrastructure used for experimentation, orchestration learning and architectural testing.

Examples:
- Docker Swarm
- automation experiments
- GPU scheduling
- networking tests

---

## Goals

This repository is not intended to be:
- a full production dump
- a copy of the live environment
- a turnkey deployment

Instead, it documents:
- architectural decisions
- reusable infrastructure patterns
- operational lessons
- tradeoffs and experiments

---

## Repository Structure

```text
docs/       Architecture notes, ADRs, lessons learned
examples/   Isolated infrastructure examples
diagrams/   Draw.io/Excalidraw diagrams and topology sketches
```

---

## Topics

- Docker
- Docker Swarm
- Ansible
- Traefik
- Proxmox
- ZFS
- Networking
- Self-hosting
- Infrastructure as Code

---

## Why This Repository Exists

The goal of this repository is to document infrastructure thinking rather than expose a full live environment.

It serves as:
- a technical notebook
- an architecture journal
- a collection of reusable infrastructure patterns
- a long-term learning archive