# 🔀 Traefik Internal Proxy — Docker Swarm Deploy

## Purpose

Deploy internal Traefik instance in Docker Swarm for service discovery and routing within the cluster.

This layer handles:

* service discovery via Docker Swarm labels
* internal HTTP routing between services
* integration with external edge reverse proxy

---

## Prerequisites

* Docker Swarm initialized
* Overlay network available for service communication
* External edge proxy configured to forward traffic to this internal ingress layer

---

## Architecture

```text
External Traffic
    ↓
[ Edge Reverse Proxy ]
    ↓
[ Internal Traefik (Swarm) ]
    ↓
[ Swarm Services ]
```

Internal Traefik is responsible for routing traffic to services inside the Swarm network based on service labels.

---

## Step 1: Create shared overlay network

All Swarm services exposed via Traefik must join a shared overlay network.

```bash id="p1x8aa"
docker network create --driver overlay --attachable proxy-network
```

Verify:

```bash id="p7k2lm"
docker network ls | grep proxy-network
```

---

## Step 2: Deploy Internal Traefik

Internal Traefik runs on Swarm manager nodes and uses Docker socket for service discovery.

Key requirements:

* Swarm provider enabled
* Docker socket mounted read-only
* Default exposure disabled
* Runs on manager nodes only
* Connected to `proxy-network`

Deploy:

```bash id="t9q3vn"
docker stack deploy -c traefik-internal-stack.yml traefik-internal
```

---

## Step 3: Expose a service

Attach service to overlay network and define routing via labels.

```yaml id="l2w9cc"
services:
  my-service:
    networks:
      - proxy-network
    deploy:
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.my-service.rule=Host(`my-service.example.com`)"
        - "traefik.http.services.my-service.loadbalancer.server.port=8080"
```

---

### Important rules

* In Swarm, Traefik labels must be under `deploy.labels`
* Router rules use `Host()` matcher (no wildcards unless explicitly configured)
* Service must be attached to the same overlay network as Traefik

---

## Troubleshooting

| Symptom                        | Check              | Fix                               |
| ------------------------------ | ------------------ | --------------------------------- |
| Service not visible in Traefik | Swarm labels       | Ensure `deploy.labels` is used    |
| 502 Bad Gateway                | Network attachment | Verify `proxy-network` membership |
| Routing not working            | Host rule syntax   | Check `Host()` format             |
| No discovery                   | Traefik logs       | Inspect Traefik service logs      |

---

## Key insight

Internal Traefik acts as a **service discovery and routing layer inside Swarm**, independent of external ingress concerns.

> Edge proxy handles external access
> Internal Traefik handles cluster routing
