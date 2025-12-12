# How to: Setup SSH key for GitHub

## Generate new key

	ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519_github

## Copy public key

	cat ~/.ssh/id_ed25519_github.pub

## Add to GitHub

1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Title: `homelab-workstation`
4. Paste key
5. Add SSH key

## Configure SSH

Edit `~/.ssh/config`:

	Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_ed25519_github
	IdentitiesOnly yes

## Test

	ssh -T git@github.com

Expected: `Hi USERNAME! You've successfully authenticated...`

---
Created: 2025-12-12
