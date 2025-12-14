# Docker Swarm nodes

## Nodes

| Hostname        | Role    | IP range / VLAN    | Notes                | Host
|-----------------|---------|--------------------|----------------------|--------
| docker-swarm-01 | manager | 10.110.20.0/24     | main manager node    | PVE1
| docker-swarm-02 | worker  | 10.110.20.0/24     | worker node #1       | PVE1
| docker-swarm-03 | worker  | 10.110.20.0/24     | worker node #2       | PVE2

## Shared storage (NFS)

- NFS server: Proxmox host (storage node)
- Export path (ZFS dataset): `/tank/docker-swarm-data`
- Mount point on Swarm nodes: `/srv/swarm`
- Notes: shared persistent data for Swarm stacks via NFS

## Swarm overlay networks

- `traefik-proxy` – overlay network for Traefik ↔ docker-socket-proxy  
- `traefik-prod-apps` – overlay network for Traefik ↔ HTTP production services  
- `traefik-demo-apps` – overlay network for Traefik ↔ HTTP demo services  
- (add more here later if needed)

## Last update

2025-12-12
