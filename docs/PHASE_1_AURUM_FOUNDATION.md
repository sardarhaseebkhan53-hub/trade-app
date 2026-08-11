# AURUM — Phase 1 Foundation

**Status:** Architecture and visual-direction proposal — implementation intentionally deferred pending approval

**Platform baseline:** Flutter + Dart, developed in VS Code and tested primarily on physical Android devices

**Product position:** A premium cryptocurrency **analysis and decision-support** product. AURUM must never imply a guaranteed return, a guaranteed prediction, or risk-free trading.

---

## 1. Executive recommendation

AURUM should be rebuilt as a new, feature-first Flutter application. It should have a dark, editorial-quality financial interface; a clean separation between presentation, state, domain rules, repositories, and remote/local services; and a backend boundary for all private credentials, AI requests, signals, and account data.

The recommended daily workflow is deliberately physical-device friendly:

```text
VS Code (Flutter/Dart extensions)
  → USB debugging enabled on Android phone
  → flutter devices
  → F5 / Flutter: Select Device / hot reload
  → flutter run --release for device validation
  → flutter build apk --release for distributable Android builds
```

An emulator is useful only as an optional layout test target; it is not a dependency of normal development.

No Flutter implementation should begin until the design direction in this document and `assets/design/aurum_phase_1_premium_ui_concept.png` are approved.

---

## 2. Existing-project audit

### Scope and evidence

The entire committed working tree and its available history were inspected before any files were added for this Phase 1 documentation:

| Audit item | Finding |
| --- | --- |
| Repository root | Only `README.md` is present. |
| README | One heading: `# trade-app`. |
| Git history | One initial commit (`a26a914`); it introduces only `README.md`. |
| Flutter configuration | Absent: no `pubspec.yaml`, `analysis_options.yaml`, `lib/`, or `test/`. |
| Dart source and widgets | Absent. |
| Navigation / state management | Absent. |
| API, repository, models, auth, database | Absent. |
| Environment files / secret-handling strategy | Absent. |
| Assets, fonts, themes, charts, trading or AI components | Absent. |
| Android / Gradle / manifest configuration | Absent. |
| CI, formatting, linting and build configuration | Absent. |
| Existing ignored or untracked project files | None found. |

### A. What is correct

- The repository is clean and almost empty, so there is no legacy Flutter code that needs to be preserved for compatibility.
- The project can start with an intentional foundation rather than perpetuating an unverified implementation.
- The README establishes a placeholder repository identity, but not the AURUM product identity.

### B. What is incorrect

There is no prior mobile implementation to validate or repair. Therefore, a claim that a particular previous screen, architecture, integration, or UI is wrong cannot be substantiated from this checkout. The incorrect state is the absence of the required application foundation: this is not currently a Flutter project and cannot be opened, debugged, or run as an Android app.

### C. What is incomplete

Everything required for a production-minded AURUM application remains to be created: Flutter bootstrap, Android project, dependency manifest, design tokens, screens, navigation, state, domain models, service interfaces, API/backend contracts, auth, secure storage, testing, build configuration, and documentation.

### D. What should be removed

- **No source code or configuration should be removed.** There is none.
- The generic `trade-app` repository naming in the README should be replaced during the approved bootstrap with an AURUM project README. It is not a technical dependency and should not drive the product architecture.

### E. What can be reused

- The Git repository and the clean initial commit only.
- No application code, packages, assets, API contracts, UI, or architecture can safely be reused because none exists.

### F. What must be rebuilt

The entire customer application and its operational baseline must be newly created. This is a greenfield build, not a migration.

### G. Architecture replacing the nonexistent old architecture

Use a **feature-first, clean-layered Flutter architecture** with Riverpod for state and GoRouter for navigation. UI code must never make HTTP calls or own API keys. Remote implementations sit behind repositories; use cases coordinate domain rules; presentation controllers expose immutable async state to widgets.

---

## 3. Product boundaries and design principles

### AURUM will do

- Present market information, technical context, watchlists, analysis summaries, and configurable notifications.
- Explain signals as time-bound analytical observations with assumptions, invalidation/risk context, data freshness, and source provenance.
- Present AI output as assistive commentary, with evidence, uncertainty, and non-advisory language.
- Help a user discover and examine assets without placing trades in Phase 2.

### AURUM will not do

- Promise performance, certainty, profitability, or risk-free outcomes.
- Present AI confidence as a prediction guarantee.
- Place, custody, transfer, or execute trades in the Phase 2 customer app.
- Ship a provider API secret in the APK.

### Design principles

