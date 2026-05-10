# 🛡️ Core Infrastructure (Guardian Node Concept)

## Overview

The Core Infrastructure layer is designed as an independent “guardian” system responsible for maintaining access, observability, and identity services even if the main compute cluster becomes unavailable.

Its primary goal is to ensure **continuous operability of the homelab control plane** under failure conditions.

---

## Design Philosophy

The system follows a strict principle:

> Core infrastructure must remain operational independently from workload infrastructure.

This ensures resilience for:
- network access
- identity services
- monitoring and alerting
- remote administration

---

## Responsibilities

The guardian layer provides:

### 🌐 Network Access Continuity
Ensures DNS resolution and basic network services remain available.

### 🔐 Identity & Access Management
Provides authentication services for infrastructure components.

### 📡 Observability
Monitors system health and external availability of core infrastructure.

### 🚪 Remote Access
Enables secure remote access to the environment during failure scenarios.

---

## Architecture Model

The system is structured into isolated service groups:

### Core Services Layer
Central infrastructure services responsible for:
- reverse proxying
- authentication
- dashboards
- notifications
- monitoring

These services are tightly integrated but logically isolated from workload systems.

---

### Satellite Services Layer
Independent services designed to operate without dependency on container orchestration layers.

Responsibilities:
- DNS resolution
- network routing assistance
- emergency access pathways

---

## Resilience Model

The system is designed around failure scenarios:

### Failure of Workload Cluster
- core services remain operational
- network access and monitoring continue
- remote access remains available

### Failure of Core Node
- fallback mechanisms ensure continuity of DNS and workload access
- backup recovery procedures restore core services from snapshots or backups

---

## Security Principles

- strict separation between core and workload systems
- authentication enforced at ingress layer
- minimal exposed attack surface
- remote access protected by VPN-based entry points

---

## Operational Summary

The guardian node acts as the control plane for the homelab, ensuring:
- observability
- access continuity
- identity management
- emergency recovery access

It is intentionally designed to be independent from the main compute environment.