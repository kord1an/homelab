# ADR-0013: Tailscale Single Entry Point with Split-DNS

## Status

Accepted

## Context

The homelab requires remote access for administrators and application users (family).
Initially, Tailscale was installed on multiple nodes (PVE host, AdGuard, reverse proxies), leading to split-brain DNS issues, routing loops, and complexity in ACL management.

## Decision

We will implement a **Single Entry Point** architecture:

1. Tailscale is installed *only* on a dedicated unprivileged LXC serving as a Subnet Router.
2. The Subnet Router exposes the internal VLANs (`10.x.0.0/16`) to the tailnet.
3. Tailscale is uninstalled from Proxmox hosts, AdGuard, and application containers.
4. MagicDNS is paired with Split-DNS restricted to the specific local domain, pointing to the local AdGuard IP.
5. Authorization is managed via Tailscale `grants` using Identity-Based Access Control (groups) and Device Tags for admin privilege elevation.

## Rejected Alternatives

- **Tailscale on every node (Service Mesh):** Rejected due to operational overhead, broken internal DNS resolution, and unnecessary encryption overhead for LAN traffic.
- **Always-on Full Tunnel:** Rejected to save battery on mobile devices and reduce upload bandwidth strain on the home internet connection.

## Consequences

- Increased dependency on the LXC (Single Point of Failure for remote access).
- Requires an Out-of-Band Management (OOBM) hardware VPN (e.g., WireGuard on Omada router) as a "break glass" recovery method.
- Network routing and Access Control Lists (ACLs) are vastly simplified.