1. **Calm before dense.** Give price, movement, freshness, and context priority over decorative card volume.
2. **Evidence beside opinion.** An AI or signal statement always exposes its technical/market support and risk note.
3. **Fast scanning, deep drill-down.** Overview feeds lead to a focused asset workspace without overloading the home screen.
4. **Premium restraint.** Near-black surfaces, metallic-gold accents, precise spacing, and sober status colors replace loud gradients and visual noise.
5. **Uncertain by design.** Data delays, unavailable values, stale analysis, and errors are explicit, not hidden.
6. **Accessible by default.** Do not communicate market direction with color alone; pair color with a signed value, icon, and label.

---

## 4. Recommended application architecture

### Layer model

```text
┌─────────────────────────────────────────────────────────────┐
│ Presentation                                                  │
│ Screens, design-system widgets, GoRouter routes, Riverpod     │
│ controllers, view state and UI-only formatting                │
├─────────────────────────────────────────────────────────────┤
│ Domain                                                        │
│ Entities, repository contracts, use cases, business/risk      │
│ policies, typed failures                                      │
├─────────────────────────────────────────────────────────────┤
│ Data                                                          │
│ Repository implementations, DTOs, mappers, REST/WebSocket     │
│ data sources, local cache, secure-session store               │
├─────────────────────────────────────────────────────────────┤
│ Core / platform                                               │
│ HTTP client, auth interceptor, logger, connectivity, config,  │
│ analytics abstraction, theme, clock, error mapping            │
└─────────────────────────────────────────────────────────────┘
```

Dependencies point inward. A presentation controller may call a domain use case; it must not know whether data originates from REST, WebSocket, cache, or a mock. A repository implementation may depend on a remote source and local store; domain contracts never depend on `dio`, Flutter widgets, or provider-specific DTOs.

### Technology choices

| Concern | Recommendation | Why |
| --- | --- | --- |
| State and dependency injection | `flutter_riverpod` with generated providers where justified | Testable, scoped, explicit async state and easy VS Code debugging. |
| Immutable state / models | Dart sealed classes; `freezed`/`json_serializable` only where the reduced boilerplate earns its build-runner cost | Exhaustive UI states and safe DTO conversion. |
| Navigation | `go_router` with a `StatefulShellRoute` | Restores independent tab stacks and supports future deep links. |
| Networking | `dio`, a single configured client, interceptors, cancellation and timeout policies | Mature requests, clear error mapping and testable adapters. |
| Secure tokens | `flutter_secure_storage` | Uses OS-backed protected storage; do not use preferences for tokens. |
| Non-sensitive cache | Isar or Drift, selected after Phase 2 data-shape validation | Offline-aware watchlists and bounded market cache without UI coupling. |
| Charts | A purpose-selected Flutter chart package or a custom `CustomPainter` adapter evaluated in a short spike | Candles, gestures and performance must be proven on physical Android before adoption. |
| Formatting / locale | `intl` | Currency, compact market cap and date/time formatting. |
| Connectivity | `connectivity_plus` as a hint, backed by actual request failures | A network interface is not proof that an API is reachable. |
| Observability | Sentry/Crashlytics through a core abstraction, with PII scrubbing | Production diagnosis without leaking account or market-query details. |

Package versions should be pinned only when `flutter --version` is chosen for the initial bootstrap. Dependencies must be added one at a time for a clear purpose; no UI-kit or all-in-one trading package should dictate AURUM’s design.

### Failure and async-state model

- Repositories return typed `Result`/`Either`-style outcomes or throw only mapped domain failures (`NetworkFailure`, `UnauthorizedFailure`, `RateLimitFailure`, `ValidationFailure`, `ServiceUnavailableFailure`, `UnexpectedFailure`).
- Controllers expose explicit `loading`, `refreshing`, `data`, `empty`, `error`, and `staleData` view states.
- A successful cached response may be shown with a visible **Last updated** timestamp while refresh is retried.
- Pages own user-facing recovery actions. Global handling is limited to session expiration, maintenance, and nonintrusive connectivity notices.

### Configuration management

```text
--dart-define / --dart-define-from-file (non-secret build configuration)
                    ↓
              AppConfig (validated once at startup)
                    ↓
       API hosts, environment name, telemetry enablement,
          feature flags, public client identifiers only
```

A checked-in `config/example.*` may document required **non-secret** keys. Real environment files, signing material, credentials, and endpoint secrets stay out of Git and out of the mobile binary. The backend owns market-provider and AI-provider secrets.

---

## 5. Proposed Flutter folder structure

