# AURUM — Phase 2 UI/UX Specification & Mobile Application Blueprint

**Status:** Final implementation blueprint — Flutter feature work is deliberately blocked until this Phase 2 direction is approved.
**Carries forward:** Phase 1 product boundary, architecture findings, Obsidian visual direction, Riverpod, GoRouter, backend-secret boundary, and Android-physical-device-first workflow.
**Technology lock:** Flutter + Dart, VS Code, Android SDK, physical Android device via USB debugging. The customer application is mobile Flutter software—not a web application.

---

## 0. Phase boundary and decisions locked in this blueprint

This document translates the approved Phase 1 foundation into an implementation-ready product specification. It does **not** create Flutter screens, a `pubspec.yaml`, Android host files, APIs, or placeholders. Those are Phase 3 work after this blueprint receives approval.

### Locked product principles

1. **AURUM is a market-analysis and decision-support product.** It displays market data, technical context, watchlists, AI-assisted research, and analysis signals. It does not promise outcomes and Phase 3 does not include trade execution, custody, deposits, withdrawals, or broker connections.
2. **Data context is part of every claim.** Market values have a source and `as of` time. AI and signal information has a data timestamp, model/methodology version, evidence, risk context, and non-advisory disclosure.
3. **The visual system is dark-only for the first production release.** A focused dark theme yields consistent chart contrast, calmer financial data density, and a smaller accessibility/test surface. A light theme is a future product decision, not an incomplete theme toggle.
4. **One state-management solution: Riverpod.** No BLoC, Redux, Provider, MobX, or ad-hoc inherited state management is introduced for application state.
5. **One navigation system: GoRouter.** A stateful tab shell retains primary-workspace history. Modal sheets and dialogs are route-driven or controller-owned overlays, never a second navigation framework.
6. **The Flutter client owns presentation and user intent, not private credentials or model/provider decisions.** The AURUM backend owns private market-data and AI credentials, normalization, entitlement, rate policy, and signal/AI safety checks.

### Phase 3 prerequisites

Before a Flutter line of feature UI is written, confirm the following with product/backend/legal stakeholders:

- Market-data provider, redistribution/caching rights, exchange symbol policy, and service-level/rate-limit expectations.
- Auth identity provider and guest-to-account entitlement policy.
- AURUM backend endpoint contracts, error schema, environments, and API versioning.
- AI-analysis response schema, data sourcing, model/version disclosure, guardrails, retention and feedback policy.
- Signal methodology, owner, publication/review policy, terminology, jurisdictional disclosures, and removal/escalation process.
- Brand-font licence and permitted asset/icon licences.

---

## 1. Product experience model

### The primary user questions

AURUM’s navigation and screen hierarchy answer questions in priority order:

| User question | AURUM workspace | Design response |
| --- | --- | --- |
| What matters in the market right now? | Overview | Market Pulse, sentiment, featured/trending assets, watchlist context and one concise AI observation. |
| Which assets should I inspect? | Markets | Search, category and sort filters, price, movement, volume and market-cap context. |
| What does this asset’s context look like? | Asset Detail | Price, time range, readable chart, indicators, statistics, related analysis and risk information. |
| What are the current analytical signals? | Signals | Active and historical items with asset, direction/context, strength, evidence, status, freshness and invalidation/risk. |
| How does AURUM interpret the data? | AI Desk | Evidence-led AI brief, scenarios, counterpoints and risk—not a chat-first experience. |
| What is saved, new, or personal? | Watchlist, Notifications, Profile | Secondary routes focused on the task, not competing with core market work. |

### Home-dashboard interpretation of “portfolio/market overview”

The Phase 3 core dashboard includes a **Market Overview** rather than a personal holdings balance. AURUM has no custody/execution scope and must not manufacture a “portfolio” from unclear data. If a future product obtains clear consent and a valid data source for user-entered or connected holdings, an optional Portfolio Summary may occupy the existing Market Overview slot. It is not assumed in the initial build.

### Content hierarchy for a market value

Every visible asset price follows this order:

```text
Asset identity  →  current price  →  signed period movement  →  period / source / freshness
```

This prevents a visually attractive chart or colored percentage from being mistaken for an instruction. Positive/negative color is always paired with an arrow and signed text such as `+3.42%` or `−1.24%`.

---

## 2. Complete screen map

### 2.1 Entry, initialization, onboarding and authentication

| ID / route | Screen | Purpose and key content | Primary actions | Required states |
| --- | --- | --- | --- | --- |
| `E01 /launch` | **AURUM Splash** | Obsidian canvas, centered gold AURUM wordmark, a small orbit/line initialization motif, accessible status text. It exists only while bootstrap resolves config, local migration, consent and session state. | None; no marketing CTA. | Initializing, maintenance redirect, unrecoverable configuration error. |
| `E02 /onboarding` | **Welcome** | One focused value proposition: live market context, technical tools, AI-assisted research. No carousel longer than three pages. | Continue; Sign in; Continue as guest if approved. | First launch; returning incomplete onboarding. |
| `E03 /onboarding/market-intelligence` | **How AURUM helps** | Explains market data, charts, technical indicators, watchlists, signals and limits of AI assistance with simple visual examples. | Continue; Back. | Static, accessible image/text alternative. |
| `E04 /onboarding/risk` | **Risk & data disclosure** | Plain-language analysis-only statement, market-volatility warning, data freshness/source explanation, privacy links and consent checkbox/acknowledgement. | Acknowledge & continue; Back. | Consent required; link opening failure handled non-destructively. |
| `E05 /auth/sign-in` | **Sign in** | Email/identifier and password or approved external identity button; concise guest conversion message. | Sign in; Forgot password; Create account; Continue as guest. | Form validation, submitting, invalid credentials, locked/rate-limited, offline. |
| `E06 /auth/sign-up` | **Create account** | Minimal required fields, password rules if password auth is approved, Terms/Privacy links and consent. | Create account; Sign in. | Field errors, submitting, duplicate account, service unavailable. |
| `E07 /auth/verify` | **Verify account** | Explains verification destination and expiry; one-time-code field only if backend uses it. | Verify; Resend; Change email. | Countdown, invalid/expired code, resend cooldown, success. |
| `E08 /auth/forgot-password` | **Password recovery** | Email/identifier input and clear message that the reset is delivered out of band. | Send reset link; Back to sign in. | Validation, generic success (avoid account enumeration), rate-limited/error. |
| `E09 /auth/session-expired` | **Re-authentication gate** | Preserves non-sensitive draft context where safe; says session ended without exposing why. | Sign in again; Sign out. | Refresh in progress, recovery error. |

**Splash behavior:** It is not a fixed-delay logo screen. Initialization resolves in this order: validated app configuration → local storage/migration → disclosure/onboarding status → secure session refresh → maintenance/force-update policy → route decision. A standard completed startup should not keep the user on splash longer than the actual work, and never uses an unskippable decorative animation as a fake loading signal.

### 2.2 Primary-workspace screens

| ID / route | Screen | Purpose and information hierarchy | Key interactions | States to design before coding |
| --- | --- | --- | --- | --- |
| `P01 /app/overview` | **Overview — Market Pulse** | Greeting/account affordance → market overview & sentiment → featured/trending assets → watchlist preview → AI market insight → signal preview → quick actions. | Open asset, manage watchlist, open signals, open AI Desk, refresh, notifications. | First-load skeleton; fresh/cached/stale market data; no watchlist; partial provider data; offline; retry. |
| `P02 /app/markets` | **Markets** | Search → category/sort summary → paginated ranked market list with price, signed 24h move, volume, market cap and watch control. | Search; filters/sort sheet; category; pagination; toggle watch; open asset. | Loading rows; empty result; rate limit; cached/stale; unavailable provider. |
| `P03 /app/signals` | **Signals** | Active / history tabs → filter summary → risk-aware signal cards ordered by issued/update time. | Filter; inspect signal; refresh; save/alert action only where entitlement permits. | Skeleton; no active signals; filtered empty; stale; service unavailable. |
| `P04 /app/ai` | **AURUM AI Desk** | Market overview / selected asset → analysis composer → current result → recent analysis history. A result is evidence-led, not a generic chat transcript. | Choose asset/context; select analytical question; request analysis; inspect history; provide quality feedback. | Initial overview loading; generation in progress; schema-safe result; unavailable; queued/rate-limited; stale history. |
| `P05 /app/profile` | **Profile & Settings** | Account identity/guest conversion → preferences → notifications → security → appearance → privacy/data → about/support → sign out. | Navigate to settings; sign in/up; logout; account deletion request. | Guest, authenticated, sync in progress, unavailable settings, destructive confirmation. |

### 2.3 Secondary task screens and overlays

