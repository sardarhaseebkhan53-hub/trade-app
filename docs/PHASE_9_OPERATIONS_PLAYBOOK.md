# AURUM — Phase 9 operations, monitoring and continuous-improvement playbook

## Operational status gate

**Current status:** AURUM is **not deployed and not ready for release**. Phase 8 has no signed Android artifact, deployed backend/database, physical-device release QA, market/AI/push/mail provider deployment, backup-restore evidence, or production monitoring.

Therefore this document is a **pre-launch operations plan**. It must not be presented as proof that AURUM is live, monitored, or collecting production analytics. Do not enable a feedback form, analytics SDK, crash reporter, or remote monitoring without updating the privacy policy, provider disclosure, retention policy and release checklist.

The mandatory order remains:

```text
Close Phase 8 release blockers
  → staged release
  → configure consent-aware monitoring
  → monitor real production behavior
  → triage/fix/test/stage each maintenance release
```

## 1. Monitoring model

### Backend and infrastructure signals

| Domain | Metric | Warning threshold | Critical threshold | Safe action |
| --- | --- | --- | --- | --- |
| Availability | HTTPS `/health` success rate | Below 99.5% over 15 min | Below 99% or database health failure | Page operator; stop rollout; inspect API/database |
| API | 5xx rate | Above 1% over 15 min | Above 5% over 5 min | Roll back/reduce rollout; inspect sanitized errors |
| API | p95 latency | Above approved service objective | Sustained severe latency | Inspect dependency/database/provider timing |
| Database | Connections/storage/query latency | Provider warning | Connection exhaustion/availability failure | Protect writes; escalate; consider rollback |
| Market provider | Timeout/rate-limit/parsing rate | Above baseline | Market data invalid/unavailable broadly | Label data unavailable/stale; investigate adapter |
| AI service | Timeout/schema-validation/provider failure | Above baseline | Invalid output bypass or broad failure | Disable interpretation safely; keep markets usable |
| Alert worker | Job duration/backlog/failure | Missed expected interval | Consecutive job failure | Pause misleading delivery; repair/replay idempotently |
| Notifications | Provider delivery failure | Above baseline | System-wide delivery failure | Disable nonessential sends; investigate provider |

All measurements must be configured with a named owner, service-level target, incident channel and retention setting before launch.

### Mobile crash and error signals

Collect only privacy-scrubbed data through an approved crash/error provider after user-notice and policy review:

- App version/build number
- Android version and non-identifying device category
- Feature/screen category
- Sanitized exception type and stack trace
- Network/error category such as `AUTH_FAILURE`, `MARKET_API_FAILURE`, `AI_FAILURE`, `DATABASE_FAILURE`, `NOTIFICATION_FAILURE`, `NETWORK_FAILURE`, or `PARSING_FAILURE`

Never send passwords, emails unless strictly required and disclosed, raw access/refresh/reset/device tokens, provider secrets, database URLs, full AI prompts, private profile content or watchlist/alert payloads without a documented lawful purpose.

## 2. Incident severity and response

| Severity | Meaning | Initial response target | Release action |
| --- | --- | --- | --- |
| CRITICAL | Security exposure, data corruption/loss, widespread auth outage, app crash loop | Immediate | Halt staged rollout; protect data; rollback/disable affected service |
| HIGH | Major journey broken: login, market load, alert handling, persistent crash | Urgent | Pause expansion; hotfix after regression/security review |
| MEDIUM | Significant degraded feature with safe workaround | Planned priority | Fix in tested maintenance release |
| LOW | Cosmetic, copy or minor usability problem | Backlog | Bundle with a future regression-tested release |

### Incident process

1. Detect through health/monitoring/support signals.
2. Classify severity and affected scope.
3. Freeze rollout and protect users/data where required.
4. Preserve sanitized evidence; do not erase useful logs or expose private data.
5. Restore service using an approved rollback, configuration reversal, feature disablement or database recovery plan.
6. Identify root cause, not only the visible symptom.
7. Implement a minimal tested fix.
8. Run regression, authorization, data-integrity and release-device checks relevant to the change.
9. Stage the release and monitor at each rollout percentage.
10. Publish a blameless incident record for CRITICAL/HIGH incidents.

## 3. Incident report template