```text
.
├── .vscode/
│   ├── launch.json                    # Flutter debug profiles for a USB device
│   ├── settings.json                  # formatter/analyzer project settings
│   └── extensions.json                # Dart/Flutter recommendations
├── android/                            # Flutter-generated Android host; physical-device ready
├── assets/
│   ├── design/                         # approved Phase 1 reference concept
│   ├── fonts/                          # licensed, bundled display/body fonts if selected
│   ├── icons/                          # SVG source + generated-safe assets
│   └── images/
├── docs/
│   ├── PHASE_1_AURUM_FOUNDATION.md
│   ├── api-contracts/
│   └── decisions/                      # short architecture decision records
├── integration_test/
├── lib/
│   ├── main.dart                       # thin composition entrypoint
│   ├── bootstrap.dart                   # guarded startup, config and observers
│   ├── app/
│   │   ├── app.dart
│   │   ├── router/
│   │   ├── theme/
│   │   └── l10n/
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── persistence/
│   │   ├── security/
│   │   ├── services/
│   │   ├── utils/
│   │   └── widgets/                    # only genuinely cross-feature primitives
│   └── features/
│       ├── auth/
│       ├── onboarding/
│       ├── home/
│       ├── markets/
│       ├── asset_detail/
│       ├── watchlist/
│       ├── signals/
│       ├── ai_analysis/
│       ├── alerts/
│       ├── profile/
│       └── settings/
│           ├── data/
│           │   ├── datasources/
│           │   ├── dto/
│           │   ├── mappers/
│           │   └── repositories/
│           ├── domain/
│           │   ├── entities/
│           │   ├── repositories/
│           │   └── usecases/
│           └── presentation/
│               ├── controllers/
│               ├── screens/
│               ├── widgets/
│               └── state/
├── test/
│   ├── core/
│   ├── features/
│   ├── golden/
│   └── helpers/
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

A small feature can omit a layer rather than invent an empty folder. Conversely, a feature-specific widget remains inside its feature until it has proven cross-feature reuse.

---

## 6. Feature map

| Module | Responsibilities | Phase 2 priority |
| --- | --- | --- |
| Bootstrap & app shell | Config validation, theme, router, error boundary, app lifecycle | Foundation |
| Design system | Tokens and accessible reusable primitives | Foundation |
| Onboarding & consent | Welcome, risk disclosure acceptance, feature orientation | Core |
| Auth & session | Sign-in/sign-up or guest mode, secure token renewal, account deletion/sign-out | Core |
| Home / Market Pulse | Overall sentiment, featured assets, watchlist preview, quick actions, concise AI insight | Core |
| Markets | Search, paginated/sortable asset list, categories, filters, market snapshot | Core |
| Asset Detail | Quote, multi-timeframe chart, OHLCV, statistics, indicator views and news/context links | Core |
| Watchlist | Local-first save/remove/reorder, optional authenticated sync | Core |
| Signals | Curated/generated analysis signals, lifecycle, filters, risk/invalidation context | Core |
| AI Desk | Request/receive analysis, evidence, confidence phrasing, history, feedback and disclaimers | Core |
| Alerts & notifications | Price/signal/analysis alerts, permission flow, in-app inbox and settings | Next |
| Profile & settings | Account, units/currency, data refresh, theme, privacy, security, support | Core |
| Observability | Crash/error reporting, performance traces, privacy-aware analytics | Foundation |

Future modules—not Phase 2 assumptions—may include comparison, tax/export reporting, multilingual support, broker integrations, social research, and iOS-specific refinements. They should be introduced only after product, legal, and backend contracts are approved.

---

## 7. Navigation map

### Recommended primary navigation

A persistent five-item bottom navigation is the best fit for the primary analytical workflows on a phone:

```text
┌──────────────────────────────────────────────────────────┐
│ App start                                                │
│  ├─ Bootstrap / migration / maintenance check            │
│  ├─ Onboarding + risk disclosure (first launch)          │
│  └─ Session gate (guest or authenticated)                │
│                                                          │
│ Authenticated / guest application shell                  │
│  ├─ Overview     Market pulse, watchlist preview, insight│
│  ├─ Markets      Discovery, search, filters, rankings    │
│  ├─ Signals      Current, completed, archived signals    │
│  ├─ AI Desk      Evidence-led AI analysis and history    │
│  └─ Profile      Account, preferences, security, support │
└──────────────────────────────────────────────────────────┘
```

- **Overview** is the launch destination because it answers “what matters now?” in one scan.
- **Markets** is separate from Overview because asset discovery, search, sort, and filters need an uninterrupted workspace.
- **Signals** needs a dedicated destination to avoid burying risk-sensitive content beneath a dashboard.
- **AI Desk** is a dedicated, named workspace. It makes the AI capability intentional rather than a magical button and preserves analysis history/context.
- **Profile** contains the user-specific and lower-frequency settings area. It prevents settings controls from cluttering market analysis.

Watchlist has a prominent Overview section and a route reachable via a top action or Markets filter; it does not need a sixth primary tab. This preserves the five-tab maximum and makes watchlist a first-class workflow without displacing analysis.

### Route hierarchy

```text
/launch
/onboarding
/auth/sign-in
/auth/sign-up
/app/overview
  ├─ /app/overview/watchlist
  ├─ /asset/:assetId
  │   ├─ /asset/:assetId/chart
  │   ├─ /asset/:assetId/indicators
  │   └─ /asset/:assetId/analysis
  └─ /notifications