| ID / route or presentation | Screen | Purpose and mandatory content |
| --- | --- | --- |
| `S01 /watchlist` | **Watchlist** | Full saved-asset list, price/movement, alert indicator, sort/reorder if supported, add-assets empty action. It is reached from Overview, Markets and a Profile shortcut—not a primary tab. |
| `S02 /notifications` | **Notification inbox** | Grouped signal alerts, price alerts, market updates and system notices. Each item has type icon/label, timestamp, unread state, destination/deep link and mark-read action. |
| `S03 /markets/search` | **Market Search** | Full-focus search surface with keyboard-safe input, debounced results, recent searches stored locally, no-results and error handling. May present as a full-screen route on phones. |
| `S04 /markets/filter` | **Market Filters & Sort** | Bottom sheet with category, rank/volume/movement sort, watchlisted toggle and reset/apply actions. Selections are text-visible and announced. |
| `S05 /asset/:assetId` | **Asset Detail** | Asset identity/watch toggle → price and selected-period move → data freshness → chart → timeframe / chart type / indicator controls → market statistics → AI preview → signals preview → risk/info. |
| `S06 /asset/:assetId/chart` | **Expanded Chart** | Distraction-minimized chart workspace with candle/line mode, volume, selected overlays, crosshair readout, timeframe, pan/zoom/reset and accessible textual summary. |
| `S07 /asset/:assetId/indicators` | **Indicator Reference & Selector** | RSI, MACD, EMA and later approved indicators with description, parameters, currently selected state and source/calculation version. Never imply an indicator gives a certain outcome. |
| `S08 /asset/:assetId/analysis` | **Asset AI Analysis** | Same analysis-result component as AI Desk, pre-scoped to asset with data time and result history. |
| `S09 /signals/:signalId` | **Signal Detail** | Asset/pair, direction/context, strength, price snapshot, issued/updated timestamps, status timeline, supporting indicators, entry zone if sanctioned, invalidation, risk level, evidence/source and disclosure. |
| `S10 /ai/new` | **New Analysis** | Asset/context selection and structured prompt choices such as trend context, indicator interpretation or risk factors. Free form text is optional only if privacy policy and server-side controls support it. |
| `S11 /ai/:analysisId` | **Analysis Detail** | Immutable rendered analysis: assessment, model confidence as uncertainty, market/technical summary, observations, scenarios, counterpoint/risk, model/data/version and feedback. |
| `S12 /profile/account` | **Account** | Basic identity, verified state, account-link management and guest conversion. Avoid displaying secrets or security-sensitive data. |
| `S13 /profile/preferences` | **Preferences** | Quote currency, locale/number display, default market filters and data-refresh behavior. |
| `S14 /profile/notifications` | **Notification Preferences** | Signal, price, market and system categories; OS permission status; platform-settings deep link only when needed. |
| `S15 /profile/security` | **Security** | Sign-in method, active sessions/device management if supported, change credentials/reauthentication path and secure sign-out. |
| `S16 /profile/appearance` | **Appearance** | Dark-theme explanation, reduced motion, compact number preference and text/display guidance. It does not expose an unfinished light-theme toggle. |
| `S17 /profile/privacy` | **Privacy & Data** | Consent/analytics controls, data-use explanation, export/delete-account pathways, legal disclosures and retention links. |
| `S18 /profile/about` | **About & Support** | Version/build, market-data attribution, licenses, support route and legal links. |
| `S19 modal` | **Alert creation/editing** | Future-entitlement modal for price/signal alert threshold, direction, frequency and permission explanation. It is omitted rather than shown disabled if backend support is unavailable. |
| `S20 modal` | **Confirmation dialog** | Sign out, account deletion start, remove from watchlist when destructive preference applies. Explains consequence and exposes cancel as the safe default. |

### 2.4 System and exception screens

| ID | Screen/state | Requirement |
| --- | --- | --- |
| `X01` | No connection / offline snapshot | Continue showing safely cached data marked **Last updated**; offer Retry; do not label it live. |
| `X02` | Service maintenance | Clear, calm message, status/support link and retry; avoid blaming the user. |
| `X03` | Force update | Only when a backend contract/security rule makes continuation unsafe; describe action and route to store/update process. |
| `X04` | Unsupported/removed asset | Explain that the asset is no longer available from the selected source, preserve ID/name where possible and offer Back to Markets. |
| `X05` | Permission denied | Explain the benefit and provide Settings/Not now. Never repeatedly trap the user in a permission prompt. |
| `X06` | Global unknown error | Preserve navigation where possible, short recovery language, Retry/Back, and an optional non-PII support correlation ID. |

---

## 3. Final navigation blueprint

### 3.1 Primary navigation decision

AURUM uses **five persistent primary destinations** in a `StatefulShellRoute`:

```text
Overview      Markets      Signals      AI Desk      Profile
```

This is an intentional decision, not a generic five-tab copy:

| Destination | Why it is primary | Why it is not merged elsewhere |
| --- | --- | --- |
| **Overview** | It is the fastest answer to “what changed and what matters?” and is the natural launch workspace. | A dense market list would dilute its scan-first role. |
| **Markets** | Discovery/search/filtering is a frequent, focused task with a long list and its own history. | It cannot be reduced to a dashboard widget without making comparison difficult. |
| **Signals** | Risk-bearing, time-sensitive analysis needs clear separation and a stable history/filters workspace. | It must not be visually buried under a home feed or AI output. |
| **AI Desk** | AI-assisted research needs a named, inspectable workspace and retained analysis history. | A floating magic button or generic chat tab obscures provenance and context. |
| **Profile** | Account/consent/security are lower frequency but must remain discoverable and stable. | It prevents personal configuration from intruding on market work. |

**Watchlist** is deliberately secondary. It is a saved view of assets, reached in one tap from the Overview preview, Markets watch control, Search, or Profile shortcut. Giving it a sixth tab would exceed the comfortable primary-navigation limit and weaken Signals/AI discovery. **Notifications** are also secondary because users respond to an event and deep link, rather than browse them as a continuous market workspace.

### 3.2 Shell behavior and small-screen rules

- The bottom bar is persistent only on the five primary routes; pushed details cover it when that improves focus, while their parent tab’s state remains alive.
- Each tab maintains an independent back stack. Reselecting its current tab scrolls to the top or returns to its root only after an explicit product-tested rule; it never silently loses filter/search state.
- On Android system back: close keyboard → close sheet/dialog → pop detail → return to current tab root → allow normal system exit behavior. Back never jumps unexpectedly between tabs.
- Bar height is safe-area aware with a **minimum 64 dp visual dock plus device inset**, 48 dp minimum target per destination, icon + text label for every item, and a gold active indicator that is not the only selected cue.
- At 320–359 dp widths, labels remain visible using compact typography and equal flexible slots; they must not become unlabeled icons or overlap. Test this before locking the implementation.
- There is **no global floating action button**. A large floating control would compete with financial data, obstruct charts, and imply an urgent execution action. Contextual actions are placed where their meaning is clear: asset watch toggle in app bar; Markets search/filter in app bar; AI “New analysis” as a full-width in-context button; Overview quick-action row.

### 3.3 Navigation flow

```text
Launch
 ├─ first launch → Welcome → How AURUM helps → Risk disclosure → Guest or Sign in
 ├─ unauthenticated returning user → Guest app shell or Sign in
 ├─ valid session → App shell / Overview
 └─ expired session → Re-authentication → return to safe intended route

App shell
 ├─ Overview
 │   ├─ Market/featured/watchlist asset → Asset Detail → Chart / Indicators / AI analysis / Signal detail
 │   ├─ Watchlist preview → Watchlist → Asset Detail
 │   ├─ AI insight → AI Desk / Analysis Detail
 │   ├─ Signal preview → Signals / Signal Detail
 │   └─ Notification bell → Notification inbox → relevant detail
 ├─ Markets
 │   ├─ Search → Market Search → Asset Detail
 │   ├─ Filter/sort → bottom sheet → Markets (updated query)
 │   └─ Watch toggle → Watchlist state update
 ├─ Signals → filters → Signal Detail → Asset Detail or Analysis Detail
 ├─ AI Desk → New Analysis → Analysis Detail → Asset Detail / Signal Detail
 └─ Profile → Account / Preferences / Notifications / Security / Appearance / Privacy / About
```

Deep links from notifications must resolve through the session gate first, then restore an authorized target route. If an item has expired/been removed, show the relevant unavailable state and a clear return destination.

---

## 4. AURUM Obsidian design system

### 4.1 Visual personality

**AURUM Obsidian** is a dark, composed research environment. Its luxury comes from restraint: graphite depth, warm metallic gold only where focus is deserved, precise data alignment, low-noise charting, and content that reads as analysis rather than promotion. It avoids neon exchange aesthetics, rainbow gradients, high-saturation status surfaces, cartoon illustrations, and generic Material elevation.

### 4.2 Color system

All colors below are semantic tokens, not arbitrary local widget values. Flutter theme extensions expose the semantic name; widgets never ask for “dark gray 2.”

