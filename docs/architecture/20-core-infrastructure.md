# Core Infrastructure (The Guardian Node)

## 1. Philosophy & Objective
This document outlines the architecture of the **PVE2 (Edge Node)**. Unlike the main compute cluster (PVE1/Swarm), this node acts as the **"Guardian"**.

**Primary Directive:** `Zero Dependency on PVE1`.
If the main server (PVE1) fails, burns down, or loses power, PVE2 must remain operational to ensure:
1.  **Internet Access** (DNS Resolution).
2.  **Remote Access** (VPN/Tailscale).
3.  **Monitoring & Alerting** (Uptime Kuma, Gotify).
4.  **Identity Management** (Authentik).

## 2. Logical Architecture

The node hosts critical services using a hybrid model for maximum reliability:
*   **LXC `infra-core`:** Monolithic Docker Compose stack for management tools.
*   **LXC `adguard2`:** Isolated Secondary DNS.
*   **LXCs `ts-gw-*`:** Isolated Subnet Routers for different VLANs.

## 3. Core Docker Stack (`/opt/docker/core`)

All management services run within Docker Compose stacks. They are interconnected via `core_net` and do not expose ports to the host (with specific exceptions), relying entirely on Traefik for ingress.

| Service | Role | Internal Port | Notes |
| :--- | :--- | :--- | :--- |
| **Traefik** | Reverse Proxy | 80/443 | EntryPoint. Uses DNS Challenge (Cloudflare) for `*.core.korpau.ovh` certs. |
| **Authentik** | SSO / IDP | 9000 | Protects all other services. Runs on embedded DB or local Postgres within the stack. |
| **Uptime Kuma** | Monitoring | 3001 | "Dead Man's Switch". Monitors PVE1, WAN, and critical paths. |
| **Gotify** | Notifications | 80 | Push Notification Server. Local storage. |
| **Apprise** | API Gateway | 8000 | Notification translator. Exposed on `host:8000` for local bash scripts. |
| **Portainer** | Management | 9000 | UI for managing this specific Docker instance. |
| **Dozzle** | Logs | 8080 | Real-time log viewer for debugging startup issues without SSH. |
| **Homepage** | Dashboard | 3000 | Central landing page. Integrates via `docker.sock`. |

### Security Measures
1.  **Traefik API:** Accessible only via domain, protected by Authentik Middleware. `insecure` mode disabled.
2.  **Apprise API:** Public access (via Traefik) protected by Authentik. Local access (via IP) open for system scripts.
3.  **SSH:** Root login disabled, key-based authentication only.

## 4. Satellite Services (LXC)

These services run outside of Docker to reduce overhead and eliminate dependencies on the Docker daemon.

### AdGuard Home
*   **Purpose:** Secondary DNS.
*   **Config:** Set as Secondary DNS in Router DHCP.
*   **Dependency:** None. Functions even if Docker service fails.

### Tailscale (Subnet Routers)
*   **Purpose:** Emergency "Backdoor" access.
*   **Config:** Advertises routes `10.110.X.0/24`.
*   **Dependency:** None. Allows SSH access to PVE2 even if Traefik is down.

## 5. Disaster Recovery Protocols

### Scenario: PVE1 Failure (Main Server Down)
1.  PVE2 remains operational.
2.  Uptime Kuma detects PVE1 packet loss -> Sends alert to mobile (via Gotify/Tailscale).
3.  Home DNS resolution continues (via AdGuard on PVE2).
4.  Admin logs in via Tailscale/VPN to PVE2 Homepage to assess the situation.

### Scenario: PVE2 Failure (Guardian Down)
1.  **Immediate Impact:** No notifications sent from PVE2 (unless external monitoring is active). Secondary DNS goes offline (Primary DNS on PVE1 handles traffic seamlessly).
2.  **Failover Mechanism:**
    *   **ZFS Replication:** The `infra-core` LXC container is replicated to PVE1 (every 15min).
    *   **Action:** If PVE2 hardware fails, the `infra-core` container can be immediately started on PVE1 to restore monitoring and management dashboards.
3.  **Recovery (Total Hardware Loss):**
    *   If replication is unavailable: Restore LXC backup from PBS (Proxmox Backup Server).
    *   If no backups exist: Create fresh LXC, `git clone` the `infra-core` repo, and run `docker compose up -d`.

## 6. Implementation Details & "Gotchas"
*   **Traefik Loopback:** The Traefik dashboard is proxied by Traefik itself using the `api@internal` service. Port 8080 is NOT exposed to the host.
*   **Apprise Local Access:** Bash scripts on the host hit `http://172.X.X.X:8000` (bypassing Auth), while external access requires SSO.
*   **Homepage Discovery:** The dashboard uses `docker.sock` to auto-discover services based on `homepage.*` labels.
```