# host_vars Not Loaded — File Placed in Wrong Directory

## Problem
Variable file created under group_vars/korpau1/ instead of
host_vars/korpau1/ — Ansible silently ignored the file, returning
"variable is undefined".

## Diagnosis
ansible korpau1 -m ansible.builtin.debug -a "var=nfs_client_network"
returned VARIABLE IS NOT DEFINED despite file existing on disk.

## Root Cause
host_vars/ must live at the same level as the inventory file:
ansible/inventory/host_vars/korpau1/vars.yml
NOT: ansible/inventory/group_vars/korpau1/vars.yml

## Fix
Move file to correct path. No changes to hosts.ini or ansible.cfg required.
Ansible discovers host_vars/ automatically by hostname match.