/app/markets
  ├─ /markets/search
  ├─ /markets/filter
  └─ /asset/:assetId
/app/signals
  └─ /signals/:signalId
/app/ai
  ├─ /ai/new?asset=:assetId
  └─ /ai/:analysisId
/app/profile
  ├─ /profile/account
  ├─ /profile/preferences
  ├─ /profile/notifications
  ├─ /profile/security
  └─ /profile/privacy
```

Asset details, signal details, filters, and AI requests are pushed above the retained tab shell. Search, timeframe choices, and quick filters can use modal bottom sheets where the task is short and reversible. Destructive/account actions use explicit dialogs.

---

## 8. Data and API architecture

### Data flow

```text
Flutter screen
  → Riverpod controller / notifier
  → domain use case
  → repository contract
  → repository implementation
  ├─ local cache / secure store
  └─ remote data source (REST, WebSocket, AURUM backend)
      → DTO validation and mapping → domain entity → view state → screen
```

The screen renders state and dispatches user intent only. A controller determines when to load, refresh, paginate, cancel a stale request, or optimistically update a watchlist. The repository makes cache-versus-network decisions and maps provider failures into AURUM failures. DTOs never leak into widgets.

### Required service contracts

| Data need | Client-side contract | Source and implementation guidance |
| --- | --- | --- |
| Live quotes / ranked assets | `MarketRepository.getMarkets`, `watchQuotes` | Use a provider supported by an AURUM server adapter. REST for initial/paginated data; WebSocket only for visible/watchlisted symbols and only when rate/cost permits. |
| Asset metadata & statistics | `AssetRepository.getAsset` | Canonical IDs, logo URL, market cap, volume, supply, all-time values, update time. Normalize provider symbol collisions server-side. |
| Historical OHLCV | `ChartRepository.getCandles(asset, interval, range)` | Backend-normalized candles with UTC timestamps. Cache bounded ranges; never redraw an entire history for a single tick. |
| Technical indicators | `IndicatorRepository.getSnapshot` | Begin server-side or deterministic shared calculation with parameters/version recorded. Return RSI/MACD/EMA values plus time range and freshness. |
| Sentiment / market pulse | `SentimentRepository.getOverview` | Return source, observed timestamp, methodology/version, and unavailable state. Do not present as a forecast. |
| AI analysis | `AiAnalysisRepository.requestAnalysis`, `getAnalysis` | AURUM backend only. Backend gathers allowed data, calls model privately, validates response schema, records model/data timestamp, filters unsafe financial claims. |
| Trading signals | `SignalsRepository.list/get` | AURUM backend only. Contract includes direction, thesis, entry **zone**, invalidation, time horizon, risk label, status, timestamp, source/version, and disclaimer. |
| User profile and settings | `UserRepository` | AURUM backend for authenticated sync; cache non-sensitive preferences locally. |
| Watchlists | `WatchlistRepository` | Local-first, account-sync conflict policy defined server-side. Queue only safe idempotent mutations. |
| Notifications | `NotificationRepository` | FCM/APNs brokered through backend. User permission is explicit; device tokens are revocable. |

### Backend boundary

The mobile app may talk to the **AURUM API** only for protected operations. The AURUM API, not the Flutter APK, owns provider API keys, AI model keys, rate-limit credentials, signal generation logic, normalization, entitlement checks, caching and audit trails. A limited public market endpoint may be used during a prototype only if its terms/rate limits permit it and it needs no secret; this is not the production security model.

Suggested endpoint families (contract sketches, not a final implementation):

```text
GET  /v1/markets?sort=market_cap&cursor=...
GET  /v1/assets/{id}
GET  /v1/assets/{id}/candles?interval=1h&from=...&to=...
GET  /v1/assets/{id}/indicators?set=overview
GET  /v1/market-pulse
GET  /v1/signals?status=active&cursor=...
GET  /v1/signals/{id}
POST /v1/ai/analyses
GET  /v1/ai/analyses/{id}
GET/PUT /v1/me/watchlist
GET/PUT /v1/me/preferences
POST /v1/devices/push-token
```

All server payloads need a schema, UTC ISO-8601 timestamps, explicit nullability, pagination limits, an `asOf` freshness timestamp, a correlation/request ID, and an API version policy. Decide with backend/legal stakeholders which market data license permits display, caching, derived indicators, and redistribution before implementation.

### Caching and request policy

- Cache market overview and asset metadata with short TTLs; tag all cached data with `asOf`.
- Cache chart intervals by `(assetId, interval, timeRange)` and update only the final candle when a live tick arrives.
- Keep watchlist changes local-first, encrypted if user data classification requires it, and reconcile on login.
- Debounce search; cancel superseded search and chart requests.
- Back off exponential retry only for safe idempotent reads. Honor server rate limits; never retry authorization or validation failures automatically.
- Paginate markets/signals with cursor-based loading and load-more thresholds, not a full universe fetch.

---

## 9. Security, privacy, and reliability plan

### Authentication and sessions

1. Authenticate using a vetted identity provider or AURUM backend OAuth/OIDC flow with PKCE; never collect credentials through a custom, unreviewed flow.
2. Keep access tokens short-lived; rotate refresh tokens server-side. Store session secrets only with `flutter_secure_storage`.
3. Attach authorization centrally via the configured HTTP client. On refresh failure, atomically clear the session and route to sign-in without losing safe unsynced preferences.
4. Support explicit sign-out, device/session revocation where backend supports it, and account deletion workflow required by the product’s privacy policy.
5. Guest mode can read non-account market data. Watchlist cloud sync, AI history, alerts, and profile data require an authenticated session. This exact entitlement policy needs product approval.

### Secrets and transport

- HTTPS only, modern TLS, hostname verification, conservative timeouts, and no logging of authorization headers, tokens, prompts containing PII, or raw account data.
- No market-provider, AI-provider, signing, or privileged API key in Dart, assets, source control, `--dart-define`, or a distributed APK.
- Use server-side allowlisting, rate limiting, abuse protection, and request authentication. Consider certificate pinning only with a documented rotation/failure strategy; it is not a substitute for TLS or backend controls.
- Android release builds must use a protected signing key and CI/secret store; enable R8/minification only after mapping-file and crash-reporting handling are verified.

### Data protection and input safety

- Validate all UI inputs locally for immediate feedback and validate all inputs/authorization on the server as authoritative.
- Treat provider/AI/notification content as untrusted display data. Escape/avoid rendering arbitrary HTML and validate every JSON schema.
- Minimize collection. Do not record full prompts, portfolio-like data, device IDs, or tokens in analytics/crash logs. Publish retention and deletion behavior.
- Mask sensitive fields in debug logs. Disable verbose network logging in release builds.

### Resilience and market safety

- Display `Last updated`, source availability, and stale/offline states; do not silently show stale values as live prices.
- Use a bounded error/retry UX and a global outage banner when appropriate.
- Every signal and AI screen includes a concise “analysis only, not financial advice” disclosure; signal uncertainty and invalidation are first-class information.

---

## 10. Premium UI/UX design system

### Visual direction

**AURUM Obsidian** is a restrained dark financial interface: graphite surfaces, off-white text, calibrated market color, and champagne-gold used as a limited signature. It feels closer to a premium research terminal than a game, exchange casino, or generic Flutter starter. There are no large colorful gradients. Depth comes from tonal surfaces, 1px low-opacity strokes, generous negative space, and data hierarchy.

### Color tokens

| Token | Hex | Use |
| --- | --- | --- |
| `ink` | `#090B0F` | Root background / immersive chart canvas |
| `canvas` | `#0F1218` | Screen background |
| `surface` | `#151922` | Standard panels, inputs, sheets |
| `surfaceElevated` | `#1B202A` | Raised cards and selected controls |
| `surfacePressed` | `#252B36` | Press/active neutral state |
| `lineSubtle` | `#2A303B` | Borders, dividers, chart guides |
| `gold` | `#D8B45A` | Brand accent, focused controls, restrained highlights |
| `goldSoft` | `#F2D27A` | Premium emphasis on dark backgrounds |
| `textPrimary` | `#F5F7FA` | Headlines and key values |
| `textSecondary` | `#B2BAC7` | Standard supporting text |
| `textTertiary` | `#7D8797` | Metadata / inactive labels |
| `positive` | `#35C98A` | Gain, bullish / confirmed positive state |
| `negative` | `#F07178` | Loss, bearish / caution reversal state |
| `warning` | `#F1B75B` | Risk / attention, distinct from brand emphasis |
| `info` | `#7AA9FF` | Non-market informational state |