| Token | Value | Usage |
| --- | --- | --- |
| `aurumInk` | `#090B0F` | Root background, expanded chart canvas, splash. |
| `aurumCanvas` | `#0F1218` | Standard page canvas. |
| `aurumSurface` | `#151922` | Inputs, standard panels, sheets. |
| `aurumSurfaceElevated` | `#1B202A` | Selected/raised card, active control background. |
| `aurumSurfacePressed` | `#252B36` | Pressed state, non-destructive selected neutral. |
| `aurumCard` | `#171B24` | Primary information card surface. |
| `aurumBorder` | `#2A303B` | 1 dp subtle borders, chart grid, dividers. |
| `aurumBorderStrong` | `#3B4350` | Focused but neutral border. |
| `aurumGold` | `#D8B45A` | Brand mark, primary action, selected navigation, restrained emphasis. |
| `aurumGoldSoft` | `#F2D27A` | Gold foreground/hover emphasis on dark surfaces. |
| `aurumTextPrimary` | `#F5F7FA` | Page titles, primary values, critical body text. |
| `aurumTextSecondary` | `#B2BAC7` | Supporting body, labels and unselected text. |
| `aurumTextTertiary` | `#7D8797` | Metadata, source/as-of timestamps, inactive labels. |
| `aurumPositive` | `#35C98A` | Positive signed movement, bullish context, healthy status. |
| `aurumNegative` | `#F07178` | Negative signed movement, bearish context, destructive action. |
| `aurumWarning` | `#F1B75B` | Risk/attention state. It is visually distinct from brand gold. |
| `aurumInfo` | `#7AA9FF` | Informational system state, neutral context. |
| `aurumFocus` | `#8DB4FF` | Keyboard/switch-access focus ring, chosen for visible contrast. |

Rules:

- `aurumGold` signals focus, brand, selection or a single primary action—**never** bullishness, trustworthiness, certainty or profit.
- Gains/losses use `positive`/`negative` alongside a signed value, arrow direction and text label. Color does not carry the meaning alone.
- All text/background combinations are checked at their actual font size; normal-size essential text targets WCAG AA contrast or better. Muted labels never carry critical values by themselves.
- Chart series use no more than three simultaneous semantic colors. Indicator lines use named labels/patterns in the legend, not color alone.

### 4.3 Typography and numeric hierarchy

**Font pair (bundled after licence confirmation):**

- **Manrope** for the wordmark-adjacent headings, labels and body. It feels contemporary and calm without display theatrics.
- **IBM Plex Mono** for market figures, timestamps where alignment helps, prices and percentages. Its tabular figures make price columns stable during updates.
- Platform fallbacks: `Roboto` / the Android sans family and system tabular figures. Do not use a network-loaded font at runtime.

| Token | Family | Size / line height | Weight | Use |
| --- | --- | ---:| ---:| --- |
| `display` | Manrope | 32 / 40 sp | 800 | Splash wordmark-adjacent title, large empty/system state. |
| `h1` | Manrope | 28 / 36 sp | 750 | Page title / screen hero. |
| `h2` | Manrope | 22 / 28 sp | 700 | Major section or asset title. |
| `h3` | Manrope | 18 / 24 sp | 700 | Card/section title. |
| `bodyLarge` | Manrope | 16 / 24 sp | 500 | Primary explanatory body. |
| `body` | Manrope | 14 / 20 sp | 500 | Standard body and list metadata. |
| `label` | Manrope | 12 / 16 sp | 650 | Control label, chip, compact UI. |
| `caption` | Manrope | 11 / 16 sp | 500 | Source, freshness and minor metadata. |
| `priceHero` | IBM Plex Mono | 30 / 36 sp | 650 | Asset-detail current price. |
| `priceCard` | IBM Plex Mono | 20 / 28 sp | 600 | Overview/current market card price. |
| `priceRow` | IBM Plex Mono | 14 / 20 sp | 550 | Market/signal row price. |
| `percentageHero` | IBM Plex Mono | 16 / 24 sp | 650 | Main signed period movement. |
| `percentageRow` | IBM Plex Mono | 12 / 16 sp | 600 | Compact signed change. |

Numeric rules:

- Use `FontFeature.tabularFigures()` for prices, percentages, time and aligned market rows.
- Monospaced digits do not replace accessible prose: `+3.42% today` remains semantic text, not a drawn canvas label.
- Price precision obeys product currency/asset rules; never use placeholder dollar signs for all quote currencies.
- Large values use a clear compact convention (for example, `$1.24B`) with an accessible full-value label and a preference to disable compact numbers.
- Text scales with the operating-system setting. Do not cap the text scale globally; reflow content, increase row height and move secondary content below primary values when needed.

### 4.4 Spacing, layout, radius and elevation

**Spacing scale (dp):** `4, 8, 12, 16, 20, 24, 32, 40, 48, 64`.

| Application | Rule |
| --- | --- |
| Screen horizontal inset | 20 dp at 360–430 dp logical widths; shrink only to 16 dp at 320 dp after layout test. |
| App-bar rhythm | 64 dp content bar plus safe inset; 16–20 dp horizontal alignment with page content. |
| Section rhythm | 32 dp between major sections; 16–20 dp heading-to-content; 8–12 dp within a component. |
| Card padding | 16 dp standard; 20 dp for insight/hero cards; never cram a card simply to fit the viewport. |
| List row | 64 dp minimum visual height for a market row; expand for text scale/metadata rather than clip. |
| Touch target | 48 × 48 dp minimum for independent targets; 44 dp only for a dense control where adjacent separation and accessibility testing justify it. |

| Token | Value | Use |
| --- | --- | --- |
| `radiusSmall` | 10 dp | Compact chip, mini control. |
| `radiusInput` | 12 dp | Search/input field. |
| `radiusButton` | 12 dp | Buttons and segmented controls. |
| `radiusCard` | 16 dp | Standard card/market panel. |
| `radiusHero` | 20 dp | Insight/analysis hero, bottom-sheet top corners. |
| `radiusPill` | 999 dp | Only small status badges; not every card. |

Elevation is tonal first. Cards use a 1 dp `aurumBorder` and surface contrast. If depth is needed, use a single soft shadow (`#000000` at roughly 24% opacity, 12 dp blur, 4 dp y offset) only on bottom sheets, dialogs and elevated transient controls. No bright glow, hard drop shadow, or stacked shadows.

### 4.5 Iconography, imagery and interaction feedback

- Use one license-compatible outlined icon family, default 24 dp, 20 dp only in dense list cells; pair unfamiliar actions with visible text.
- Asset logos are remote data with a circular/fallback initial treatment. They never become the only asset identifier.
- No decorative hero photography is required. AURUM’s visual identity is built from data, type and subtle line motifs.
- Press feedback: 0.92–0.96 opacity/surface-tone change and optional 1–2 dp scale in 100–140 ms. Haptic feedback is reserved for confirmed actions (watch added, refresh complete), errors and destructive confirmation; honor OS settings.

---

## 5. Component library specification

### 5.1 Implementation ownership

All reusable primitives live under the design system. Feature components compose primitives and stay within their feature unless they are truly cross-feature. No screen should hand-roll a slightly different card, price row, error view or button.

```text
Design tokens + theme extensions
  ↓
Base primitives (button, card, text, state surface)
  ↓
Data-display components (price, chart shell, indicator, list row)
  ↓
Feature compositions (AI insight, signal card, asset header)
  ↓
Screen layouts
```

### 5.2 Core primitives

| Component | Variants / API intent | Behavior and accessibility |
| --- | --- | --- |
| `AurumButton` | `primary`, `secondary`, `text`, `destructive`; standard/full-width; leading/trailing icon; loading | 48 dp min height; primary is gold with ink text; disables duplicate submission; exposes semantic busy label; no icon-only primary action. |
| `AurumIconButton` | neutral, selected, destructive | 48 dp target; mandatory tooltip/semantic label; selected state has icon + tonal change. |
| `AurumCard` | standard, elevated, outlined, interactive, risk | Semantic one-purpose container; 16/20 dp radius; interactive card has focus/pressed state and no nested competing tap targets. |
| `AurumAppBar` | root, detail, search | Root uses section title + targeted actions; detail has back, concise title, optional watch/share; 64 dp rhythm and safe area. |
| `AurumBottomNavigation` | five-item app shell | Text and icon labels; active tab semantic selected state; safe inset; preserved tab stacks. |
| `AurumSearchField` | market search, compact in-page | Debounced input owned by controller; clear action; keyboard-safe; semantic hint; empty/no-result/error companion states. |
| `AurumTextField` | auth, analysis request | Visible label, helper/error text, masked secure mode, field-level validation and correct autofill type. |
| `AurumSegmentedControl` | timeframe, active/history | 44–48 dp control target; text selection plus surface/underline; supports overflow sheet only when labels cannot fit. |
| `AurumFilterChip` | neutral/selected/disabled | Text label and optional count/check; multi-select semantics; no color-only selection. |
| `AurumStatusBadge` | positive, negative, warning, neutral, info | Text such as `Active`, `Moderate risk`, `Stale`; icon/pattern where useful; not used as a vague decoration. |
| `AurumDivider` | standard, inset | Uses subtle border token; never replaces needed group headings. |
| `AurumBottomSheet` | filter, indicator, action selection | 20 dp top corners, drag handle with semantics, keyboard avoidance, explicit close and apply/reset where applicable. |
| `AurumConfirmationDialog` | destructive / irreversible | Consequence first; cancel is visually safe/default; destructive action is explicit and requires valid enabled state. |

