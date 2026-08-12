# AURUM — Threat Model (V3)

**Date:** 2026-08-12  
**Version:** 1.0  
**Scope:** Flutter mobile app + Node.js/Fastify + PostgreSQL backend (Prisma)  
**Approach:** STRIDE + Defense-in-Depth + Zero Trust

---

## 1. Assets (What we protect)

### High-Value
- User account & identity
- Password hash (Argon2id)
- Access & Refresh tokens (SHA-256 hashed server-side)
- Sessions / Device registrations
- AI conversation history
- Watchlists & Alerts
- Security events / Login history
- Notification tokens (device push)

### Medium-Value
- User profile (name, email)
- Preferences & Notification settings
- Market data / AI analysis results (read-only)

### Low-Value
- Public market data

**Never stored or transmitted:**
- Raw biometrics
- Seed phrases / private keys (explicitly disallowed)
- Plaintext passwords / tokens

---

## 2. Trust Boundaries

1. **Device → App** (Flutter sandbox)
2. **App → Backend** (TLS only)
3. **Backend → Database** (internal VPC)
4. **Backend → 3rd parties** (Market providers, AI, Push, Google)
5. **User → App** (UI / deep links)

**Zero Trust Rule:** Nothing is trusted by default. Every API request is re-validated server-side.

---

## 3. Attack Surfaces

| Surface                  | Description                              | Exposure |
|--------------------------|------------------------------------------|----------|
| Flutter client           | Local storage, deep links, biometrics    | High     |
| Auth endpoints           | `/auth/*` (login, refresh, reset)        | Critical |
| Protected API            | Watchlist, alerts, AI history            | High     |
| Device registration      | Push token registration                  | Medium   |
| Deep links               | Asset, alert, security navigation        | Medium   |
| Notifications            | Push payload delivery                    | Medium   |
| AI / Intelligence        | User prompts + market context            | High     |
| Backend admin (future)   | —                                        | Critical |

---

## 4. Threat Actors

- **External Opportunist** — credential stuffing, brute force
- **Malicious User** — IDOR, account takeover via stolen token
- **Compromised Device** — malware, screen recording, rooted device
- **Insider / Supply-chain** — malicious dependency, malicious AI prompt
- **Advanced Persistent** — targeted phishing + token theft

---

## 5. Threat Catalog (Selected Critical/High)

### CRITICAL

| Threat | Impact | Likelihood | Mitigation | Detection | Recovery |
|--------|--------|------------|------------|-----------|----------|
| Authentication bypass (stolen access token) | Full account takeover | Medium | Short-lived access tokens + hashed refresh + revocation + server-side validation | Failed auth attempts, new device alerts | Revoke session + force re-auth + notify user |
| IDOR / BOLA (userId manipulation) | Cross-user data access | Medium | Server-side ownership verification on every resource | Abnormal access patterns | Immediate revoke + audit + user notification |
| Prompt injection via market data / external feeds | AI leaks secrets or executes malicious actions | Low | Treat all external content as untrusted; strict system prompt isolation | AI response anomaly detection | Rollback, rate-limit, human review |
| Token theft from insecure storage | Long-term impersonation | Low | flutter_secure_storage + biometric gating + token rotation | New device / unusual location | Global sign-out + password reset flow |

### HIGH

| Threat | Impact | Likelihood | Mitigation | Detection | Recovery |
|--------|--------|------------|------------|-----------|----------|
| Brute-force / credential stuffing on login | Account compromise | High | Rate limiting (10/min), progressive delays, generic errors, breached-password checks | Login anomaly detection | Account lockout + email notification |
| App lock bypass (background timeout) | Local data exposure | Medium | Configurable timeouts + biometric re-auth + lifecycle observer | — | Force re-auth on next launch |
| Deep-link parameter abuse | Unauthorized navigation or data leak | Medium | Validate destination + ownership + auth state server-side | — | Sanitize + redirect to safe state |
| Exposure of sensitive data in logs / error responses | Credential / token leak | Low | Redaction in logger + safe error messages | Log scanning | Incident response + key rotation |
| Biometric enrollment change attack | Stale biometric credential | Low | Invalidate on enrollment change detection (local_auth) | — | Fall back to password |

### MEDIUM / LOW

- Excessive AI requests → rate limits + abuse engine
- Stale market data → DataFreshnessIndicator + integrity checks
- Screenshot of recovery codes / security screens → selective FLAG_SECURE (Android)
- Supply-chain compromise → dependency audit + renovate + SBOM

---

## 6. Sensitive Data Flow

```
User enters password → Flutter (never stored raw)
  → TLS → Backend (Argon2id hash) → DB

Access token (opaque) → Flutter secure storage
  → TLS → Backend (SHA256 hash) → Session lookup + validation

Biometric → Device Secure Enclave / Keystore only
  → Unlocks local token (never leaves device)
```

**Zero Trust Validation Points:**
- Every protected route: `authenticate()` middleware
- Every resource: owner check in repository/controller
- Every token: hash comparison + expiration + revocation flag

---

## 7. Mobile-Specific Risks & Controls

| Risk                        | Control Implemented                              | Status |
|-----------------------------|--------------------------------------------------|--------|
| Insecure local storage      | flutter_secure_storage only                        | ✓      |
| Biometric raw data leakage  | Never transmitted; local_auth only               | ✓      |
| Screenshot of secrets       | Selective (future FLAG_SECURE on sensitive)      | Partial |
| Deep link injection         | Validation + ownership checks                    | In progress |
| App lock bypass             | Lifecycle + configurable timeout + re-auth       | ✓      |
| Reverse engineering         | Obfuscation + no embedded secrets                | ✓      |

---

## 8. Backend Security Controls (Current)

- Argon2id + SHA256 token hashing (excellent)
- Short-lived access + refresh tokens with revocation
- Per-route rate limiting (login 10/min, reset 5/15min, etc.)
- Helmet + body limit + redacted logs
- Server-side authorization on all protected routes
- Device registration + session metadata
- Password reset single-use expiring tokens

---

## 9. Gaps & Recommended Mitigations (V3)

1. **Step-up authentication** for sensitive actions (change password, disable 2FA, sign-out-all) — partially via App Lock.
2. **Full TOTP 2FA** (backend scaffolding exists via password-reset pattern).
3. **Client-side deep link validation service**.
4. **Privacy Center** with export/delete flows (UI started).
5. **Configurable App Lock timeouts** (1m/5m/15m/Immediate/Never) — implemented in this phase.
6. **Security event engine** with severity levels.
7. **Admin dashboard** (future — must be server-side only).
8. **Replay protection** on reset / security actions (nonce or short window).

---

## 10. Attack Tree Summary (Critical Path)

```
Steal credentials / token
  → Bypass rate limit? (NO — enforced)
  → Reuse expired token? (NO — validated)
  → Cross-user access? (NO — ownership check)
  → Escalate via AI prompt? (NO — untrusted input)
```

**Conclusion:** Architecture is already strong on authentication, token handling, and authorization. Focus for this phase: complete UI/UX for App Lock, Privacy Center, Security Education, step-up flows, and full threat documentation.

---

**Next:** See SECURITY_ARCHITECTURE_AURUM.md for layered controls.