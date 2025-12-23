# Minecraft Server (Docker Swarm Migration)

## Status: 🚧 Work In Progress / Experimental
This project documents the migration of a Minecraft server from a legacy Proxmox LXC container to a Docker Swarm cluster.

## Context & The "Battle"
The previous configuration relied on a standalone LXC container integrated with Tailscale for connectivity. I am currently transitioning to Swarm to centralize service orchestration and improve high availability (HA).

## Project Structure
- `minecraft-stack.yml` – Docker Swarm stack definition.
- `docs/projects/minecraft-swarm/progress.md` – Engineering logs and network troubleshooting notes.

## Quick Start (Prototype)
To deploy the current demo stack to your cluster:
