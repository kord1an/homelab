# Lessons Learned: Ansible Role Best Practices

## Issue 1: Using `copy` vs `template` Module

When using Ansible, always use the `ansible.builtin.template` module for Jinja2 files (`.j2`). The `ansible.builtin.copy` module does not render Jinja2 variables.

## Issue 2: Proper Placement of Configuration Commands

Ensure that configuration commands like `exportfs -ra` are placed in handlers rather than regular tasks. This prevents unnecessary execution and ensures the command runs only when changes occur.

## Issue 3: Scope Plays to Specific Groups

When defining plays, explicitly scope them to specific groups to avoid unintended application. For example, if a role is intended for LXC/VMs only, limit it to those groups.

## Issue 4: Match Group Names in `group_vars`

Ensure that the folder names in `group_vars` exactly match the inventory group names. Mismatches can lead to undefined variables at runtime.