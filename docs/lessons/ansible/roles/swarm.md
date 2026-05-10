# Lessons: Ansible Roles (Swarm)

## 2026-03-02

This document captures recurring issues encountered while working with Ansible roles for Docker Swarm management.

---

## 1. Task Directives vs Module Parameters

### Problem
Task-level directives were incorrectly placed inside module parameters instead of being defined at the task level.

### Impact
Ansible silently ignored task behavior such as variable registration, leading to missing runtime data.

### Root Cause
Misunderstanding of Ansible execution structure:
- module parameters control module behavior
- task directives control execution logic

### Lesson
> Task directives (e.g. `register`, `when`, `delegate_to`) must always be defined at task level, not inside module arguments.

---

## 2. Incorrect Conditional Logic in State Checks

### Problem
Conditional logic for detecting system state was inverted, causing unnecessary execution of initialization logic.

### Impact
Idempotency was broken, leading to redundant operations on already configured systems.

### Root Cause
Assuming state flags represent “action required” instead of “state already achieved”.

### Lesson
> State-check conditions must always explicitly represent desired idempotent behavior: actions should run only when state is missing or invalid.

---

## 3. Missing Module Parameters in Output Queries

### Problem
Swarm inspection data was incomplete because required module parameters were not explicitly enabled.

### Impact
Downstream logic relying on node metadata failed due to missing data fields.

### Root Cause
Assuming default module output includes all available information.

### Lesson
> Always explicitly define required data scope when querying system state — default outputs are often minimal.

---

## Summary

Most issues encountered in Ansible automation stem from:
- misunderstanding execution vs configuration layers
- incorrect assumptions about default module behavior
- lack of explicit state definition in idempotent logic