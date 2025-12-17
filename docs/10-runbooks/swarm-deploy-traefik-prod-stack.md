# Runbook: Traefik deploy on Docker Swarm cluster 

**Last updated:** 2025-12-17  
**Frequency:** One-time

## Purpose

Deploy a new Traefik instance on the Docker Swarm cluster to act as the main ingress for homelab services, replacing the legacy Traefik running on `swarm-01` host with docker compose.

## Context

- **Environment:** Production (homelab core) 
- **Target system:** Docker Swarm Cluster (`swarm-01` manager, `swarm-02`/`swarm-03` workers) 
- **Related components:**
  - Legacy Traefik (Docker Compose on `swarm-01`)
  - Overlay networks: `traefik-prod-apps`, `traefik-demo-apps`
  - DNS: Cloudflare (via API Token)

## Prerequisites

- [ ] SSH access to Swarm Manager (`swarm-01`)
- [ ] User is in `docker` group
- [ ] Cloudflare API token created (DNS edit for homelab zone)
- [ ] Swarm secret `cf_api_token` created from Cloudflare token
- [ ] Overlay networks `traefik-prod-apps` and `traefik-demo-apps` exist:
  - `docker network ls | egrep 'traefik-prod-apps|traefik-demo-apps'`
- [ ] Ports `8080`, `8443`, `9090` are free on `swarm-02`/`swarm-03` (temporary test ports)
- [ ] No existing stack named `traefik-prod-1`:
  - `docker stack ls | grep traefik-prod-1 || echo "no existing stack"` 

## Steps

### 1. Preparation

1. SSH to the Swarm manager node:
   ```bash
   ssh <swarm-admin>@docker-swarm-01
   ```

2. Ensure the manager has network access to the Git hosting service (GitHub/Gitea) to download the stack file (e.g. `curl` / `wget` to repo URL). 

3. Verify Swarm node status:
   ```bash
   docker node ls
   ```
   Confirm `swarm-02` and `swarm-03` are `Ready` and `Active`.

4. Verify required overlay networks:
   ```bash
   docker network ls | egrep 'traefik-prod-apps|traefik-demo-apps'
   ```
   Create them if needed:
   ```bash
   docker network create --driver overlay --attachable traefik-prod-apps
   docker network create --driver overlay --attachable traefik-demo-apps
   ```

5. Verify Cloudflare secret:
   ```bash
   docker secret ls | grep cf_api_token
   ```

### 2. Execution

1. Download or sync the current version of the Traefik stack file to the manager, for example:
   ```bash
   mkdir -p /opt/swarm/prod/traefik
   # przykład – dostosuj URL do swojego repo (GitHub/Gitea)
   wget https://raw.githubusercontent.com/<user>/<repo>/main/stacks/traefik-prod-1.yml \
     -O /opt/swarm/prod/traefik/traefik-prod-1-stack.yml
   ```

2. Ensure the data/config directory exists on the NFS mount and is owned by the Traefik service account:
   ```bash
   sudo mkdir -p /srv/swarm/prod/traefik/traefik-prod-1/data
   sudo mkdir -p /srv/swarm/prod/traefik/traefik-prod-1/acme
   sudo chown -R svc-traefik:svc-traefik /srv/swarm/prod/traefik/traefik-prod-1
   ```

3. Edit the downloaded `traefik-prod-1-stack.yml` so that:
   - Volume paths point to:
     - `/srv/swarm/prod/traefik/traefik-prod-1/acme` for `acme.json` (cert storage)
     - Optional config directories under `/srv/swarm/prod/traefik/traefik-prod-1/…`
   - The service runs as `svc-traefik` (UID/GID of that account) via `user:` or `deploy.resources`/`labels` as needed.
   - The service is attached to:
     - `traefik-prod-apps` for production services
     - `traefik-demo-apps` for demo/test services
   - Published ports for test phase:
     - `8080` → HTTP (`entrypoint: web`)
     - `8443` → HTTPS (`entrypoint: websecure`)
     - `9090` → Dashboard

4. Deploy the stack using the edited file:
   ```bash
   docker stack deploy \
     -c /opt/swarm/prod/traefik/traefik-prod-1-stack.yml \
     traefik-prod-1
   ```

5. Wait a few seconds for Swarm to schedule and start all tasks:
   ```bash
   docker service ps traefik-prod-1_traefik
   ```

### 3. Verification

1. Check the stack and tasks on the manager:
   ```bash
   docker stack ps traefik-prod-1
   ```
   All `traefik-prod-1_traefik` tasks should be in `Running` state.

2. Verify that Traefik is listening on the expected ports on at least one worker node (e.g. `swarm-02`):
   ```bash
   ssh swarm-02
   sudo ss -tlnp | egrep '8080|8443|9090'
   ```

3. Open the Traefik dashboard in a browser:
   - URL: `http://<swarm-02-ip>:9090`
   - Expected: Traefik dashboard loads without errors.

4. (Optional) Deploy a simple test service (`whoami`) on `traefik-demo-apps` and verify routing:
   ```bash
   docker service create --name traefik-whoami-test \
     --network traefik-demo-apps \
     --label "traefik.enable=true" \
     --label "traefik.http.routers.whoami-test.rule=Host(`whoami.home.<twoja-domena>`)" \
     --label "traefik.http.routers.whoami-test.entrypoints=websecure" \
     --label "traefik.http.routers.whoami-test.tls.certresolver=cloudflare" \
     traefik/whoami
   ```

5. From a client that can reach the Swarm nodes, test HTTPS routing using `curl` with host override:
   ```bash
   curl -v -k --resolve whoami.home.<twoja-domena>:8443:<swarm-02-ip> \
     https://whoami.home.<twoja-domena>:8443/
   ```
   Expected:
   - Successful TLS connection
   - Body containing request/hostname data from `traefik/whoami`.

6. Remove the temporary test service:
   ```bash
   docker service rm traefik-whoami-test
   ```

## Rollback

If the deployment needs to be reverted:

1. Remove the stack from the Swarm cluster:
   ```bash
   docker stack rm traefik-prod-1
   ```

2. Confirm that no tasks or services related to `traefik-prod-1` remain:
   ```bash
   docker stack ls | grep traefik-prod-1 || echo "stack removed"
   docker service ls | grep traefik-prod-1 || echo "no services"
   ```

3. Optionally remove the stack file and data directory if no longer needed:
   ```bash
   rm -f /opt/swarm/prod/traefik/traefik-prod-1-stack.yml
   # Only if you are sure Traefik data (including ACME) can be discarded:
   # sudo rm -rf /srv/swarm/prod/traefik/traefik-prod-1
   ```

4. Verify that legacy Traefik on `swarm-01` still serves existing services correctly (open current production URLs).

## Notes / Troubleshooting

- If tasks stay in `Pending` or `Failed` state:
  - Check node availability:
    ```bash
    docker node ls
    ```
  - Check image pull or startup errors:
    ```bash
    docker service logs traefik-prod-1_traefik --tail 50
    ```

- If HTTP/HTTPS requests do not reach Traefik:
  - Verify which ports are published in the stack file (`8080`, `8443`, `9090`).
  - Ensure no local firewall blocks access to published ports on Swarm nodes.
  - Confirm that test `curl` commands use correct IP and port combinations.

- This runbook deploys Traefik in **parallel** to the legacy instance and does **not** change DNS for production services yet. Cutover of `*.home.<twoja-domena>` to the Swarm-based Traefik should be handled in a separate runbook.
- If runbook and server differ, treat Gitea repo + Ansible as the source of truth, then update this runbook accordingly (runbook is documentation of the process, not configuration).