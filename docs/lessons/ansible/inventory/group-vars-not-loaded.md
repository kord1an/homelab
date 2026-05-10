# Lesson: group_vars Directory Not Loaded
**Date:** 2026-03-03 | **Time Lost:** ~1.5h

## Problem
Ansible threw "undefined variable" errors for vault secrets (e.g., `ansible_operator_public_key`) when running `ansible-playbook playbooks/bootstrap.yml`. Ad-hoc commands from the project root worked fine.

## Root Cause
The `group_vars/` directory was placed in the project root. Ansible only loads `group_vars` automatically if it is located directly next to the **inventory file** or next to the **playbook file**. Since the playbook was in a subdirectory (`playbooks/`), it couldn't find the root `group_vars/`.

## Solution
Moved the variables to align with the inventory:
```bash
mv group_vars/ inventory/
```
Final structure: `inventory/group_vars/all/{vars.yml, vault.yml}`

## Prevention
Always place `group_vars/` inside the `inventory/` directory (or specific environment folder like `inventories/prod/`). This ensures variables are loaded consistently regardless of where the playbook is executed from.
