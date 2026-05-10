# 🧭 Runbook: Ansible Vault Secret Management

## Purpose

Manage encrypted secrets for Ansible using Vault, with separation between encrypted storage and runtime variables.

---

## Prerequisites

* Vault password file configured locally:

  * `~/.ansible_vault_pass` (permission: `600`)
* `ansible.cfg` configured with:

  ```ini
  vault_password_file = ~/.ansible_vault_pass
  ```

---

## 1. Create or edit secrets

```bash
ansible-vault edit inventory/group_vars/all/vault.yml
```

Add encrypted values using `vault_` prefix:

```yaml
vault_my_api_token: "secret_value"
```

---

## 2. Map secrets to runtime variables

Expose vault values via non-encrypted variables:

```yaml
# inventory/group_vars/all/vars.yml
my_api_token: "{{ vault_my_api_token }}"
```

---

## 3. Usage in playbooks

Use mapped variables directly:

```yaml
- name: Example task
  debug:
    msg: "{{ my_api_token }}"
```

---

## 4. Verification

Test decryption locally:

```bash
ansible localhost -m debug -a "var=my_api_token"
```

---

## 5. Git workflow rules

* Commit only encrypted files (`vault.yml`)
* Never commit vault password file

```bash
git add inventory/group_vars/all/vault.yml
git commit -m "Update vault secrets"
git push
```

---

## Key constraints

* Vault secrets are always stored in encrypted form (`vault_` namespace)
* Plain variables in `vars.yml` are safe to use in playbooks
* Password file must never leave local machine

---

## Insight

Vault is only storage encryption layer.

> Real security boundary is process discipline, not tooling.