Positive and negative values always also carry `+`/`−`, arrows, and descriptive text; color alone is never semantic. Gold is not a success signal and must not make a claim look verified.

### Typography

Bundle/licence-confirm the selected fonts rather than relying on a device font. Proposed pairing:

| Role | Typeface / fallback | Size / line height | Weight / treatment |
| --- | --- | --- | --- |
| Brand / display | Manrope / system sans | 28–32 / 36–40 | 700–800, tight but readable |
| Page title | Manrope / system sans | 24–28 / 32–36 | 700 |
| Section title | Manrope / system sans | 17–20 / 24–28 | 650–700 |
| Body | Manrope / system sans | 14–16 / 20–24 | 400–500 |
| Label / metadata | Manrope / system sans | 11–12 / 16 | 600; modest tracking only where useful |
| Price / market figures | IBM Plex Mono / tabular system fallback | 20–30 / 28–36 | 600–700, `tabularFigures` |
| Row price / percentage | IBM Plex Mono / tabular system fallback | 13–16 / 20 | 500–600, right aligned |

Support text scaling through layout—not hard height boxes. Essential values wrap/scale as needed; decorative labels may truncate only if their complete value is available semantically.

### Layout, shape and motion

- **Grid:** 4 pt base grid; standard screen padding 20 dp; compact internal spacing 8/12 dp; section rhythm 24/32 dp.
- **Targets:** 48 × 48 dp minimum for primary tap targets; do not make small chart controls inaccessible.
- **Corners:** 12 dp field/chip, 16 dp standard card, 20 dp hero/analysis card. Avoid excessive roundness.
- **Borders/elevation:** 1 dp `lineSubtle`; tonal elevation before shadows. If a shadow is used, keep it black and very low opacity.
- **Motion:** 160–220 ms ease-out for press/expand/fade. Respect reduced-motion platform settings. Never animate price changes in a misleading way and never autoplay distracting charts.
- **Icons:** a single consistent outlined icon family, 20/24 dp, labelled where meaning could be ambiguous.

