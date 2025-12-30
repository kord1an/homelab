# Project: Minecraft Server Migration (LXC to Swarm)

## Phase 0: Legacy Setup (LXC + Tailscale)
Documentation of the previous battle with LXC, Tailscale, and networking is preserved here: 
[Link to your attached .md file or its content]

## Phase 1: Docker Swarm Prototype (2025-12-23)
Current goal: Move from LXC to a high-availability Swarm stack.

### Key Learnings so far:
- **Image:** Using `itzg/minecraft-server` - much simpler than manual LXC setup.
- **Networking:** Testing Swarm's routing mesh vs host mode for port 25565.
- **Storage:** Blocker identified - syncing world data across Swarm nodes (NFS vs Local).

### Status: WIP
Currently experimenting with a demo stack. Not ready for production runbook yet.
