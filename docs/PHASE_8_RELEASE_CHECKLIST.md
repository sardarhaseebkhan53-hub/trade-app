# AURUM — Phase 8 release checklist

**Current decision:** **NOT READY FOR RELEASE**

| Release area | Required evidence | Current result | Gate |
| --- | --- | --- | --- |
| Production backend domain/HTTPS | Live HTTPS endpoint and sanitized health response | Not deployed | BLOCKED |
| Health check | `GET /health` verifies database connectivity | Source implemented; no live DB | BLOCKED |
| Production database | Migrated schema, indexes, constraints and tested restore | Prisma generation/migration blocked | BLOCKED |
| Secrets | Secret-manager screenshots/audit, no Git credentials | Source scan safe; host configuration absent | BLOCKED |
| CORS/rate/security headers | Live production probes | Source configured; no deployed API | BLOCKED |
| Market data proxy | Backend-owned provider key/rate/caching adapter | Not deployed/implemented as production proxy | BLOCKED |
| Production AI | Backend-only provider adapter, structured validation and failure test | Remote port only; provider absent | BLOCKED |
| Alert worker | Scheduled price evaluation, single trigger and preference check | Source service only | BLOCKED |
| Push/email | Consent, delivery, disable/logout behavior | Provider adapters absent | BLOCKED |
| Flutter analyzer/tests | `flutter analyze`, `flutter test` green | Flutter unavailable | BLOCKED |
| Android signing | Protected keystore; signed artifact | Template only | BLOCKED |
| Release APK | Installed/tested on physical Android | Not generated | BLOCKED |
| Release AAB | Generated/verified store artifact | Not generated | BLOCKED |
| App icon/assets | Final non-placeholder icon and release asset audit | Placeholder launcher vector remains | BLOCKED |
| Store screenshots | Captured from signed production release | Not available | BLOCKED |
| Store legal/data safety | Reviewed privacy policy, terms, operator/contact, provider disclosure | Drafts need legal/operator completion | BLOCKED |
| Monitoring/backups | Uptime/error/DB/provider alerting + restore evidence | Runbook only | BLOCKED |
| Final regression | Production release/device end-to-end pass | Not executed | BLOCKED |

## Required final commands

```bash
# backend, secure CI/deployment agent
cd backend
npm ci
npm run build
npm test
npm run prisma:generate
npm run prisma:deploy

# Flutter, secure release workstation
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=path/to/production-defines.json
flutter build appbundle --release --dart-define-from-file=path/to/production-defines.json
```

No Phase 8 artifact should be called production-ready until every blocked row has independently verifiable evidence.