### Component inventory and behavior

| Component | Specification |
| --- | --- |
| Primary button | Gold fill with ink text, 48 dp height, clear disabled/loading state. Used sparingly for committed actions such as “Generate analysis.” |
| Secondary / tonal button | `surfaceElevated` with light text and hairline border; used for filters and reversible actions. |
| Text button | Gold-soft text with 48 dp target; no tiny tap labels. |
| App bar | 64 dp visual rhythm; title left; only high-value actions right (search, notifications, add). A compact bottom border rather than a generic material shadow. |
| Bottom navigation | Five stable destinations; dark elevated dock, icon + text label, gold active indicator/hairline, safe-area aware. Preserve each tab stack. |
| Search | Full-width dark surface, leading search icon, clear action, 48 dp touch height, debounced state and recent searches. |
| Segmented tabs / timeframe | Compact grouped control with fully visible selection, text plus underline/surface state; values are not lost behind scrolling without an overflow action. |
| Filter chip | Neutral outline at rest, selected gold-tinted surface plus checkmark/text—not color only. |
| Market / coin row | Asset mark, name/symbol, current price in tabular numerals, signed 24h change and mini trend. Entire row opens detail; watch action is separate. |
| Premium card | One semantic purpose per card. 16 dp radius, 16–20 dp padding, subtle line, headings and metadata aligned to common baseline. |
| Chart container | Full-width high-contrast plotting area; selectable timeframe and indicator controls, crosshair/value readout, skeleton state, a textual summary alternative. |
| Signal card | Direction label, asset pair, status, observed/issued time, thesis, entry zone, invalidation, risk badge and disclosure. No green “buy now” imperative. |
| AI analysis card | Assessment (`Bullish`, `Neutral`, etc.), model confidence described as uncertainty not certainty, data timestamp, evidence bullets, risk note, source/model version. |
| Indicator | Text + icon + label; `RSI 58.2` never only a colored dot. Explain through details sheet. |
| Loading | Skeleton geometry matches final content; use a small inline progress indicator for refresh rather than blocking usable cached content. |
| Empty | Purposeful icon, one sentence, optional action, e.g. “Your watchlist is clear. Add an asset from Markets.” |
| Error | Plain-language issue + effect + recovery; retain cached content where safe. Add retry and support/error ID as appropriate. |
| Dialog / bottom sheet | Dialog for destructive/auth-confirming decisions. Bottom sheet for filters, timeframe, indicator selection and short task flows; focus/keyboard safe. |

### Accessibility and responsive rules

- Build and test at 320 dp, 360 dp, 393 dp and 430+ dp portrait logical widths, plus 1.0x, 1.3x and 1.5x text scale.
- Use `SafeArea`, `LayoutBuilder`, intrinsic flexible rows, scrollable content and keyboard insets; never use fixed screen-height dashboard cards.
- Chart width follows available width; its minimum viable plot height is protected while labels/controls move to a second line on narrow devices.
- Use screen-reader labels for charts (current, change, range, data time), icon buttons, statuses, and chart gestures. Verify reading order and contrast.
- Test low network, offline, locale/currency expansion, and an Android system back action on a physical device.