### 5.3 Financial-data and feature components

| Component | Contents | Rules |
| --- | --- | --- |
| `AssetIdentity` | Logo/fallback, asset name, symbol, optional rank | Supports long localized name; symbol is secondary but never omitted where ambiguity exists. |
| `PriceText` | Formatted price + quote currency | Tabular typography; semantic full value; supports loading placeholder and unavailable value. |
| `PriceChangeBadge` | Signed percentage/absolute value, direction arrow, period label | Positive/negative/neutral; always label period and value; neutral state is not green/red. |
| `MarketRow` | Rank, `AssetIdentity`, `PriceText`, `PriceChangeBadge`, mini sparkline, watch toggle | Entire non-control area opens detail; watch control is its own 48 dp target; handles missing sparkline gracefully. |
| `CryptoCard` | Asset identity, price/move, mini trend, key statistic, selectable context | Used in featured/trending horizontal panels only; not a substitute for a long market list. |
| `AssetHeader` | Asset identity, quote, change, source/as-of, watch action | Asset Detail’s fixed context block; no chart duplication. |
| `MarketChart` | Chart canvas, legend, crosshair tooltip, viewport, semantic summary | Owns chart rendering adapter only; receives validated series/view model—not raw DTOs. |
| `ChartControls` | Timeframe, chart style, indicators, reset/expand | Controls never obscure plot; actions reflect selected state in text. |
| `IndicatorChip` | Indicator name, current formatted value, selected state | Opens reference/parameter surface; displays calculation/period where ambiguity matters. |
| `MarketStatGrid` | Label, value, optional help/info | 2-column at normal width, one column under compression; unavailable values show `—` with accessible explanation. |
| `AIInsightCard` | Assessment, short insight, evidence count, data time, risk qualifier | A preview routes to Analysis Detail; no opaque model conclusion without context. |
| `AnalysisBrief` | Summary, technical view, observations, scenarios, risk, provenance | Reused in AI Desk and Asset Detail; output sections are schema driven, not HTML. |
| `SignalCard` | Asset/pair, direction/context, strength, risk, status, issued time, thesis preview | Hierarchy is asset → direction/status → evidence/risk → time; avoids green “act now” treatment. |
| `SignalEvidenceList` | Indicators/evidence and source time | Explains why a signal exists; handles incomplete/unavailable evidence. |
| `WatchlistPreview` | Saved asset rows + count + manage action | Overview-specific composition; empty state routes to Markets. |
| `NotificationRow` | Type, title/body, timestamp, unread state, destination | Long press/context only if tested; reads full item as semantic content. |

### 5.4 State and feedback components

| Component | Requirements |
| --- | --- |
| `LoadingSkeleton` | Matches final geometry and spacing; does not use flashing or misleading price values; respects reduced motion. |
| `ChartLoadingState` | Fixed readable chart area with subtle grid and progress label; prevents layout jump when candles arrive. |
| `AurumEmptyState` | One purposeful icon, title, explanatory sentence and one relevant action. Example: “Your watchlist is empty. Add an asset from Markets.” |
| `AurumErrorState` | What failed + user impact + retry/alternative action. Keeps safe cached content visible where possible. |
| `AurumInlineError` | Field/component-specific error without blocking a usable page. |
| `AurumOfflineBanner` | Calm, nonmodal banner with Last updated time; disappears only when a successful fresh request occurs. |
| `AurumRefreshIndicator` | Tonal/gold restrained pull-to-refresh feedback; never disguises a failed refresh as success. |
| `AurumToast` | Brief noncritical confirmation, one at a time, accessible announcement; no essential error only in toast. |

---

## 6. Screen-level UI/UX specifications

### 6.1 Splash and onboarding

**Splash**

- Centered wordmark uses gold on ink; a fine horizontal line and a single orbit/dot is the maximum animation.
- Animation duration: 600–900 ms and loops only while genuine startup work continues. An accessibility label announces “AURUM is starting.”
- Configuration or maintenance failure transitions to a real recovery screen, not an endless logo.

**Onboarding**

- Three value pages maximum: `Market intelligence`, `Make data easier to read`, `Research with AI context`.
- Each page has one abstract data visualization, heading, short explanation and stable progress indicator; never a dense feature catalogue.
- The risk disclosure is a distinct final acknowledgement—not a tiny footnote. It states: crypto markets are volatile; data may be delayed or unavailable; AURUM provides analysis, not financial advice; AI content may be wrong/incomplete; users make their own decisions.
- Guest access is visible only if the approved entitlement policy permits it. It must explain what will not sync without an account.

### 6.2 Overview — Market Pulse

**Purpose:** a calm briefing that takes less than a minute to scan.

**Vertical composition:**

1. Root app bar: AURUM wordmark, notification action, account/avatar.
2. Contextual greeting (`Good morning, Amina` or `Welcome to AURUM` for guest), date/time-zone-aware but not overly prominent.
3. **Market Overview** hero: total-market directional summary and market sentiment, source/methodology label, `as of` time. Sentiment shows a numeric score and label such as `64 · Greed`; it is not a forecast.
4. A compact market/featured chart strip, not a second full asset-detail chart.
5. **Featured assets**: 3 concise `CryptoCard`/rows selected by an explicit server-provided category; each opens Asset Detail.
6. **Trending assets**: limited 3–5 rows, named category/sort basis (`24h volume leaders`, not vague “hot” labels).
7. **Your watchlist** preview: maximum 3 rows and a clear `Manage` path. Empty version uses a compact callout with `Explore Markets`.
8. **AI Market Insight**: only an approved, timestamped concise summary with evidence count and risk qualifier. It routes to AI Desk.
9. **Signal pulse**: one/two recently updated analysis signals, no rapid price animation; `View all signals` routes to Signals.
10. **Quick actions**: Explore Markets, Watchlist, AI Desk, Signals. Use equal-width low-emphasis buttons/tiles; no trade-like action.

**Behavior:** pull-to-refresh updates independently loadable sections with a unified timestamp status. A partial failure leaves other valid sections intact and places an inline retry in the failed block. Do not require all providers to succeed to render the dashboard.

### 6.3 Markets and search

**Markets**

- App bar presents `Markets`, search action and filter/sort action. The title has no decorative subtitle.
- Search route becomes full focus on phones; input is immediately keyboard-focused only after user action, not on tab arrival.
- Category chips use provider-supported classification only. Initial set: `Top`, `Gainers`, `Losers`, `Volume`; each label describes its calculation period in the filter summary.
- The filter row is horizontally scrollable only after the primary selected state and filter button remain accessible. Active filters are announced and visible as a concise summary.
- Market list rows show asset/rank, price, `24h` signed movement, 24h volume and market cap on either a second line or detail mode. A narrow phone never squeezes all values into unreadable columns: price and change remain primary; volume/cap move under or into a configurable detail line.
- Infinite/cursor pagination shows a predictable lower loading row and honors rate limits. No false “all markets” claim when a source page is incomplete.

**Search states:** recent searches (stored locally and removable), active query results, no matches, offline cache matches, error with Retry. Search is debounced 250–350 ms; a new query cancels an old remote request.

### 6.4 Asset Detail and chart workspace

**Asset Detail composition:**

1. Detail app bar: Back, asset name/symbol, independent watch action, optional share only when deep links are designed.
2. `AssetHeader`: current price, selected-period signed movement, source/as-of line, market status if meaningful.
3. Main chart pane: visible plot, data-derived scale, crosshair, selected timeframe and no hidden axes.
4. `ChartControls`: timeframes `1H`, `4H`, `1D`, `1W`, `1M`, `1Y`; candle/line setting if supported; indicators; expand action.
5. Technical snapshot: selected RSI/MACD/EMA values with definition route. Do not call a technical indicator a recommendation.
6. Market statistics: market cap, volume, circulating supply, 24h high/low, all-time values where source supports them. Values carry source/freshness.
7. Related AI analysis preview, then relevant signal preview, both timestamped.
8. Risk/data information card explaining volatility or missing data context as applicable.

**Chart principles:** detailed separately in Section 7. The detail page chart has a protected minimum plot height of 260 dp (excluding controls); on small screens, metadata flows below rather than shrinking the chart to an unreadable strip.

### 6.5 AI Desk and analysis result

**AI Desk must feel like an analytical briefing workspace, not a chatbot.**

- Header introduces the currently selected market context and last known market-data time.
- `New analysis` is a grounded request composer: asset / overall market selector; a small set of approved analytical lenses (trend, momentum, volatility, risk factors); contextual input only if enabled by policy. It states the data scope before submit.
- Generation state shows the requested scope and staged skeleton sections such as “Reviewing market context” and “Preparing risk factors.” It never streams speculative text that disappears or appears as fact before server validation.
- Result surface is ordered: **Market Summary → Technical View → AI Interpretation → Potential Scenarios → Risk Factors → Provenance**.
- Assessment can be `Bullish context`, `Neutral context`, `Bearish context`, or `Mixed`. Confidence is explicitly labelled **model confidence / uncertainty, not a prediction** and is never alone.
- Potential scenarios are conditional: “If price holds above … and volume confirms …” not promises. Counterpoint/risk is required even for a bullish-context output.
- Every analysis has generated time, market-data as-of time, source list/summary, analysis/model version and feedback mechanism. It is immutable after generation; a refresh creates a new version/history item.

