# AURUM API integration-test plan

Run these against an isolated PostgreSQL database configured through `DATABASE_URL` in CI. Tests must reset the schema between cases.

- Authentication: register, duplicate email, login, invalid password, refresh rotation, logout revocation, expired access session, generic password-reset response.
- Authorization: unauthenticated protected request; valid user accessing own watchlist/alert/notification; valid user attempting another user’s resource ID.
- Watchlist: empty list, add, duplicate add, remove, non-existent removal.
- Alerts: create, update, delete, invalid asset/price, alert trigger only once, notification preference disabled.
- Notifications: create, cursor pagination, mark one read, mark all read, ownership enforcement.
- Security: malformed JSON, oversized body, invalid bearer token, expired token, SQL-like input, unsupported sort/query parameters and auth endpoint rate limits.

The source-level unit tests are intentionally database-free. Production CI must add a PostgreSQL service and execute this plan before deployment.
