# ADR-0007: site.yml Master Playbook Structure

## Status

Accepted

## Context

The project requires a single entry point for Ansible automation
that maps host groups to roles in a predictable, maintainable way.
Initial version had several issues: invalid group syntax
(debian:children), duplicated swarm plays, missing become directives.

## Decision

site.yml is structured as one play per functional role:

- hosts: debian — role: common (base configuration for all Debian hosts)
- hosts: swarm  — role: docker (engine installation)
- hosts: swarm  — role: swarm (manager init / worker join via when:)
- hosts: pve1   — role: nfs_server (NFS on bare metal PVE)
- hosts: pve1   — role: pve_base (TODO — placeholder)

All plays use become: true and gather_facts: true.
Swarm manager/worker distinction is handled inside the role
via when: inventory_hostname in groups['swarm_managers'].

## Consequences

- Single ansible-playbook site.yml --check validates entire infrastructure
- Adding new service = new play at the bottom, no touching existing plays
- pve_base role is a placeholder until PVE base configuration is defined