---

## 11. Screen specifications

### 11.1 Overview — “Market Pulse”

**Purpose:** answer what is happening now and what the user should investigate next.

1. Compact AURUM wordmark, notifications, account affordance.
2. Market Pulse hero: market sentiment gauge with source/time and a conservative label, not an instruction.
3. A focused market overview chart and visible as-of time.
4. Featured assets (BTC, ETH, selected mover) with price, signed 24h change, small sparkline and touch target to details.
5. Watchlist preview with add/manage action.
6. One AI insight summary with evidence count, data time, risk disclaimer and route to AI Desk.
7. Quick actions: Explore Markets, View Signals, Create Analysis, Manage Watchlist.

**States:** skeleton on first launch; cache-first refresh; empty watchlist; partial-source warning; offline snapshot; retryable service error.

### 11.2 Markets

**Purpose:** discover, compare and select an asset without dashboard noise.

- Search with recent searches and debouncing.
- Horizontal sort/category/filter controls in a bottom sheet (rank, volume, 24h change, watchlisted).
- Paginated market rows: rank, asset identity, price, signed movement, micro chart and independent watch control.
- Explicit loading, no-results, rate-limited and stale-data states.
- Selecting a row opens a shared Asset Detail route.

### 11.3 Asset Detail

**Purpose:** give a deep, understandable analytical view of one asset.

- Pinned identity: asset mark, name/symbol, current quote, signed change, source/as-of time, watch toggle.
- Main chart with accessible value summary, 1H / 1D / 1W / 1M / 1Y controls and candle/line selection if supported.
- Technical context: RSI, MACD, moving average chips; tap opens definition/parameters and data freshness.
- Market statistics grid (market cap, 24h volume, circulating supply, high/low) that gracefully omits unavailable values.
- Latest AI analysis preview and signal preview, both time-stamped and clearly non-advisory.
- No “trade” CTA in Phase 2.

### 11.4 AI Desk

**Purpose:** provide transparent, scoped AI-assisted research.

- Asset/context picker and request form with preset questions (trend context, indicator summary, risk considerations).
- Analysis result: neutral/bullish/bearish assessment, confidence **as model uncertainty**, evidence, counterarguments, observations, methodology/model and data timestamp.
- Risk card and permanent short “Analysis only — not financial advice” text.
- Prior analysis list with status and freshness; no unbounded opaque chat transcript.
- Loading can be progressive but must not fabricate results. Failure exposes retry and safe fallback context.

### 11.5 Signals

**Purpose:** separate risk-aware signal monitoring from general market browsing.

- Active / completed / archived segmented lists plus asset/direction/risk filters.
- Card includes pair, direction (`Long context`, `Short context`, or `Watch`), issued time, entry zone, invalidation, horizon, risk label, status and thesis preview.
- Detail shows supporting indicators, price snapshot/data time, status changes, limitations and source/methodology.
- Use “analysis signal,” “context,” and “invalidation”; avoid imperative investment language.

### 11.6 Profile & settings

**Purpose:** consolidate identity and device/account controls without polluting analysis surfaces.

- Account and subscription/entitlement summary (only when applicable).
- Preferences: quote currency, locale, compact-number setting, theme policy.
- Notifications: separate granular categories and permission state.
- Security: active sessions where supported, change/sign-in method, sign out.
- Privacy/data: consent, analytics preference, export/delete account paths, legal/risk disclosures, app version/support.

### Supporting screens

- Welcome/onboarding & risk disclosure
- Sign in, sign up, account recovery and guest conversion
- Watchlist management/reorder
- Global notification inbox
- Search results / filter sheet / indicator reference sheet
- Maintenance, offline, permission and no-network states

---

## 12. Premium visual concept

The generated design reference is stored at:

[`assets/design/aurum_phase_1_premium_ui_concept.png`](../assets/design/aurum_phase_1_premium_ui_concept.png)

It is a static reference board, not an assertion that the application has already been built. It anchors the visual language for the Overview, Markets, Asset Detail, AI Desk, Signals and Profile & Settings experiences:

- Near-black/graphite background with controlled champagne-gold branding.
- Data-forward spacing, tabular prices, emerald/coral market direction and clear hierarchy.
- Professional chart surfaces without neon effects or generic gradient cards.
- Evidence/risk-bearing AI and signals presentation rather than profit-oriented claims.
- Five-destination bottom navigation consistent with the recommended navigation map.

Before any production UI implementation, approve or adjust: (1) the Obsidian + Gold palette, (2) the editorial typography pairing, (3) the five-tab information architecture, and (4) the conservative analysis/risk vocabulary.