```text
Incident ID:
Date / timezone:
Severity:
Duration:
Affected feature and release version:
Estimated affected users:
User impact:
Detection source:
Root cause:
Immediate mitigation:
Permanent fix:
Validation/retest evidence:
Rollback used?:
Data/security impact:
Prevention follow-up / owner / due date:
```

## 4. Data and signal quality controls

### Market data

Reject/label data as invalid or stale when required fields are missing, timestamps are implausible, numeric values are non-finite, OHLC consistency fails, or provider data exceeds configured anomaly controls. Cached data must remain visibly cached; it must never be labelled live merely because a screen rebuilt.

### AI output

The backend must validate structured output before display. Reject output that misses required fields, includes unsupported data, exposes internal prompts/configuration, makes certainty/profit claims, or conflicts with supplied structured evidence without explicitly acknowledging the conflict. If AI fails, markets, authentication, watchlists and alerts continue independently.

### Signals

Monitor duplicate generation, missing generation, stale `ACTIVE` records, unexpected invalidations, conflicting multi-timeframe results and analytical output produced with insufficient history. Historical records remain immutable; corrections create an updated/invalidated record rather than mutating prior context.

## 5. Feedback and backlog policy

A future in-app feedback mechanism must be deliberately added only after privacy review. Its minimum shape is:

```text
Category: Bug | Incorrect data | AI issue | UI problem | Notification problem | General feedback | Feature request
Description: required, bounded length
Optional screenshot: explicit consent, redacted/upload-scanned
App version/build: automatic, non-identifying
```

Feedback must be authenticated or abuse-protected, rate-limited, stored with a documented retention period, and separated from feature requests. Do not attach passwords, token values, provider responses, private account data, complete screenshots, or unreviewed financial information automatically.

### Triage backlog fields

| Field | Purpose |
| --- | --- |
| Issue ID | Stable reference |
| Category | Bug, feedback, feature request, security, data quality |
| Severity/priority | Impact-based, not request volume alone |
| User impact | Scope and workaround |
| Evidence | Sanitized trace/reproduction steps |
| Status | New, triaged, planned, in progress, verified, released, declined |
| Target version | Tested release target |
| Privacy/security review | Required when data collection/permissions change |

## 6. Release management

Every post-launch release needs a version/build number, changelog, linked issue list, automated-test results, known issues, release owner, staged rollout schedule and rollback plan.

Recommended rollout:

```text
Internal validation → small percentage → expanded percentage → full rollout
```

Do not advance a rollout when crash/error/latency measures regress, authentication fails, user data integrity is uncertain, or alert/notification behavior becomes misleading.

Database migrations are reviewed, backed up, tested against representative staging data, deployed once, verified, and monitored. No manual production table edits replace a migration.

## 7. Privacy-first analytics

Do not add analytics solely because it is available. Before enabling any event, document its product question, fields, retention, processor, access, user disclosure and deletion behavior.

Potential useful, minimized metrics after consent/policy review:

- Aggregate active/retention cohorts
- Screen/feature usage without sensitive market/account payloads
- Watchlist/alert feature interaction counts
- Notification interaction aggregate
- Sanitized error frequency and performance timing

Never include passwords, tokens, private AI content, precise financial holdings, raw alerts, full search terms, or unnecessary personal identifiers in product analytics.

## 8. Monthly health review

Review product feedback/retention, crash/error trends, latency, provider quality, signal/AI quality, security events, dependency advisories, infrastructure cost, database storage/connections, backup/restore evidence and outstanding incidents. Record actions, owner and target release.

## 9. Architecture protection rule

Maintain the existing layering:

```text
Flutter UI → Riverpod state → repository → service/client → AURUM backend → database/provider
```

No post-launch fix bypasses authorization, validation, repository boundaries, structured parsing, secure storage, cache freshness labels or financial-safety wording for convenience.

## 10. Future feature gate

Before any new capability, record user demand, core-product impact, data/privacy changes, security risk, infrastructure and provider cost, architecture impact, test plan, rollback strategy and legal/regulatory implications. A request becomes a feature only after this review—not because a competitor has it.

## Permanent AURUM loop

```text
PLAN → IMPLEMENT → TEST → SECURITY REVIEW → STAGED RELEASE → MONITOR → LEARN → REPEAT
```

AURUM prioritizes reliability over unnecessary features, accuracy over impressive-looking claims, security over convenience, performance over distracting effects, clarity over overload, and user trust over engagement tricks.
