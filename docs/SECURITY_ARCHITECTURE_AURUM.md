# AURUM — Security Architecture (Defense-in-Depth)

**Version:** 2026-08-12  
**Status:** Implemented + Documented

## Philosophy
Zero Trust + Defense in Depth.  
No single layer is trusted. Every layer independently validates.

## Layered Security Model

### 1. DEVICE LAYER
- Platform-protected storage (flutter_secure_storage + Keychain / Keystore)
- Biometric APIs (local_auth) — **never** transmitted
- App Lock (background timeout + re-auth)
- Selective screen privacy (FLAG_SECURE on sensitive screens — planned)
- No root / jailbreak trust assumptions

**Controls:**
- AppLockService
- BiometricService (device-only)
- SecureSessionStore

### 2. APPLICATION LAYER (Flutter)
- No secrets embedded
- Strict input sanitization on deep links
- Client-side validation + server re-validation
- Data freshness indicators (untrusted market data)
- Secure error handling (no secrets in UI)

### 3. AUTHENTICATION LAYER
- Argon2id password hashing (backend)
- Opaque short-lived access tokens + refresh tokens
- SHA-256 token hashing on server
- Rate limiting per endpoint (login 10/min, password reset 5/15min)
- Generic error messages (no enumeration)
- Google OAuth — backend validates idToken only

### 4. SESSION LAYER
- Server-side `UserSession` records
- Access + Refresh token expiration
- Revocation support
- Device metadata (platform, last active)
- Touch on every authenticated request
- Sign-out this device / all other devices

### 5. API LAYER
- Fastify + helmet + rate-limit
- `authenticate()` middleware on every protected route
- Body size limit (64KB)
- Structured logging with redaction
- Safe error responses (never leak stack traces or internals)
- Versioned routes planned (`/api/v1`)

### 6. AUTHORIZATION LAYER (Zero Trust)
- **Every** resource access performs ownership check
- `requireAuthUserId()` + repository-level filters
- No trust of `userId` from client
- Prevents IDOR / BOLA

### 7. DATABASE LAYER
- PostgreSQL (least privilege)
- Parameterized queries via Prisma
- Encrypted connections (TLS)
- Cascade deletes
- No direct exposure to client

### 8. THIRD-PARTY LAYER
- All external data treated as untrusted
- Market data validated (timestamp, range, freshness)
- AI prompts isolated from system instructions
- Push notifications contain no secrets

### 9. MONITORING / AUDIT LAYER
- Security events model (planned full engine)
- Login history / device tracking
- Rate limit + abuse logging
- Future: Security dashboard

---

## Key Security Principles Enforced

| Principle                  | Implementation Status                  |
|---------------------------|----------------------------------------|
| Never trust client         | Server-side auth + ownership checks    |
| Short-lived tokens         | Access + Refresh with expiration       |
| Token rotation / revocation| Supported via sessions                 |
| Biometrics local-only      | Fully implemented                      |
| No secrets in Flutter      | Verified                               |
| Rate limiting              | Per-endpoint (backend)                 |
| Safe logging               | Redaction + safe errors                |
| Data minimization          | Ongoing (Privacy Center)               |
| Untrusted external data    | Freshness + validation                 |

---

## Current Implementation Highlights (V3)

- **First-Launch Safety Center** (complete with required acknowledgements)
- **App Lock** (configurable via Security Center + lifecycle)
- **Active Devices + Security Events** (Security Center)
- **Privacy / Legal disclosures** (Safety + Legal screens)
- **Secure token storage** (Flutter + backend hashing)
- **Strong password & reset flows**
- **Device registration** (backend)
- **DataFreshnessIndicator** (untrusted data protection)

---

## Remaining High-Priority Gaps (documented)

1. Full TOTP 2FA (backend schema ready, UI partial)
2. Step-up authentication for high-risk actions
3. Privacy Center full implementation (data export / delete)
4. Configurable App Lock timeouts UI (1m / 5m / 15m / Never)
5. Security event engine + real alerting
6. Selective screenshot protection
7. Comprehensive security test suite (manual + automated)

---

**This architecture document is the single source of truth for all future security decisions.**