# GitHub ↔ Gitea workflow for Swarm

## Purpose

This document explains how GitHub and the private Gitea instance are used together in the homelab, and why both systems are kept.  
It defines which repository is the source of truth for documentation, templates, and operational Swarm stacks.

## Roles of repositories

- **GitHub (public)**
  - Hosts documentation, architecture notes, and generic templates for services.
  - Contains only placeholders and example values, never real secrets or environment‑specific data.

- **Gitea (private, self‑hosted)**
  - Hosts operational repositories used directly by Swarm manager nodes.
  - Contains real stack definitions and configuration files for the homelab environment.

## Workflow overview

1. New stacks or changes are developed on the workstation in GitHub-backed repositories (for example under `swarm/`).
2. When a template is ready for use, the relevant stack file is downloaded from GitHub into the appropriate Gitea repository (for example using `wget` or manual copy).
3. Changes are committed and pushed in Gitea, which becomes the operational source of truth for Swarm stacks.
4. On the Swarm manager, the Gitea repo is pulled and stacks are deployed from there using `docker stack deploy` with the files stored in the repo.

## Security rules

- Public GitHub repositories never store real tokens, passwords, private keys, or detailed internal IP addresses; only examples and placeholders are committed.
- Private Gitea repositories and Swarm nodes do not use real `.env` files and production configuration - `.gitignore` excludes those from version control where appropriate.

## Future evolution

- Manual deployment (SSH + `docker stack deploy`) can later be replaced by CI/CD pipelines that pull from Gitea or GitHub and perform automated rollouts.
- When CI/CD is introduced, only the Execution section in runbooks should change; the overall repository roles and documentation structure stay the same.