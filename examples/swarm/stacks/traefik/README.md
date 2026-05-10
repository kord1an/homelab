
# Traefik Swarm Stack (Template)

This directory contains a **template** for deploying Traefik as a reverse proxy on a Docker Swarm cluster.  
The stack is parameterized via a `.env` file and deployed using `deploy.sh`.

## Files

- `traefik-stack.yml` – Docker Swarm stack template for Traefik.
- `.env.traefik.template` – example `.env` file with all required variables.
- `deploy.sh` – helper script to load `.env` and deploy the stack.

## Prerequisites

- Docker Swarm initialized and running.
- An external overlay network named `traefik-public`:
  ```
  docker network create --driver overlay traefik-public
  ```
- A Swarm secret containing the Cloudflare API token, for example:
  ```
  echo "YOUR_CF_API_TOKEN" | docker secret create cf_api_token -
  ```

## Usage

1. **Copy this directory** to your Swarm manager node.

2. **Create the `.env` file** based on the template:
   ```
   cp .env.traefik.template .env
   nano .env
   ```
   Adjust at least:
   - `TRAEFIK_DATA_ROOT` – e.g. `/srv/swarm/prod/traefik/traefik-prod-1`
   - `TRAEFIK_NODE_HOSTNAME` – hostname of the node where Traefik should run
   - `TRAEFIK_ACME_EMAIL` – e‑mail address for Let's Encrypt
   - `TRAEFIK_HTTP_PORT`, `TRAEFIK_HTTPS_PORT`, `TRAEFIK_DASHBOARD_PORT` – published ports

3. **Deploy the stack**:
   ```
   ./deploy.sh traefik-stack
   ```

4. **Verify deployment**:
   ```
   docker stack services traefik-stack
   docker service logs traefik-stack_traefik -f
   ```

5. **Access the Traefik dashboard**:
   - Via IP and port: `http://<node-ip>:9090`
   - Via router: `https://traefik.<your-domain>` (once DNS and TLS are correctly configured)

## Notes

- This template is meant as a **starting point**; review ports, paths and security settings before using in production.
- Cloudflare API token should always be stored as a **Swarm secret**, never in `.env` or Git.
