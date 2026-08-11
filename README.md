# AURUM

AURUM is a premium, mobile-first cryptocurrency **market-analysis and decision-support** application built with Flutter and Dart. It presents mock market context, charts, AI-analysis layouts, signals, watchlists and notifications in Phase 3. It does **not** execute trades, custody assets, promise outcomes, or contain production market/AI credentials.

## Current phase

**Phase 3 — Flutter foundation + premium mock-backed UI**

- Central AURUM Obsidian theme, components and responsive mobile shell
- Riverpod state management and GoRouter route structure
- Mock repositories behind API-ready interfaces
- No real market, AI, transaction, or authentication API integration
- Phase 1/2 specifications: [`docs/`](docs/)

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
flutter run --release -d <physical-device-id>
flutter build apk --release
```

## Non-secret configuration

`config/app_config.example.json` documents safe, public configuration values. Runtime configuration is read from `--dart-define`:

```bash
flutter run \
  --dart-define=AURUM_ENV=development \
  --dart-define=AURUM_API_BASE_URL=https://api.example.invalid \
  --dart-define=AURUM_ENABLE_TELEMETRY=false
```

Never add market-provider, AI-provider, database, signing, push, or privileged API credentials to Dart source, assets, defines, or Git. Those belong to the AURUM backend/secret infrastructure in later phases.

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
