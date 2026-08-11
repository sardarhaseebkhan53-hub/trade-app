# AURUM — Phase 5 technical analysis and intelligence layer

## Status

The Phase 5 **source implementation** creates the analysis stack on top of the Phase 4 `MarketRepository`. It does not execute trades, place orders, generate profit guarantees, or send an AI-provider credential from the application.

The existing sandbox still cannot bootstrap Flutter/Dart, contact the market provider, or connect a USB Android device. Therefore the source is not represented as physically validated; see `PHASE_3_ENVIRONMENT_STATUS.md` and the validation section below.

## Implemented architecture

```text
Provider-neutral ChartSeries (price + volume)
  ↓
TechnicalAnalysisService (pure Dart)
  ↓
TechnicalSnapshot
  ↓
MarketAnalysisEngine (documented multi-factor rules)
  ↓
MarketAnalysis
  ↓                    ↓
SignalEngine           AIAnalysisService
  ↓                    ↓
SignalHistoryStore     structured AiMarketAnalysis
  ↓                    ↓
Riverpod providers → AURUM premium UI
```

No Flutter widget computes an indicator or parses a provider response. `AnalysisRepository` requests the existing normalized market/price data, runs the pure technical service, then supplies a typed `MarketAnalysis` to Riverpod/UI consumers.

## Technical calculations

`TechnicalAnalysisService` implements:

- SMA: 20, 50, 100 and 200 periods when enough observations exist
- EMA: 20 and 50 periods when enough observations exist
- Wilder RSI (14), including flat-market and insufficient-history handling
- MACD (12, 26, 9): MACD line, signal line, histogram and crossover context
- Volume: latest volume versus 20-observation average
- Volatility: recent price range and standard deviation of percentage returns
- Price structure: recent identified support/resistance, high/low and range position

New/short-history assets require at least 35 usable close observations before an assessment is considered sufficient. The UI receives **“Insufficient market data for reliable analysis.”** rather than a fabricated conclusion.

## Multi-factor scoring policy

`MarketAnalysisEngine` uses these configurable diagnostic weights:

| Factor | Weight | Evidence examples |
| --- | ---: | --- |
| Trend | 35 | Price versus EMA20/EMA50; EMA relationship |
| Momentum | 25 | RSI context and MACD histogram/crossover context |
| Volume | 15 | Current volume versus 20-point average |
| Volatility | 10 | Recent range and return deviation |
| Price structure | 15 | Position inside identified recent support/resistance range |

Each factor is deliberately constrained to a small negative/neutral/positive contribution. The resulting `0–100` value is labelled **Analytical strength**, not accuracy, win rate, or probability of profit. Bias thresholds are:

| Strength | Bias |
| ---: | --- |
| 75–100 | Strong bullish bias |
| 60–74 | Bullish bias |
| 41–59 | Neutral |
| 26–40 | Bearish bias |
| 0–25 | Strong bearish bias |

Volatility, conflicting evidence, RSI extremes, price-structure conditions and trend reversals are carried into risk/invalidation text rather than hidden behind the score.

## Explainable signals and lifecycle

`SignalEngine` turns an already-generated `MarketAnalysis` into a `SignalRecord` containing asset, timeframe, bias, analytical strength, price snapshot, reasons, conflicts, risks, invalidation conditions, data time, generated time, expiry time and analysis version.

`SignalHistoryStore` is an in-memory immutable-record boundary for Phase 5. It never overwrites a prior record: a material bias change creates an `invalidated` historical record and a new current record. Repeated analysis of exactly the same data timestamp does not duplicate history. Phase 6 must replace the store with authenticated durable persistence and notification preferences.

Signal statuses are `active`, `updated`, `invalidated` and `expired`. A record expiring or invalidating is presented explicitly; it is never silently removed.

`AnalysisNotificationEventFactory` also creates typed, delivery-independent events for signal creation/invalidation, significant watchlist movement and analysis updates. Phase 6 must apply user preferences, persistence, permissions and actual push/in-app delivery; Phase 5 does not send notifications or spam users.

## AI architecture and safety

### Current Phase 5 implementation

- `MockAIAnalysisService` creates an explicitly labelled **Local structured interpretation** from `MarketAnalysis`. It uses only supplied data and is deterministic/transparent for offline development and tests.
- `AiPromptBuilder` constructs a controlled future prompt that prohibits invented data, trading instructions, certainty claims and guaranteed-profit language.
- `RemoteAIAnalysisService` depends on `AurumAiBackendClient`, not a model-provider SDK. It validates required structured fields before UI rendering.
- `AiAnalysisCache` keys responses by asset, timeframe, market-data timestamp and analysis version; it deduplicates concurrent work and applies a 10-minute TTL.

### Production requirement

A production remote interpretation path is:

```text
Flutter → AURUM backend → approved AI provider
```

The backend owns model credentials, prompts, data grounding, rate policy, schema validation, audit/retention policy and safety filtering. No AI key, provider endpoint, raw token or model prompt secret is in the Flutter client.

## UI upgrades

- **Asset Detail:** real selected-timeframe technical chips, provider-chart analysis, multi-timeframe bias chips, structured AI preview, generated signal records, risks and source/timestamp language.
- **AI Desk:** asset and timeframe controls; bias, analytical strength, technical evidence, supporting/conflicting factors, scenarios, risks, invalidation and analysis/data timestamps.
- **Signals:** rule-based multi-factor records with asset, bias, timeframe, analytical strength, risk, status, generated/data time and history filtering.
- **Home:** real market data plus a structured AURUM intelligence card and current explainable signals. Legacy demo signal/AI cards were removed.

## Tests added

- `technical_analysis_service_test.dart`: SMA, EMA, RSI, MACD and insufficient volume/volatility/structure behavior
- `market_analysis_engine_test.dart`: sufficient multi-factor analysis and insufficient-history state
- `ai_analysis_service_test.dart`: local structured interpretation plus valid/invalid remote schema parsing
- `signal_engine_test.dart`: immutable historical records, invalidation and duplicate-data prevention

## Local/device validation required

Once the official Flutter/Android toolchain is available, run:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <physical-device-id> \
  --dart-define=AURUM_MARKET_DATA_MODE=remote \
  --dart-define=AURUM_MARKET_API_KEY=YOUR_DEVELOPMENT_DEMO_KEY
```

On the physical phone test sufficient and insufficient history, timeframes, stale/offline market data, technical calculation render, AI unavailable render, active/updated/invalidated/expired signals, TalkBack/text scale and Android back navigation. Do not mark Phase 5 device complete until these checks pass.
