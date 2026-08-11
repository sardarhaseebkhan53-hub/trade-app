# AURUM — Phase 7 master QA checklist

**Execution date:** 2026-08-11
**Scope:** source review, backend static/build/unit validation, dependency audit, environment preflight, and production-readiness review.
**Important:** `BLOCKED` is not a pass. Flutter, Prisma/PostgreSQL, release APK, live API, and physical-device checks could not be executed in this sandbox.

| Feature | Test | Expected result | Actual result | Status | Severity | Fix | Retest status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Backend TypeScript | `npm run build` | No TypeScript errors | Passed | PASS | — | — | PASS |
| Backend unit tests | `npm test` | Auth and validation tests pass | 4/4 tests passed | PASS | — | — | PASS |
| Production dependencies | `npm audit --omit=dev` | No production dependency vulnerability | 0 vulnerabilities | PASS | — | — | PASS |
| Prisma client/schema | `prisma generate` | Client generated from schema | Blocked by TLS access to Prisma engine host | BLOCKED | HIGH | Run on a networked build agent; then generate/migrate against isolated PostgreSQL | NOT RUN |
| PostgreSQL migration | `prisma migrate` | Schema/migration applies | No PostgreSQL/Docker available | BLOCKED | HIGH | Run PostgreSQL-backed integration environment | NOT RUN |
| Flutter analyzer | `flutter analyze` | Zero unresolved analyzer errors | Flutter cannot bootstrap Dart SDK in sandbox | BLOCKED | HIGH | Install official Flutter/Dart SDK on workstation | NOT RUN |
| Flutter unit/widget tests | `flutter test` | All Dart/widget tests pass | Flutter unavailable | BLOCKED | HIGH | Run on workstation after `flutter pub get` | NOT RUN |
| Android release build | `flutter build apk --release` | Signed installable APK | Android SDK, Java, signing key and Flutter unavailable | BLOCKED | HIGH | Configure release workstation and signing keystore | NOT RUN |
| Physical Android device | USB install/functional pass | All flows work on actual phone | No `adb` or USB device available | BLOCKED | HIGH | Execute documented device matrix | NOT RUN |
| Backend auth | Register duplicate-email unit case | Duplicate account rejected | Passed | PASS | — | — | PASS |
| Backend auth | Invalid password unit case | No session issued | Passed | PASS | — | — | PASS |
| Backend auth | Login, refresh rotation, logout revocation | Session lifecycle works against DB | Requires Prisma/PostgreSQL integration test | BLOCKED | HIGH | Run DB integration suite | NOT RUN |
| Backend auth | Password reset generic reply and token use | No account enumeration; reset revokes sessions | Source reviewed; email delivery adapter not configured | PARTIAL | HIGH | Configure mail provider and DB integration test | NOT RUN |
| Backend authorization | Cross-user resources | User A cannot access User B data | Repository query ownership reviewed; integration test needs DB | PARTIAL | HIGH | Run authorization matrix with two test users | NOT RUN |
| Password security | Hashing | Argon2id only; no plaintext persistence | Source reviewed | PASS | — | — | PASS (source) |
| Session security | Token persistence | Only token hashes in database; secure storage on mobile | Source reviewed | PASS | — | — | PASS (source) |
| Request validation | Malformed registration/alert payload | Structured 422, no crash | 2 validation assertions passed | PASS | — | — | PASS |
| Rate limits | Auth endpoints/global limit | Abusive requests throttled | Source reviewed; no load execution | PARTIAL | MEDIUM | Run scripted rate tests against live API | NOT RUN |
| CORS/security headers | Fastify helmet/CORS policy | Restricted configured origins and headers | Source reviewed | PARTIAL | MEDIUM | Validate production origin list in deployment | NOT RUN |
| Watchlist persistence | Add/remove/reopen | Own list persists after app restart | Remote repo + database schema present; no live DB/device | BLOCKED | HIGH | Execute journey with two users/device | NOT RUN |
| Watchlist duplicate | Constraint/service behavior | Duplicate rejected | Unique schema + service reviewed | PARTIAL | MEDIUM | DB integration test | NOT RUN |
| Preferences | Read/update | User-only settings persist | API/repository source present; no live DB | BLOCKED | MEDIUM | DB/API/device test | NOT RUN |
| Alerts | Create/update/delete | Valid user-owned alerts persist | API/repository source present; no live DB | BLOCKED | HIGH | DB/API/device test | NOT RUN |
| Alert processing | Above/below/once | Trigger once, respect opt-out | Worker service source reviewed; no scheduler/market worker configured | PARTIAL | HIGH | Wire scheduled worker and test quotes | NOT RUN |
| Notifications | List/read/read all/pagination | Correct user-scoped records | API/repository source present; no live DB | BLOCKED | HIGH | DB/API/device test | NOT RUN |
| Push delivery | Consent/device/send | Disabled users receive none | Device schema/port only; no FCM/APNs adapter configured | BLOCKED | HIGH | Configure provider and device tests | NOT RUN |
| Market data | Load/search/cache/rate fail | Live values/stale/error states accurate | Source reviewed; live provider transport blocked | BLOCKED | HIGH | Run remote API/device QA | NOT RUN |
| Technical analysis | SMA/EMA/RSI/MACD/insufficient data | Correct typed outcomes | Test source exists; Flutter test runner blocked | BLOCKED | HIGH | Run Flutter test | NOT RUN |
| Signal engine | Bullish/bearish/neutral/lifecycle | Explainable status, no incomplete-data bias | Test source exists; Flutter test runner blocked | BLOCKED | HIGH | Run Flutter test and rule matrix | NOT RUN |
| AI structured output | Valid/invalid/missing fields | Reject malformed/invented output | Test source exists; remote provider intentionally not configured | PARTIAL | HIGH | Run Flutter tests; test backend AI adapter | NOT RUN |
| AI privacy | Prompt secrets/PII | No credentials/private user data in prompt | Source reviewed | PASS | — | — | PASS (source) |
| Navigation | Root/tab/detail/back paths | No broken routes or collision | Source reviewed only | BLOCKED | MEDIUM | Widget/integration/device tests | NOT RUN |
| UI overflow | Small/large/text scale/keyboard | No clipped/overlapping content | Static layout review only | BLOCKED | HIGH | Device/golden/text-scale QA | NOT RUN |
| Accessibility | Semantics, contrast, targets | TalkBack and non-color state semantics work | Source review only | PARTIAL | MEDIUM | TalkBack/text-scale device audit | NOT RUN |
| List/chart performance | Scroll/rebuild/memory | Smooth, bounded points | Source reviewed: chart adapter caps points; no profiling | PARTIAL | MEDIUM | Flutter DevTools on physical phone | NOT RUN |
| Logging | Secrets absent | No password/token/key logging | Source scan passed; network log is debug-gated/path-only | PASS | — | — | PASS (source) |
| Release signing | Debug key not used for release | Release config requires a real keystore | **Fixed in Phase 7:** removed debug signing fallback; unsigned release remains a release blocker | FIXED | HIGH | Add protected key.properties on release workstation | PENDING DEVICE BUILD |
| Frontend password policy | Match backend policy | Registration rejects weak password locally | **Fixed in Phase 7:** requires 12 chars + upper/lower/number | FIXED | MEDIUM | Flutter widget test pending | NOT RUN |
| Disclaimer | No certainty/profit claim | Analysis-only wording remains visible | Source scan/review passed | PASS | — | — | PASS (source) |

## Required live regression journeys

The following are deliberately unmarked until a real backend/database/Android phone is available:

1. Splash → onboarding → register → home
2. Login → markets → search → asset → chart → technical analysis
3. Watchlist add → app restart → persisted watchlist
4. Price alert → quote trigger → notification record → disabled preference check
5. Session expiry → login redirect → fresh login
6. Release APK installation and full Android back/keyboard/background/network-switch pass
