# Lessons: Authentik SSO — Proxmox VE Integration

## PVE `prompt=none` Causes Login Loop on Session Expiry

**Problem:** After PVE session expires, browser does not redirect to Authentik
login page. Instead, URL changes to `/?error=login_required&error_description=
The%20Authorization%20Server%20requires%20End-User%20authentication` and loops.

**Cause:** PVE sends `prompt=none` in every OAuth2 authorization request.
This instructs Authentik to authenticate the user silently — without showing
the login page. When the Authentik session has expired, it cannot do so and
returns `login_required`. PVE does not handle this response correctly and loops
instead of redirecting to the login page.

Confirmed in Authentik logs — look for this combination:

```json
"prompt": "none"
"status": 302
"event": "login_required"
```

**Fix:** Change `prompt` value in PVE realm config from `none` to `login`:

```bash
pveum realm modify authentik --prompt login
```

Verify the change:

```bash
cat /etc/pve/domains.cfg
```

Expected result in `domains.cfg`:

```
openid: authentik
    prompt login
    ...
```

**Rule:** Never use `prompt=none` with Authentik in PVE unless you have
persistent Authentik sessions longer than PVE token TTL. Default or `login`
is the correct value for standard SSO setups.

## Authentik Log Signals to Watch

When debugging PVE → Authentik SSO issues, filter logs with:

```bash
docker logs authentik-server --tail 100 2>&1 | grep -i "login_required\|prompt\|pve"
```

| Log field | What to look for |
|---|---|
| `"prompt": "none"` | Silent auth requested — will fail on expired session |
| `"status": 302` + `login_required` | Authentik redirecting back with error instead of login page |
| `"authorized_application"` | Successful auth — confirms flow completed |
| `"redirect_uri"` | Must match exactly the URL registered in Authentik Application |