---

## 13. Performance and quality gates

### Performance requirements

- Render only visible list rows; paginate markets and signals. Do not fetch the full market universe upfront.
- Scope Riverpod providers by asset ID/timeframe and use `select`/small consumers to avoid rebuilding the whole dashboard for one quote update.
- Throttle/coalesce WebSocket updates and pause streams for inactive screens/app background. Use only REST refresh initially if it is sufficient.
- Isolate expensive candle/indicator parsing or calculation if profiling on a real phone proves UI jank.
- Resize/cache remote asset imagery, use placeholders, and provide deterministic fallback initials.
- Measure on a physical mid-range Android device: first usable view, tab switch, chart range change, list scroll, memory after repeated asset navigation, and poor-network recovery.

### Test plan

| Layer | Required checks |
| --- | --- |
| Static | `dart format`, analyzer, strict lint rules, dependency audit. |
| Unit | Mappers, repositories, use cases, parsing/validation, indicator/signal/risk formatters, token/session behavior. |
| Widget | Design-system states, text scaling, screen loading/empty/error/data branches, keyboard/bottom-sheet behavior. |
| Golden | Core desktop-independent mobile surfaces at approved widths and both color schemes if a light theme is later added. |
| Integration | Launch/session gate, search → detail, watchlist persistence, signal detail, AI request failure/success schema, navigation back behavior. |
| Device | USB physical Android debug/release smoke test, Android back, permission denial, offline/reconnect, orientation policy, TalkBack, 1.3–1.5x font scale. |

Continuous integration should run format verification, analysis, unit/widget tests, and a debug Android build. Release signing and secret injection should occur only in secured CI after the codebase exists.

---

## 14. Phase 2 implementation plan (after approval)

1. **Lock product contracts.** Approve the visual direction, guest/auth entitlement, market-data licensing/provider, backend ownership, signal methodology/disclaimers and AI schema/safety policy.
2. **Create the Flutter baseline.** Bootstrap a current stable Flutter project, Android host, lint rules, `.gitignore`, VS Code debug configuration, flavor/config pattern, `README`, CI debug build and physical-device run instructions.
3. **Build core composition.** Add `AppConfig`, router shell, design tokens/theme, typography assets/licensing, error/failure model, `Dio` client, secure session abstraction, logging/observability abstraction and accessibility defaults.
4. **Implement the reusable design system.** Build and golden-test app bar, navigation shell, buttons, fields, cards, chips, list rows, skeleton/empty/error state and accessible chart container.
5. **Establish contract-first data foundations.** Define domain entities/DTOs/mappers/repositories; implement mock/fake data sources behind interfaces; write fixture-backed tests. No secret or provider key enters Flutter.
6. **Build core flows vertically.** Overview, Markets search/list, Asset Detail, local watchlist and responsive state branches using the approved visual language.
7. **Integrate approved backend services.** Add authenticated endpoints, quote/cache policy, charts, technical indicators, signal feed and rigorous API failure handling.
8. **Add AI Desk and notification/preferences flows.** Integrate only the reviewed server-side AI schema; enforce data time, model version, risk language, safe failures and account/permission boundaries.
9. **Harden and validate.** Perform real-device performance profiling, offline/retry validation, accessibility sweep, security review, privacy/log review, release build/signing readiness and APK smoke test.
10. **Prepare Phase 3 scope.** Reassess user feedback and data costs before any trade execution, broker, or advanced automation feature is contemplated.

### Explicit Phase 2 exit criteria

- The app launches and hot-reloads on a USB-connected physical Android phone from VS Code.
- Every core screen implements data, loading, empty, error and stale-data states with no overflow at agreed device widths/text scaling.
- UI contains no direct HTTP calls or secrets; core flows use repository contracts.
- AI and signal surfaces carry evidence, timestamps, risk/invalidation context and non-advisory language.
- Automated checks and real-device smoke tests are documented and passing.

---

## 15. Approval checkpoint

**Implementation is intentionally paused at Phase 1.** Approval is requested for this foundation before Flutter code is created:

- [ ] AURUM’s analysis-only product scope and risk language
- [ ] Feature-first clean architecture (Flutter + Riverpod + GoRouter)
- [ ] Five-item navigation: Overview, Markets, Signals, AI Desk, Profile
- [ ] Obsidian/graphite interface with restrained champagne-gold accent
- [ ] Mobile concept reference image and information hierarchy
- [ ] Backend-only protection for market-provider and AI secrets
- [ ] Phase 2 order and physical-Android-first workflow

Once approved, Phase 2 begins with the Flutter project baseline and design-system foundation—not a rushed full-app build.