### 6.6 Signals and signal details

**Signals list**

- Starts with Active and History segmented tabs. Filters support asset, direction/context, risk, strength and status only where those properties are truly available.
- A card’s reading order is: asset/pair → direction/context and status → current/analysis price snapshot → strength/risk → evidence preview → issued/updated time.
- Direction vocabulary is product-controlled: `Long context`, `Short context`, `Watch`, or `Neutral`—never an imperative `Buy now`/`Sell now` action. If product/legal chooses a different vocabulary, it must undergo the same review.
- Signal strength is a labeled scale (`Developing`, `Moderate`, `Strong`) with definition; it is not a probability and is not rendered as a giant red/green meter.

**Signal Detail**

- Shows a status timeline (issued, updated, invalidated/closed if applicable) with exact UTC/localized display policy.
- Shows evidence/indicator values, data and analysis timestamp, and methodology/source link.
- Entry-zone/invalidation fields are only present if the approved signal contract supports them; they are labelled analytical levels, not execution instructions.
- Required risk block: uncertainty, volatility, limitations, and “Analysis only — not financial advice.”

### 6.7 Watchlist, notifications and profile

**Watchlist**

- Local-first list of saved asset IDs with price/movement and optional alert indicator. Account sync is a convenience, not a reason to block list usability.
- Rows open Asset Detail; a top action routes to Search/Markets to add assets. Remove has immediate visible undo only if data consistency supports it; otherwise uses clear confirmation.
- Empty state: “Your watchlist is empty. Add an asset from Markets.” → `Explore markets`.

**Notifications**

- Four types: Signal alerts, Price alerts, Market updates, System notifications.
- Each group/item shows human-readable time, unread state and destination. Notification copy is informational; it cannot declare a guaranteed market outcome.
- OS permission is requested only after the user enables a concrete alert category or otherwise encounters value; never as the first splash prompt.

**Profile & Settings**

- Profile list order: Account → Preferences → Notifications → Security → Appearance → Privacy & Data → About & Support → Sign out.
- Guest screen promotes optional sign-in by explaining sync/history/alerts benefit, without blocking market exploration.
- Security and deletion operations require re-authentication where backend policy requires it. Sign out is separated from destructive delete-account flow.

---

## 7. Premium chart experience specification

Charts are a primary comprehension tool, not decoration. The first implementation must prove legibility/performance on a physical Android phone before expanding advanced drawing features.

### 7.1 Supported chart modes and data contract

| Capability | Phase 3 requirement | Notes |
| --- | --- | --- |
| Timeframes | `1H`, `4H`, `1D`, `1W`, `1M`, `1Y` | Each maps to a backend-defined candle interval/range; changing timeframe clearly changes the period label. |
| Price modes | Candlestick primary; line fallback/alternate | Candle data requires validated OHLC values. Fall back to line/no-data, never draw false candles. |
| Volume | Optional lower histogram pane | Toggle if provider has valid volume; it shares time viewport but not price scale. |
| Technical overlays | Initial RSI, MACD, EMA | Parameters/version are explicit; indicator calculation is server-defined or identically versioned. |
| Context levels | Support/resistance only if backend provides methodology/source | Render as labeled subdued horizontal zones, not exact promises. |
| Crosshair & tooltip | Long press/drag crosshair; selected candle date/OHLC/volume | Tooltip avoids fingers and does not fall below the navigation/safe area. |
| Zoom & pan | Pinch/drag in expanded chart, constrained viewport, Reset | Detail chart can prioritize timeframe selection over complex gestures; no gesture conflict with page scroll. |

### 7.2 Chart layout and visual rules

```text
Asset header / freshness
Timeframe control: 1H  4H  1D  1W  1M  1Y
┌────────────────────────────────────────────┐
│ price chart / candles or line              │
│  subtle horizontal grid · y-axis labels    │
│  crosshair / data tooltip when active      │
├────────────────────────────────────────────┤
│ volume histogram (if available)            │
└────────────────────────────────────────────┘
Indicators: RSI / MACD / EMA  ·  Expand
```

- Canvas: `aurumInk`; grid: `aurumBorder` at low contrast; axes: `aurumTextTertiary`; current price marker uses a text label and semantic direction, not only a colored line.
- Candles: up `aurumPositive`, down `aurumNegative`, neutral/unknown `aurumTextSecondary`; wicks remain visible at the chosen contrast.
- The series has an accessible summary (“BTC, 1 day, last 68,420.50 USD, up 3.42 percent, data as of …”). The user can access a table/text summary when a screen reader or reduced-data setting requires it.
- Skeleton preserves chart bounds and uses nonnumeric blocks/grid. No fake candles or animated prices during loading.
- No data state explains whether history is unavailable for the selected period and offers another timeframe or Retry.
- Chart data is decimated/aggregated to the viewport. A 1Y view does not build a widget for every raw tick.

### 7.3 Gesture, semantics and performance safeguards

- One-finger vertical scroll remains predictable outside the plot. A long press begins crosshair; pinch zoom is enabled only in expanded mode after physical-device testing.
- Crosshair haptic feedback is off by default; optional subtle haptic occurs only on entering a candle, never for every move.
- Requests cancel when a user changes asset/timeframe; latest response wins through request identity.
- Parse/aggregate large candle sets off the UI thread if profiling identifies dropped frames. Repaint boundaries isolate the chart from unrelated quote updates.
- A chart implementation is accepted only after screen-reader labels, 320 dp width, 1.5 text scale controls, 60 Hz scroll/gesture checks and poor-network states pass on a physical phone.

---

## 8. AI and signal content safety blueprint

### 8.1 AI output schema (product presentation contract)

The backend returns a validated structured result; Flutter does not render raw model HTML/Markdown as trusted UI.

```text
AnalysisBrief
├─ id, status, generatedAt, expiresAt
├─ scope (market or canonical asset ID), question/lens
├─ marketDataAsOf, sourceSummary, methodologyVersion, modelVersion
├─ assessment (bullish_context | neutral | bearish_context | mixed)
├─ confidence (0–100) + label: "model confidence / uncertainty, not a prediction"
├─ marketSummary
├─ technicalView (trend, momentum, volume, volatility)
├─ keyObservations[]
├─ scenarios[] (conditional bullish / neutral / bearish)
├─ counterpointAndRiskFactors[]
└─ disclosure
```

Client rules:

- Required fields missing or invalid → present an unavailable/partial result state; never silently make up a section.
- A confidence value is formatted with uncertainty language and supporting context. `72%` cannot appear as a standalone guarantee badge.
- Conditional scenarios require a condition, possible outcome and invalidating/counterpoint factor where applicable.
- Free-text user input is length-limited, sanitized, disclosed and passed only over authenticated HTTPS to the backend; prompt content is not copied into analytics logs.
- “Not financial advice” stays visually present but never substitutes for genuine evidence/risk explanation.

### 8.2 Signal presentation contract

```text
AnalysisSignal
├─ id, canonical asset/pair, status, issuedAt, updatedAt
├─ direction/context, strength, riskLevel, horizon
├─ marketPriceSnapshot + asOf
├─ thesis
├─ supportingIndicators[] / evidence[]
├─ analytical entry zone and invalidation (only if sanctioned)
├─ methodology/source version
└─ disclosure
```

- Status is explicit: `Active`, `Watching`, `Updated`, `Invalidated`, `Completed`, `Archived`. “Completed” describes lifecycle, not investment performance.
- Direction is not colored without text. Risk always has text (`Low`, `Moderate`, `Elevated`) and a definition sheet.
- “Historical” is never positioned as proof of future quality. It includes data/methodology provenance and does not show promotional win-rate claims.

---

## 9. Loading, empty, error and offline specification

### 9.1 Loading states

| Surface | Loading treatment | Must not do |
| --- | --- | --- |
| Splash | Real initialization state and concise accessibility status | Artificial fixed delay. |
| Overview | Header/hero/list skeletons matching final vertical geometry; independent section loading | Blank screen or all-or-nothing wait. |
| Market list | 6–8 row skeleton with stable rank/logo/price geometry; footer pagination row | Placeholder prices that could be read as real data. |
| Asset detail | Asset header placeholder + protected chart skeleton + stat grid skeleton | Collapse chart height then jump. |
| Chart range change | Existing chart dimmed/marked refreshing; compact in-plot progress | Remove valid prior data without a label. |
| AI generation | Structured skeleton sections and requested scope; cancellable where API supports it | Simulated analysis text, blinking terminal effect, or false incremental conclusions. |
| Signals | Signal-card skeleton matching risk/evidence layout | Green/red generic blocks with no labels. |

Skeleton shimmer is subtle (1.2–1.6 s), limited to content placeholders, and replaced by a static low-motion state when reduced motion is enabled.

### 9.2 Empty states

