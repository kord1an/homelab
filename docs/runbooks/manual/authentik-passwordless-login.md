# Authentik Passwordless Login — Passkey (WebAuthn) Setup

## Purpose

Configure **passwordless authentication** in Authentik using a hardware security key (YubiKey) or platform authenticator.
Users log in by touching a security key — no password prompt.

Tested on Authentik **2026.2.2**.

## Prerequisites

- Authentik admin access
- At least **2x WebAuthn-compatible devices** (e.g. YubiKey)
- Active admin session open in a **second browser tab** as fallback — do not close until testing is complete

## Step 1: Enroll Security Keys

> Enrollment is done in the **User Interface**, not Admin Interface.

Navigate to `https://<your-authentik-domain>/if/user/`, go to **Settings → MFA Devices** and click **Add WebAuthn Device**. Follow the browser prompt and touch the YubiKey when asked.

Repeat for the **second device**. Both keys must be enrolled before proceeding.

## Step 2: Create Passwordless Flow

Go to **Admin Interface → Flows & Stages → Flows → Create**.

| Field | Value |
|---|---|
| Name | `sensiblename-passwordless-flow` |
| Slug | `sensiblename-passwordless-flow` |
| Designation | `Authentication` |
| Title | `Passwordless Login` |

## Step 3: Create and Bind Stages

**Authenticator Validation Stage** — **Stages → Create → Authenticator Validation Stage**:

| Field | Value |
|---|---|
| Name | `sensiblename-passwordless-webauthn` |
| Device classes | `WebAuthn` only |
| Not configured action | `Force the user to configure an Authenticator` |

**Bind default or created User Login Stage**:

| Field | Value |
|---|---|
| Name | `default-authentication-login` |
| Rest | defaults |

Bind both stages to the `sensiblename-passwordless-flow` flow under **Stage Bindings**:

| Order | Stage |
|---|---|
| 10 | `sensiblename-passwordless-webauthn` |
| 20 | `default-authentication-login` |

## Step 4: Link to Default Authentication Flow

Go to **Flows → default-authentication-flow → Stage Bindings → Identification Stage → Edit**.
Set the **Passwordless flow** field to `sensiblename-passwordless-flow`. Save.

This adds a passkey option to the standard login screen.

## Step 5: Test

Open a **new private/incognito window**, navigate to the Authentik login page and select the passkey option.
Touch the YubiKey — login must complete without a password prompt.
Repeat with the second YubiKey.

## Troubleshooting

| Symptom | Check | Action |
|---|---|---|
| Passkey option not visible | Identification Stage config | Verify **Passwordless flow** field is set |
| "Not configured" error | User MFA Devices | Confirm device enrolled at `/if/user/` |
| Browser does not prompt for key | Protocol | WebAuthn requires HTTPS — verify domain uses TLS |
| Enrollment not visible | Wrong interface | Use `/if/user/`, not `/if/admin/` |

## References

- [Authentik WebAuthn Stage docs](https://docs.goauthentik.io/add-secure-apps/flows-stages/stages/authenticator_webauthn/)
- [Authentik Passwordless Login (YouTube)](https://www.youtube.com/watch?v=aEpT2fYGwLw)
