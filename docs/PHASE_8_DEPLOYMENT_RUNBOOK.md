# AURUM — Phase 8 deployment and release runbook

## Status

This is a **deployment procedure**, not evidence that a production environment, release APK, AAB, database backup, monitoring integration, market proxy, AI provider, push provider, or store listing has been created. The Phase 8 release report remains **NOT READY FOR RELEASE** until every gate below has verifiable evidence.

## 1. Environment separation

Create independent resources and secrets for each environment:

| Concern | Development | Testing | Production |
| --- | --- | --- | --- |
| API URL | Local/LAN non-production endpoint | Isolated CI endpoint | HTTPS production domain |
| PostgreSQL | Local disposable data | Ephemeral test database | Dedicated production database |
| Market/AI/push/mail | Test/sandbox credentials | Test credentials | Production secret-manager credentials |
| Flutter config | Mock/dev define file | CI test defines | Secure production `--dart-define-from-file` input |

Production must not reuse development databases, credentials, signing keys, push projects, or provider accounts.

## 2. Production prerequisites

- A production domain with TLS termination and certificate renewal.
- A dedicated PostgreSQL instance with network access limited to the API deployment.
- A secret manager/host environment system for `backend/.env.production.example` variables.
- A market-data backend proxy/adapter. The current Flutter market adapter must not carry a private provider key in production.
- A secure AI backend adapter with structured-output validation, timeout, cache and rate policy.
- Configured FCM/APNs and mail adapters, both consent-aware and tested.
- Protected Android release keystore stored outside source control.
- Legal owner/contact, privacy contact address, retention decisions and legal disclaimer review.

## 3. Safe database migration procedure

1. Review `backend/prisma/schema.prisma`, generated migration SQL, indexes and constraints in a staging database.
2. Take and verify a pre-migration production backup/snapshot.
3. Put the deployment in maintenance/read-only mode if the migration is not backward compatible.
4. Run `npm ci`, `npm run prisma:generate`, then `npm run prisma:deploy` using production secrets only on the deployment agent.
5. Query migration status and verify `GET /health` returns only `{ status: "ok" }` with the database connected.
6. Run smoke checks against register/login, ownership, watchlist, alert and notification records.
7. Retain the migration log and rollback plan. Never manually change production tables as a substitute for a reviewed migration.

## 4. Backup and recovery policy

Target policy to configure with the chosen managed PostgreSQL provider:

- Encrypted daily full backups, minimum 35-day retention.
- Point-in-time recovery/log retention for at least 7 days.
- Access restricted to approved operators; backup encryption keys managed separately.
- Quarterly restore exercise into an isolated environment, documenting recovery time and data integrity.
- Backup status/failed-job alerts routed to on-call operators.

**Release gate:** a restore test has not yet occurred, so backups cannot currently be claimed as reliable.

## 5. Backend deployment procedure

```bash
cd backend
npm ci
npm run build
npm test
npm run prisma:generate
npm run prisma:deploy
NODE_ENV=production node dist/server.js
```

Host the API behind HTTPS. Restrict inbound traffic to the reverse proxy/load balancer. Use `backend/.env.production.example` only as a variable-name template; populate real values in the host secret manager.

Before routing live traffic verify:

- `GET /health` returns 200 only when PostgreSQL is reachable.
- CORS has exact permitted web origins, not `*`.
- Global/auth rate limits produce sanitized `RATE_LIMITED` responses.
- Logs redact authorization/password/reset fields.
- Error monitoring records feature/category/version without tokens, prompts, email or provider secrets.

## 6. Monitoring and alert policy

Configure host/provider monitoring for:

- `/health` availability and 5xx rate
- Auth failure/rate-limit spikes
- API latency p50/p95/p99
- PostgreSQL connectivity, CPU, storage, backup failure and restore exercises
- Market/AI/provider timeout/rate-limit failures
- Alert processor failure/backlog and push/mail delivery failure

Alert immediately on backend outage, database availability failure, backup failure, unusual auth-failure spikes, and alert-processor failure. Use an approved error reporting provider only after PII/scrubbing review.

## 7. Flutter production build procedure

1. Create a **non-committed** production define file from `config/production.dart-define.example.json`; set the real HTTPS AURUM API domain and leave market private key blank.
2. Copy `android/key.properties.example` to non-committed `android/key.properties` and configure the protected release keystore.
3. Run Flutter checks, then build:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=path/to/production-defines.json
flutter build appbundle --release --dart-define-from-file=path/to/production-defines.json
```

4. Install the resulting APK on a physical Android device. The AAB is the store artifact; the APK is direct-test only.
5. Confirm the app has no debug banner, mock mode, test account, development endpoint, provider key, debug logging, missing icon/font, or crash.

## 8. Rollback

- **API:** deploy the prior immutable image/version only if schema compatibility is preserved.
- **Database:** use managed restore/PITR only after assessing data-loss impact; do not run an ad-hoc downgrade query.
- **Android:** halt store rollout/staged percentage, investigate release crash/error data, and publish a patched build number if needed.

## 9. Store and launch gate

Do not submit until the signed AAB, production backend/database, provider adapters, device QA, privacy/terms, data-safety declarations, screenshots from the actual release app, monitoring and restore evidence are complete.