| Context | Title | Supporting text | Action |
| --- | --- | --- | --- |
| Watchlist | Your watchlist is empty | Add an asset to keep its market context close. | Explore Markets |
| Markets search | No assets found | Try a full name, ticker, or clear a filter. | Clear filters |
| Active signals | No active signals right now | New analytical signals will appear here when available. | View history / Refresh |
| AI history | No saved analyses yet | Choose a market context to create an evidence-led brief. | New analysis |
| Notifications | You’re all caught up | New signal, price and system updates will appear here. | Back |

### 9.3 Error and stale-data copy

| Condition | Title | Description | Action |
| --- | --- | --- | --- |
| Network unavailable | Unable to load market data | Check your connection and try again. Cached data may still be shown with its last update time. | Retry |
| Provider/API unavailable | Market data is temporarily unavailable | The data source did not respond. Your saved view remains available where possible. | Refresh |
| Rate limited | Updates are temporarily paused | We’re waiting before requesting more market data. | Try again later |
| AI unavailable | AI analysis is temporarily unavailable | Market data remains available. Please try again shortly. | Retry / View market context |
| Unauthorized | Your session has ended | Sign in again to continue with account features. | Sign in |
| Asset unavailable | This asset is not currently available | It may have been removed or is unsupported by the selected source. | Back to Markets |

All recoverable errors show an action. Errors caused by an invalid user form input appear at the field and in a concise summary; errors are not a generic `Something went wrong` unless no safe detail exists. Cached/stale data is visually labelled with **Last updated** and not removed merely because refresh failed.

---

## 10. Responsive and accessibility plan

### 10.1 Mobile layout strategy

AURUM is portrait-first and uses constraints, flexible layouts and scrollable content—not hard-coded screen dimensions.

| Test class | Logical width reference | Design response |
| --- | ---:| --- |
| Small Android | 320–359 dp | 16 dp page inset when needed; price/change retain priority; secondary table values move below; bottom labels remain visible. |
| Standard Android | 360–399 dp | 20 dp page inset; normal two-column statistic grid; full primary bottom-nav labels. |
| Large Android | 400–480 dp | Preserve readable max content rhythm rather than scaling every type; cards can use wider charts/columns. |
| Tall aspect ratio | 20:9+ | Do not fill space with oversized cards; dashboard scroll remains content-led. |
| Keyboard open | Any | Route/search/form scrolls to focused field; bottom controls rise above `viewInsets`; submit action remains reachable. |

Rules:

- `SafeArea` is applied deliberately to app bars, shell dock and bottom sheets; scroll content gets enough bottom padding to avoid the navigation dock.
- `LayoutBuilder` or adaptive child composition selects row vs stacked metadata, not device-name checks.
- Long asset names and locales are tested. Name may wrap to two lines; price/critical movement retains a stable leading/trailing column or moves below—never overlaps.
- Charts occupy available width, preserve plot height and move controls/statistics to the next line before sacrificing readability.
- Landscape is not a core use case at launch; if the host permits rotation, expanded chart is the only enhanced landscape experience. All other screens remain safe and scrollable rather than presenting a broken desktop layout.

### 10.2 Accessibility requirements

- Essential text meets contrast target; status has text, icon/arrow and color.
- All independent actions meet 48 dp targets, have semantic labels and expose selected/disabled/busy states.
- Screen-reader order follows visual/decision order: title → key price → freshness → chart summary → controls → supporting context.
- Charts offer an accessible textual summary and crosshair data in semantic form. Gestures always have an alternative action/control.
- Font scale tests at 1.0x, 1.3x and 1.5x; OS bold text/high contrast and Android TalkBack smoke tests are required.
- Reduced motion disables shimmer, nonessential card entrance transitions and chart morphing; it retains instant feedback and state change labels.
- Never rely on a tiny gold outline alone for selected tabs/chips; use text weight/state and semantic selected flag.

---

## 11. Motion and animation system

AURUM uses motion to preserve context and confirm user intent, never to dramatize price movement.

| Interaction | Motion | Duration / curve | Guardrails |
| --- | --- | --- | --- |
| Splash initialization | Wordmark fade + restrained orbit/line | 600–900 ms, ease-out | Only while actual startup progresses; reduced motion fades once. |
| Root page/tab change | Content fade/short translate (4–8 dp) | 180–220 ms, standard ease-out | Keep tab stack; no large sliding panes. |
| Pushed detail | Shared visual origin only when it clarifies selected asset; otherwise standard material-safe fade/slide | 220–260 ms | Avoid expensive chart hero animation. |
| Card press | Surface tone + 1–2 dp scale | 100–140 ms | No bouncy animation; respects reduced motion. |
| Skeleton | Low-contrast shimmer | 1.2–1.6 s | Static placeholder in reduced motion. |
| Price update | Text crossfade/brief highlight, then settle | 160–200 ms | No rolling slot-machine values, pulsing green/red or sound. |
| Chart timeframe | Fade old series/overlay loading then render new data | 180–250 ms | Do not interpolate unrelated time ranges as a predictive animation. |
| Bottom navigation | Active indicator/label emphasis | 180 ms | Labels stay fixed; no shifting icon positions that cause missed taps. |
| AI generation | Section skeleton reveal as validated sections are ready | 180–240 ms | No typing effect that implies unreviewed live model output. |
| Signal update | Small status dot/text crossfade + optional haptic on user refresh | 160–200 ms | Not a flashing alert; accessibility announcement uses concise change. |
| Pull-to-refresh | Minimal gold/neutral progress arc | platform-appropriate | Completion is shown only after data result resolves. |

All animation values are centralized as `AurumMotion` tokens. Controllers do not trigger repeated animation for background quote ticks. The default system behavior is calm and stable.

---

## 12. Final Flutter folder architecture

The Phase 1 structure is refined below. It keeps features independent, makes presentation/test ownership clear, and avoids a generic `shared/models` dumping ground.

