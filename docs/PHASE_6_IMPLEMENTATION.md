# AURUM — Phase 6 backend, accounts and persistent-data layer

## Status and validation boundary

Phase 6 adds a production-shaped TypeScript/Fastify/PostgreSQL backend source tree and Flutter repository/session integration boundaries. In this sandbox, `npm run build` and the four database-free backend unit tests pass. Flutter/Dart/Android SDK, USB device, Docker, PostgreSQL client/server, and a Prisma-engine download path remain unavailable. `prisma generate`, migrations, a live API process, Flutter tests, and physical-device flows are therefore not represented as tested.

## Backend choice

**AURUM API:** TypeScript + Fastify + Prisma + PostgreSQL.

- Fastify provides a compact, schema-oriented HTTP server with middleware/plugin boundaries.
- PostgreSQL is the relational production datastore.
- Prisma provides parameterized persistence and explicit schema/migration control.
- Argon2id hashes passwords; database stores only token hashes for opaque sessions.

## Request flow

```text
Request
  → Fastify rate limit / security headers / CORS
  → authentication middleware
  → Zod validation
  → controller
  → service
  → repository
  → Prisma/PostgreSQL
  → { success, data } or { success: false, error }
```

No controller holds database credentials or business rules. No Flutter widget calls raw HTTP, owns credentials, or decides authorization.

## Schema implemented

`backend/prisma/schema.prisma` defines:

- `User`, `UserSession`, `PasswordResetToken`
- `Watchlist`, `WatchlistItem`
- `UserPreference`, `NotificationPreference`
- `PriceAlert`, `Notification`, `DeviceRegistration`
- `Signal`, `SignalHistory`, `AIAnalysis`

It includes unique constraints and indexes for email, token hashes, user-owned resources, active alerts by asset, notifications by user/time, and intelligence history. Watchlist item uniqueness is enforced at `(watchlistId, assetId)`.

## Authentication and security

- Register / login hash passwords with Argon2id.
- Sessions use random opaque access and refresh tokens. Only SHA-256 token hashes are persisted.
- Access tokens expire after a configured short TTL; refresh rotates/revokes the previous session.
- All protected routes use the authenticated `request.auth.userId`, never a client-provided user ID.
- Logout revokes the current session; password reset and account deletion revoke all user sessions.
- Password reset replies are generic to avoid email enumeration.
- Account deletion is re-authenticated with the current password, revokes sessions, then anonymizes account credentials/identity while database retention policy is finalized.
- The app server uses security headers, constrained CORS, 64 KB request-body limit, endpoint/global rate limiting, structured errors, and log redaction for authorization/password/reset fields.

## API endpoints

| Area | Endpoints |
| --- | --- |
| Auth | `POST /auth/register`, `/auth/login`, `/auth/logout`, `/auth/refresh`, `/auth/forgot-password`, `/auth/reset-password`; `GET /auth/me` |
| User | `GET/PATCH /users/me`, `DELETE /users/me`, `GET/PATCH /users/preferences`, `GET/PATCH /users/notification-preferences` |
| Watchlist | `GET /watchlist`, `POST /watchlist`, `DELETE /watchlist/:asset` |
| Alerts | `GET/POST /alerts`, `PATCH/DELETE /alerts/:id` |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` |
| Devices | `POST /devices`, `DELETE /devices/:id` |
| Intelligence history | `GET /signals/history`, `GET /ai-analyses/history` |

Responses use `{ "success": true, "data": … }` or `{ "success": false, "error": { "code", "message" } }`. Internal traces and database errors are not exposed.

## Alerts and notifications

`AlertProcessorService` is a backend-worker service port. It receives a market quote, evaluates active user alerts, marks matching alerts triggered, respects `priceAlertEnabled`, and creates persistent notification records. It does not run in Flutter. `PushService` is an explicit provider interface; Phase 6 stores only a hashed device token and does not activate push delivery without a consent-aware FCM/APNs backend adapter.

## Flutter integration

The Flutter project now includes:

- Secure OS-backed access/refresh-token storage
- `AurumBackendClient` with standardized response parsing and no secret logging
- Conditional mock/remote repositories for auth, watchlists, notifications, profile/preferences and price alerts
- `AuthState` states: unauthenticated, authenticating, authenticated, session expired, logging out
- Splash session restoration, session-expiry redirect, remote logout behavior
- Persistent-backend-ready price-alert screen and route

Use `AURUM_BACKEND_MODE=mock` until a backend URL and local secure environment are configured. Remote mode uses `AURUM_API_BASE_URL`; a physical phone must use a reachable LAN/HTTPS development URL—not `localhost`.

## Local startup

```bash
# Backend
cd backend
cp .env.example .env
npm install
npm run prisma:generate
# if Docker is installed
docker compose -f docker-compose.dev.yml up -d postgres
npm run prisma:migrate
npm run dev

# Flutter, on a separate terminal / physical Android device
flutter pub get
flutter run -d <physical-device-id> \
  --dart-define=AURUM_BACKEND_MODE=remote \
  --dart-define=AURUM_API_BASE_URL=https://your-dev-api.example
```

Never use production database, AI, push, market-provider or signing secrets for this workflow. Backend `.env` is ignored; only `backend/.env.example` is tracked.

## Tests included and required next

- Source-level backend auth/validation tests under `backend/test/`
- Backend authorization/ownership/integration matrix in `backend/test/authorization-plan.md`
- Flutter mocks remain available for offline UI/widget tests

Before Phase 6 is declared complete, CI/local PostgreSQL must run Prisma migration, `npm run build`, `npm test`, Flutter analysis/tests, and the physical Android sequence: register → login → persistent watchlist → create alert → notification record → logout → expired-session flow. This environment could not execute those commands.
