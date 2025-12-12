# Git basics (cheat sheet)

## Commit message convention
Commit messages follow this convention:

`<type>: <short description>`

Examples:

- `feat: add Authentik middleware`          – new feature
- `fix: fix container's DB connection`      – bug fix
- `docs: add runbook for Traefik migration` – documentation only
- `chore: initial repository structure`     – maintenance, setup, config
- `refactor: optimize docker-compose.yml`   – code change without new features
- `style: formatting change`                – whitespace, formatting, no logic
- `test: add unit test`                     – tests only

## Typical workflow

Typical flow for changes:

1. Edit files
2. Check status

		git status

3. Stage files

		git add <file> # single file
		git add . # everything (careful!)

4. Commit with message

		git commit -m "type: short description"

5. Push to remote

		git push

## Useful commands

Some useful commands:

Show history (short)

	git log --oneline --graph --decorate

See what will be committed (staged changes)

	git diff --staged

See local changes (not staged)

	git diff

Undo last commit, keep changes staged

	git reset --soft HEAD~1

Undo staging (keep changes in files)

	git reset HEAD <file>

## Safety reminders

- Always check `git status` before `git commit`
- Never commit secrets:
  - `.env` files
  - API tokens, passwords, SSH private keys
- Use `.gitignore` to exclude sensitive or generated files
- For experiments, create a separate branch instead of pushing directly to `main`