```text
.
├── .vscode/
│   ├── extensions.json
│   ├── launch.json
│   └── settings.json
├── android/                              # Flutter-generated Android host/configuration
├── assets/
│   ├── design/                            # Approved reference concepts, not runtime screenshots
│   ├── fonts/                             # Licensed Manrope / IBM Plex Mono files
│   ├── icons/
│   └── images/
├── docs/
│   ├── decisions/                         # Short architecture decision records
│   ├── api-contracts/
│   ├── PHASE_1_AURUM_FOUNDATION.md
│   └── PHASE_2_AURUM_UI_UX_BLUEPRINT.md
├── integration_test/
│   ├── flows/
│   └── support/
├── lib/
│   ├── main.dart                          # Calls bootstrap only
│   ├── bootstrap.dart                     # Guarded initialization and provider overrides
│   ├── app/
│   │   ├── app.dart                       # MaterialApp.router composition
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   ├── route_guards.dart
│   │   │   └── route_names.dart
│   │   ├── theme/
│   │   │   ├── aurum_theme.dart
│   │   │   ├── aurum_colors.dart
│   │   │   ├── aurum_text_styles.dart
│   │   │   ├── aurum_spacing.dart
│   │   │   └── aurum_motion.dart
│   │   └── l10n/
│   ├── core/
│   │   ├── config/                        # Validated non-secret AppConfig/environment
│   │   ├── constants/
│   │   ├── errors/                        # Failure taxonomy and error mapper
│   │   ├── network/                       # Dio setup, auth, retry/rate interceptors
│   │   ├── persistence/                   # Cache database interfaces/adapters
│   │   ├── security/                      # Secure session/token abstractions
│   │   ├── services/                      # Clock, connectivity, logging, analytics abstractions
│   │   ├── utils/
│   │   └── widgets/                       # Only app-wide technical helpers
│   ├── design_system/
│   │   ├── components/                    # AurumButton/Card/AppBar/etc.
│   │   ├── charts/                        # Chart adapter & accessible chart shell
│   │   ├── feedback/                      # Skeleton/empty/error/offline surfaces
│   │   └── foundation/                    # Component variants/tokens/extensions
│   └── features/
│       ├── bootstrap/
│       ├── onboarding/
│       ├── auth/
│       ├── home/
│       ├── markets/
│       ├── asset_detail/
│       ├── watchlist/
│       ├── signals/
│       ├── ai_analysis/
│       ├── notifications/
│       └── profile/
│           └── [each feature]/
│               ├── data/
│               │   ├── datasources/
│               │   ├── dto/
│               │   ├── mappers/
│               │   └── repositories/
│               ├── domain/
│               │   ├── entities/
│               │   ├── repositories/
│               │   └── usecases/
│               └── presentation/
│                   ├── controllers/
│                   ├── screens/
│                   ├── state/
│                   └── widgets/
├── test/
│   ├── app/
│   ├── core/
│   ├── design_system/
│   ├── features/
│   ├── golden/
│   └── support/
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

### Folder rules

- `main.dart` has no feature logic, configuration literals, or service wiring beyond calling `bootstrap`.
- A feature widget never imports another feature’s `data/` implementation. Cross-feature navigation passes stable IDs/query objects, not DTOs.
- Entities and repository contracts reside in their owning feature’s `domain/`. Promote an entity to `core` only if it is truly cross-feature and semantically stable.
- `design_system` may import `app/theme` foundations but never a feature. Feature UI may import design-system components.
- DTOs stay inside `data/`, are mapped at repository boundaries, and never reach presentation widgets.
- Tests mirror ownership. Golden references use approved device widths and synthetic non-sensitive fixtures.

---

## 13. State-management architecture — Riverpod only

### 13.1 Why Riverpod

Riverpod is selected because it supports typed dependency graphs, explicit asynchronous state, provider overrides for test/fake API clients, feature-scoped controllers, cancellation/disposal, and small rebuild surfaces. It works naturally with a layered architecture and can be debugged in VS Code without a global mutable store.

**Not used:** BLoC/Cubit, Provider as a separate application framework, Redux, GetX state, MobX, singleton service-locator state or `setState` for remote/business state. Local ephemeral widget state (text-field focus, one animation controller, an expansion toggle) remains local when it is not shared, persisted or test-worthy as feature state.

### 13.2 Provider ownership

| Scope | Riverpod role | Examples |
| --- | --- | --- |
| App/global | Long-lived app-scoped providers, narrowly watched | `appConfigProvider`, `sessionProvider`, `connectivityProvider`, `appThemePreferencesProvider`, `routerRefreshProvider`. |
| Core infrastructure | `Provider` for immutable services/interfaces | `dioProvider`, secure-store provider, logger, clock, cache database, backend client. |
| Repository | `Provider` mapping contracts to implementations | `marketRepositoryProvider`, `watchlistRepositoryProvider`, `aiAnalysisRepositoryProvider`. |
| Feature collection | `AsyncNotifier`/generated provider with immutable query state | Markets page query/pagination; signal list/filter; notification inbox. |
| Feature detail | `.family` async provider keyed by canonical stable ID/timeframe | Asset detail, candles, indicator snapshot, signal detail, analysis detail. |
| Mutation | Controller/notifier with explicit command state | Watch toggle, sign-in, alert changes, AI analysis submit, sign-out. |
| UI-only | Widget state or small auto-dispose provider | Search field focus, currently expanded card, transient selection. |

### 13.3 State model and widget reaction

- Standard remote view state uses Riverpod `AsyncValue<T>` or a feature-specific immutable state that contains `data`, `isRefreshing`, `isPaginating`, `lastUpdated`, `isStale`, query and typed error metadata. The chosen shape is consistent per feature; it is not an uncontrolled mix.
- `loading`: show matching skeleton only in the missing content area.
- `data`: render domain view models; source/freshness and offline badge are part of view state.
- `refreshing`: preserve existing content and show inline/pull progress.
- `empty`: show a task-specific `AurumEmptyState`.
- `error`: render `AurumErrorState`, preserving safe data where possible.
- Widgets use `ref.watch` only for the smallest state slice they render. Action handlers use `ref.read(controller.notifier)`. List/chart subtrees use selection/family providers to prevent an unrelated quote or app setting from rebuilding a full screen.
- Controller methods call use cases; they do not construct DTOs, write HTTP requests or read UI context to show dialogs. The screen maps state/events to UI feedback.

### 13.4 Cache and invalidation policy

```text
UI intent
  → Riverpod controller (deduplicates/cancels active request)
  → use case
  → repository
      → fresh local record? return cache + freshness metadata
      → remote request when stale/forced
      → validate/map/persist normalized data
  → controller updates immutable state
  → only subscribed widgets rebuild
```

- Cache keys are canonical and scoped: asset ID + timeframe + range, market query, user ID + watchlist version, analysis ID.
- Repository TTL policy is centralized, visible in tests and driven by data class—not embedded in a widget. Suggested initial policy: overview 60 s; visible quote 15–30 s/push update; market list 60 s; asset metadata 24 h; chart range 5–15 min with final-candle update; indicators 5 min; AI result immutable by ID; signals 30–60 s. Final values depend on provider licence/cost and backend SLA.
- Optimistic watchlist changes update a local entity immediately, queue safe idempotent sync when authenticated, and reconcile server version/conflicts predictably. Failed mutation gets a visible retry/undo policy.
- Session logout invalidates account-scoped providers and secure cache records; public market cache may remain subject to privacy/data policy.

---

## 14. API and data architecture

### 14.1 Mandatory flow

```text
Flutter widget
   ↓ user intent / render state
Riverpod controller
   ↓
Use case (domain policy)
   ↓
Repository contract
   ↓
Repository implementation
   ├── local cache / secure store
   └── remote data source
         ↓
      Dio API client / authenticated WebSocket adapter
         ↓
      AURUM backend
         ↓
      licensed market / AI / notification providers
```

A widget does not import `Dio`, a backend DTO, an API key, a JSON parser, or a provider URL. A provider-specific network response ends at the data mapper and becomes a stable domain entity before presentation sees it.

### 14.2 Client and backend responsibilities

| Concern | Flutter client | AURUM backend |
| --- | --- | --- |
| Market data | Requests normalized contract, displays freshness, caches bounded UI data | Provider credentials, licensing rules, canonical IDs/symbol mapping, aggregation, cache/rate policy. |
| Historical charts | Requests canonical asset/timeframe/range; decimates/renders supplied series | Validates OHLCV, interval mapping, source consistency and range limits. |
| Technical indicators | Renders labeled/versioned values | Defines/calculates algorithm/parameters or guarantees version alignment. |
| AI analysis | Sends permitted scoped request; renders validated schema | Model credential, prompt/data orchestration, tool grounding, output schema/safety validation, retention policy. |
| Signals | Displays structured signal and disclaimer | Signal generation/review, methodology, status lifecycle, entitlement, audit log. |
| Authentication | Starts approved OAuth/OIDC/identity flow, stores issued session securely | Identity validation, token issuance/revocation, rate limiting and account policies. |
| Notifications | Registers revocable device token with consent; displays inbox | Publishes notification, authorization and deep-link payload policy. |

### 14.3 API client standards

- A single configured `Dio` client per environment with base URL from validated non-secret `AppConfig`.
- Interceptors: request ID/correlation, locale/app version, authorization attachment, token-refresh single-flight, safe retry/backoff for idempotent reads, structured response/error mapping and release-safe logging.
- Timeouts are explicit: connection, send, receive and overall request policy. Requests are cancellable; late responses cannot overwrite a newer query.
- API responses use versioned paths, UTC ISO-8601 timestamps, canonical IDs, cursor pagination, explicit nullability, `asOf` time and request/correlation ID. Avoid locale-formatted numbers in API payloads.
- Domain failures are typed: `NetworkFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `ForbiddenFailure`, `ValidationFailure`, `RateLimitFailure`, `ServiceUnavailableFailure`, `MaintenanceFailure`, `DataIntegrityFailure`, `UnknownFailure`.
- WebSocket, if enabled after a provider/cost spike, is a repository data source—not a widget stream. Subscribe only to visible/watchlisted canonical assets, coalesce ticks, pause in the background, reconnect with bounded backoff, and fall back to REST state.

### 14.4 Initial endpoint contract families

```text
GET  /v1/market-pulse
GET  /v1/markets?category=&sort=&cursor=&limit=
GET  /v1/assets/search?q=
GET  /v1/assets/{assetId}
GET  /v1/assets/{assetId}/candles?timeframe=&from=&to=
GET  /v1/assets/{assetId}/indicators?set=overview
GET  /v1/signals?status=&assetId=&risk=&cursor=
GET  /v1/signals/{signalId}
POST /v1/ai/analyses
GET  /v1/ai/analyses/{analysisId}
GET  /v1/me/analyses?cursor=
GET  /v1/me/watchlist
PUT  /v1/me/watchlist
GET  /v1/me/notifications?cursor=
PUT  /v1/me/notifications/{id}/read
GET  /v1/me/preferences
PUT  /v1/me/preferences
POST /v1/devices/push-token
DELETE /v1/devices/push-token/{id}
```

Auth endpoints/redirects are decided by the approved identity provider rather than hard-coded into this list. Any endpoint that returns account data requires authorization and server-side ownership checks; the mobile client never determines entitlement itself.

### 14.5 Data quality rules

- Normalize all market timestamps to UTC in domain data; display local time with an unambiguous date/time format and accessibly expose source time zone where required.
- A quote/candle/indicator must report `asOf`. If the source does not provide it, backend marks source receipt time distinctly rather than pretending exchange time.
- Validate numeric values (finite, reasonable precision, OHLC consistency: low ≤ open/close ≤ high). Bad values map to a data-integrity failure/partial state, not a malformed chart.
- Asset ID is canonical; display symbols cannot key persistence or routes because symbols collide/change.
- Use bounded cursor pagination and server-defined maximum page/range sizes. Do not download all assets/candles to the phone.

---

## 15. Security, privacy and session plan

### 15.1 Authentication and tokens

