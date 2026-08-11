# AURUM Privacy Policy — publication draft

**Effective date:** To be set at launch
**Operator:** `[Legal entity name]`
**Privacy contact:** `[privacy contact email/address]`

> This draft reflects the current AURUM source architecture. It is not a substitute for legal review. Before publication, replace bracketed operator/contact details, list the actual hosting, market-data, AI, push, mail, monitoring and analytics providers, and align retention periods with the deployed configuration.

## 1. Scope

AURUM is a cryptocurrency market-analysis and decision-support application. It offers market information, technical-analysis context, watchlists, alerts, structured intelligence, account settings and notifications. AURUM does not provide custody or exchange-order execution.

## 2. Information processed

| Category | Why it is processed | Storage/access |
| --- | --- | --- |
| Name and email | Create and manage an account, sign in, support and account deletion | AURUM production database; authorized service operators only |
| Password | Authenticate account access | Argon2id hash only; plaintext password is not stored |
| Opaque session token hashes | Maintain, refresh and revoke sessions | Token hashes in AURUM database; raw tokens only in OS-backed mobile secure storage |
| Watchlist, preferences, alerts | Deliver saved markets and configured product behavior | AURUM production database associated with the account |
| Alert/notification records | Deliver and display requested alert, signal, market and system messages | AURUM production database; device registration is minimized and token-hashed |
| AI/analysis history, if enabled | Show requested structured market-analysis history | AURUM production database; should contain market/technical context rather than passwords or account secrets |
| Market identifiers and requests | Retrieve market data and calculate analysis | AURUM backend and configured market-data provider; provider terms apply |
| Device push token, if push is enabled | Deliver opted-in notifications | Hash stored by AURUM; actual push provider identified before launch |
| Technical logs | Diagnose outages/security issues | Sanitized backend monitoring/log systems; no passwords, raw tokens, private keys or database credentials |

## 3. Third-party services

Before launch, list the actual providers and their privacy terms here:

- PostgreSQL/database hosting: `[provider]`
- Market-data provider/backend proxy: `[provider]`
- AI provider through AURUM backend: `[provider or not enabled]`
- Push provider: `[provider or not enabled]`
- Password-reset email provider: `[provider or not enabled]`
- Monitoring/error reporting: `[provider or not enabled]`

AURUM should send AI providers only the market and technical context necessary for the requested analysis. It must not send passwords, raw authentication tokens, unnecessary profile information, database credentials or private backend configuration.

## 4. Retention

The intended production policy is:

- Active account data is retained while the account remains active.
- Access sessions expire after the configured short lifetime; refresh sessions expire after the configured refresh lifetime and are revocable.
- Password-reset tokens expire after the configured short lifetime and become unusable after use.
- Notification, alert, analysis and signal-history retention must be set to `[approved retention period]` before launch.
- Sanitized operational logs must have a documented `[approved retention period]`.
- Backups follow the approved backup/restore policy and may persist data until their retention expiry.

## 5. Account deletion

AURUM provides an authenticated account-deletion flow. It requires password re-authentication, revokes active sessions, removes device registrations, alerts, notifications, watchlist data, password-reset tokens, user-specific AI/signal history, and anonymizes the account identity according to the deployed retention policy. The deployed policy must explain any legal/security backup retention that cannot be erased immediately.

## 6. Security

AURUM uses HTTPS in production, server-side authorization checks, parameterized persistence, validated input, rate controls, password hashing, opaque token hashing and OS-backed mobile token storage. No system can guarantee absolute security; users should keep account credentials confidential.

## 7. Your choices

Users can manage supported watchlists, alerts and notification preferences. Notifications can be disabled in the application and/or device settings. Users can request account deletion through the authenticated account settings flow once it is enabled in the released app.

## 8. Children and financial risk

AURUM is not intended for children where prohibited by applicable law. It provides market-analysis information only; it does not guarantee profits, accuracy, returns or future market movements.

## 9. Changes and contact

Material changes will be communicated through the application, website or other appropriate channel. Contact `[privacy contact]` with privacy, access, correction or deletion questions.
