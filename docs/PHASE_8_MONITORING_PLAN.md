# AURUM — Phase 8 monitoring plan

## Required production signals

| Signal | Source | Alert condition | Owner action |
| --- | --- | --- | --- |
| API availability | HTTPS `/health` probe | Two consecutive failures or sustained 5xx | Investigate API/database; pause rollout if user impact persists |
| Database availability | Managed PostgreSQL metrics + health query | Connection failure, storage threshold, backup failure | Escalate to database operator; assess restore/PITR |
| API latency | Reverse proxy/APM | p95 above approved SLO | Inspect slow route/query/provider dependency |
| Authentication failures | Sanitized application metrics | Sustained abnormal spike | Check abuse/rate limits/identity flow; do not log passwords |
| Market provider failure | Backend adapter metrics | Timeout/rate-limit/error threshold | Serve labelled cache where safe; investigate provider/proxy |
| AI failure | Backend AI adapter metrics | Structured validation/timeout/rate threshold | Keep market app usable; investigate provider/prompt/backend |
| Alert processor | Worker heartbeat/backlog/failure metric | Missed interval or failed job | Pause misleading alerts; repair worker and reprocess safely |
| Notification delivery | Push/mail provider metrics | Failure spike | Verify credentials/consent/device lifecycle |
| Android release crashes | Approved privacy-scrubbed crash reporter | New fatal cluster/regression | Halt staged rollout and investigate |

## Privacy constraints

Monitoring must not contain passwords, raw session/refresh/reset/device tokens, provider secrets, complete AI prompts, account email unless operationally necessary and approved, or database connection strings. Correlation IDs, feature name, error category, app version, platform, sanitized route and latency are preferred.

## Release gate

This plan is not configured in a monitoring provider yet. Production launch remains blocked until the selected host/APM/alerting systems are configured, tested and assigned to responsible operators.