1. Use a vetted OAuth/OIDC provider or equivalent AURUM backend identity service with Authorization Code + PKCE for mobile. Do not build an unreviewed password/token protocol in Flutter.
2. Access tokens are short lived. Refresh is server-controlled/rotated and performed centrally once for concurrent requests. Failed refresh clears session atomically.
3. Store tokens and any refresh/session secret only with `flutter_secure_storage`, using OS-backed Android protection. Never store secrets in `SharedPreferences`, local cache tables, route arguments, analytics, crash logs or widget state.
4. Session gate checks bootstrap state; it never flashes a protected screen before authorization resolves. Unauthorized responses route to re-authentication and then a safe intended destination where permitted.
5. Sign out revokes server session when available, removes secure local tokens, invalidates user-scoped Riverpod providers and clears user-scoped persistent cache. Account deletion is separate, reauthenticated and server-led.

### 15.2 Secrets, environments and transport

- `--dart-define` / `--dart-define-from-file` carries validated **non-secret** values only: environment label, AURUM API base URL, public telemetry toggles and public client IDs when unavoidable. Real values are supplied by developer/secured CI and ignored by Git.
- Market-data API keys, AI model keys, push server credentials, database credentials, private signing material and privileged configuration remain on backend/secret infrastructure. They never appear in Flutter source, assets, APK or commits.
- HTTPS with modern TLS and hostname validation is mandatory. Consider certificate pinning only after a documented backup/rotation strategy and a mobile reliability review; pinning is not a substitute for TLS/auth.
- Release logging redacts Authorization, cookies, tokens, device identifiers, email, raw prompts, user profile and full response payloads. Crash/telemetry provider is wrapped behind a scrubber/consent-aware interface.
- Android release signing uses protected CI/local secret handling; debug keys never sign a distribution build. R8/minification, mapping-file upload and reproducible build checks are verified before release.

### 15.3 Input, privacy and financial-safety controls

- Client-side validation makes forms usable; backend validation/authorization is authoritative. Use maximum lengths, Unicode-safe input handling and schema validation.
- Treat all server/provider/AI text as untrusted data. Render structured text only; do not render arbitrary HTML, execute links silently or trust model-generated instructions.
- Collect the minimum data necessary. Explain analytics/AI retention and offer applicable consent controls. Do not log market queries tied to identity unnecessarily.
- AI prompts/history and notification tokens have explicit retention/deletion policies. The client confirms account deletion request/complete status from the backend; it does not claim local delete erased remote data until confirmed.
- Every AI/signal detail includes data time, limitation/risk information and analysis-only language. Automated assertions/test fixtures reject banned certainty claims such as “guaranteed profit” or “100% accurate.”

---

## 16. Physical Android and VS Code testing blueprint

### 16.1 Developer workflow

```text
1. Install Flutter stable, Android SDK platform tools and VS Code Dart/Flutter extensions.
2. Enable Developer options on the Android phone.
3. Enable USB debugging; accept the computer’s RSA fingerprint on the phone.
4. Connect USB and run: adb devices
5. From the repository run: flutter doctor -v
6. Confirm the phone: flutter devices
7. In VS Code: Flutter: Select Device → choose the physical phone → press F5.
8. Use hot reload (r) for UI changes and hot restart when provider/bootstrap state changes.
9. Exercise real touch, keyboard, TalkBack, network and performance flows on the phone.
10. Validate distributable behavior: flutter run --release -d <device-id>
11. Produce an Android artifact when ready: flutter build apk --release
```

The project must bind only to on-device capabilities and relative/backend URLs appropriate to a physical device. Browser-style `localhost` assumptions are not permitted for customer networking. An emulator may be used as an additional form-factor test but is never required for normal coding/debugging.

### 16.2 Device validation matrix

| Area | Required physical/device check |
| --- | --- |
| Layout | 320–359, 360–399 and 400+ dp widths; tall aspect ratio; safe insets. |
| Text | 1.0x, 1.3x and 1.5x system text; Android bold text if available. |
| Touch | Bottom nav, app-bar actions, chart controls, long-press crosshair and keyboard dismissal. |
| Network | Healthy Wi-Fi/mobile data, flight mode/offline cache, slow/high latency, reconnect and rate limit response. |
| Lifecycle | Cold start, warm resume, background/foreground while chart/refresh is active, session expiration. |
| Accessibility | TalkBack order/labels, focus indication, color-independent gain/loss and reduced motion. |
| Performance | Market scroll, tab switch, asset/detail/chart range change, repeated navigation, memory after a long session. |
| Release | `--release` install/start, no sensitive debug logs, correct app id/name/icon, signing/ProGuard mapping path. |

---

## 17. Quality gates before Phase 3 completion

| Gate | Acceptance condition |
| --- | --- |
| Architecture | Screens call controllers/use cases/repositories only; no UI-to-HTTP, no DTO leakage and no hard-coded secret. |
| Design system | Required primitives are created and used; no duplicate card/button/error implementations; design tokens are applied. |
| Navigation | Five shell destinations retain state; deep links/session gate/back behavior are integration-tested. |
| Data states | Every primary/secondary data surface demonstrates loading, data, empty, error and stale/offline rendering. |
| Chart | All six timeframes, loading/no-data, narrow width, crosshair summary and performance profile pass physical-device acceptance. |
| AI/signals | Structured schema, timestamps, evidence, risk/counterpoint, status and analysis-only disclosure are always present. |
| Accessibility | Contrast, target size, semantic labels, 1.5x text, TalkBack and reduced-motion paths pass targeted tests. |
| Security | Secure token flow, redacted logging, session-expiry routing, environment validation and no-secret scan pass review. |
| Device | VS Code F5/hot reload and release smoke test succeed on USB-connected physical Android phone. |
| Test automation | Format/analyzer, unit/repository tests, widget state tests, golden tests and critical integration flows are passing in CI. |

---

## 18. Refined premium visual concept

The finalized Phase 2 reference concept is stored at:

[`assets/design/aurum_phase_2_final_ui_blueprint.png`](../assets/design/aurum_phase_2_final_ui_blueprint.png)

It is a **static design reference**, not a claim that the Flutter app has already been implemented. It visualizes the locked Obsidian design system across all six required perspectives:

1. Overview / Market Pulse
2. Markets
3. Asset Detail
4. AURUM AI Desk
5. Signals
6. Profile & Settings

The image is deliberately aligned with the blueprint: restrained gold, graphite surfaces, readable tabular prices, source/freshness language, evidence-led AI, risk-aware signals, five labeled primary destinations and no trade-execution or guaranteed-performance language.

---

## 19. Phase 3 implementation plan — only after Phase 2 approval

### Stage 1 — Bootstrap and developer baseline

1. Create the stable Flutter project and Android host with the approved application identifiers.
2. Add `.gitignore`, analyzer/lint policy, VS Code launch tasks, non-secret environment example, CI debug build and physical-device README instructions.
3. Add licensed fonts, assets and the AURUM theme/foundation tokens.
4. Set up `bootstrap`, GoRouter route shell, Riverpod root, typed failures, safe logger and configuration validation.

### Stage 2 — Design system and navigation foundation

1. Implement and golden-test the primitive components, state surfaces, app bars, navigation dock, input controls and confirmation/sheet behavior.
2. Implement responsive app shell, route guards, Android back behavior, accessibility labels/focus and reduced-motion tokens.
3. Establish fixtures/fake repositories so the UI can be verified without private APIs.

### Stage 3 — Core market experience

1. Build Overview, Markets, Search/Filters, Watchlist and Asset Detail against domain contracts/fakes.
2. Implement chart adapter spike and approve it on a physical phone before committing to the final chart library/renderer.
3. Add data/loading/empty/error/stale states and widget/golden coverage at the approved widths.

### Stage 4 — Account, signals and AI experience

1. Implement onboarding, disclosure, auth/session gate and Profile preference/security routes behind reviewed identity contracts.
2. Build Signals list/detail with validated fixtures and risk-first language.
3. Build AI Desk request/result/history with structured response fixtures, safety presentation and no raw model rendering.
4. Add notification inbox/preferences and device-permission flow when backend push contract is ready.

### Stage 5 — Backend integration and hardening

1. Integrate approved AURUM backend endpoints through repositories, cache policy, authorization, error mapping and observability scrubber.
2. Validate rate limits, provider outage, offline cache, session expiry and data-integrity flows.
3. Profile real Android performance; optimize only measured bottlenecks (chart aggregation, list rebuilds, image/cache behavior).
4. Complete security/privacy review, accessibility/device matrix, release signing flow and APK smoke test.

### Approval checkpoint

Phase 3 starts only after approval of:

- [ ] Complete screen map and route/navigation model
- [ ] Five primary destinations and secondary Watchlist/Notifications decision
- [ ] AURUM Obsidian colors, typography, spacing, component and motion systems
- [ ] Chart gestures/data/indicator scope
- [ ] AI and signal structure, risk language and certainty constraints
- [ ] Final Flutter folder architecture and Riverpod-only state approach
- [ ] Backend/secret/security boundary and physical-device testing workflow
- [ ] Refined Phase 2 premium concept image

Once approved, Phase 3 begins with the Flutter bootstrap and design-system foundation—not randomly assembled screens or direct API calls from widgets.
