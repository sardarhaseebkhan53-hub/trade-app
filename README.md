# AURUM

AURUM is a premium, mobile-first cryptocurrency **market-analysis and decision-support** application built with Flutter and Dart. It presents provider-normalized market context, technical analysis, structured intelligence, explainable signals, watchlists and notifications. It does **not** execute trades, custody assets, promise outcomes, or contain production market/AI credentials.

## Current phase

**Phase 5 — Technical analysis + structured market intelligence**

- Central AURUM Obsidian theme, responsive shell, Riverpod, and GoRouter
- Provider-neutral market data with explicit remote/mock configuration
- Pure-Dart SMA, EMA, RSI, MACD, volume, volatility, and price-structure analysis
- Documented multi-factor analytical strength and explainable signal lifecycle
- Structured local interpretation plus a backend-only remote AI abstraction
- No trade execution, custody, transaction, provider AI key, or guaranteed-outcome claim
- Phase specifications, provider decision, and validation notes: [`docs/`](docs/)

> The repository has a source-level Flutter/Android project. This remote workspace does not contain a functioning Flutter/Dart/Android toolchain or a USB-connected Android phone. See [`docs/PHASE_3_ENVIRONMENT_STATUS.md`](docs/PHASE_3_ENVIRONMENT_STATUS.md) for the exact verification status.

## Requirements for local physical-device development

- Flutter stable SDK
- Android SDK and accepted Android licences
- Java 17, as supported by the installed Flutter/Android toolchain
- VS Code with Dart and Flutter extensions
- Android phone with Developer options and USB debugging enabled

## Run on a physical Android phone

If this is a manual checkout rather than a project generated on the workstation, copy `android/local.properties.example` to `android/local.properties` and set the Android SDK and Flutter SDK paths first. The real file is intentionally ignored by Git.

```bash
flutter doctor -v
flutter doctor --android-licenses
adb devices
flutter devices
flutter pub get
flutter analyze
flutter test
flutter run -d <physical-device-id>
```

In VS Code, select the physical phone using **Flutter: Select Device**, then press **F5**. Use hot reload for UI changes and hot restart when bootstrap/provider state changes.

Release-device smoke test and APK creation:

```bash
# Copy android/key.properties.example to android/key.properties and use a protected release keystore first.
flutter run --release -d <physical-device-id>
flutter build apk --release
```

AURUM intentionally never falls back to the Android debug signing key for a release artifact. Keep `android/key.properties` and the keystore outside Git.

## Production-readiness status

The Phase 7 report currently concludes **NOT READY — FIX REQUIRED** because database migration, live API, Flutter analyzer/test, signed-release, and physical-Android validation are blocked in this sandbox. See [`docs/PHASE_7_PRODUCTION_READINESS_REPORT.md`](docs/PHASE_7_PRODUCTION_READINESS_REPORT.md) and [`docs/PHASE_7_MASTER_QA_CHECKLIST.md`](docs/PHASE_7_MASTER_QA_CHECKLIST.md).

## Non-secret configuration

`config/app_config.example.json` and `.env.example` document placeholders only; `.env.example` is not loaded at runtime. Runtime configuration is read from `--dart-define`:

```bash
flutter run \
  --dart-define=AURUM_MARKET_DATA_MODE=remote \
  --dart-define=AURUM_MARKET_PROVIDER=coingecko \
  --dart-define=AURUM_MARKET_API_BASE_URL=https://api.coingecko.com/api/v3 \
  --dart-define=AURUM_MARKET_API_KEY=YOUR_DEVELOPMENT_DEMO_KEY
```

Use explicit mock mode for offline UI work:

```bash
flutter run \
  --dart-define=AURUM_BACKEND_MODE=mock \
  --dart-define=AURUM_MARKET_DATA_MODE=mock
```

For the Phase 6 backend setup and physical-phone-safe API URL configuration, see [`backend/README.md`](backend/README.md) and [`docs/PHASE_6_IMPLEMENTATION.md`](docs/PHASE_6_IMPLEMENTATION.md).

Never add market-provider, AI-provider, database, signing, push, or privileged API credentials to Dart source, assets, defines, or Git. A `--dart-define` key is suitable only for local development; a production mobile app must use an AURUM backend proxy for private provider credentials.

## Architecture

```text
Flutter widget
  → Riverpod controller/provider
  → repository interface
  → mock repository (Phase 3)
  → real API repository (future Phase 4+)
```

`lib/app/` owns routing and theme. `lib/features/` owns screens and feature-specific presentation. `lib/shared/models/` holds the small, stable cross-feature demo domain model. `lib/shared/services/` owns repository interfaces, mock implementations and providers. UI widgets do not own fake market data or make HTTP requests.

## Important product boundary

Every demo asset, chart, signal and AI result is explicitly illustrative. AURUM is analysis support only—not financial advice, a prediction engine, an exchange, a broker, or a guarantee of performance.
