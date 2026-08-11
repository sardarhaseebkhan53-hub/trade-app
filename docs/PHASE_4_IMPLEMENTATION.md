# AURUM — Phase 4 real market-data integration

## Status

**Implemented in source:** Provider-neutral real market-data path, CoinGecko development adapter, typed models, centralized HTTP client, in-memory cache, freshness metadata, provider error mapping, debounced search, real-data UI bindings, and offline/mock mode.

**Not validated in this sandbox:** Flutter/Dart/Android tooling and physical-device execution remain blocked exactly as recorded in `PHASE_3_ENVIRONMENT_STATUS.md`. A direct unauthenticated transport probe to `api.coingecko.com` is also blocked by this sandbox's outbound TLS boundary. No command result in this document implies a real device/API run.

## Architecture

```text
Flutter screen
  ↓ Riverpod provider / controller
MarketRepository
  ├── MockMarketRepository              (explicit AURUM_MARKET_DATA_MODE=mock)
  └── RemoteMarketRepository            (default remote mode)
        ↓ CoinGeckoMarketService        (provider JSON only)
        ↓ HttpMarketApiClient            (timeouts, retry, typed errors, safe logging)
        ↓ CoinGecko Demo API or future AURUM proxy
```

Widgets receive `MarketSnapshot<T>`, never provider JSON. A snapshot carries the typed data, source, `asOf`, cache state, stale state, and chart source-interval label. This prevents cached data from being presented as live.

## Selected development provider

CoinGecko Demo is selected for Phase 4 because it fits ranked markets, current price/change/market-cap/volume, global overview, search, asset details, market-history series and an OHLC path behind one provider adapter. See [`PHASE_4_PROVIDER_DECISION.md`](PHASE_4_PROVIDER_DECISION.md) for the comparison, constraints, official links and production policy.

### Provider endpoint mapping

| AURUM requirement | Adapter request | Repository result |
| --- | --- | --- |
| Ranked markets / featured / watchlist quotes | `/coins/markets` | `MarketTicker` → `MarketAsset` |
| Search | `/search`, then bounded `/coins/markets?ids=…` | Canonical IDs → priced search results |
| Global market overview | `/global` | `MarketOverview` |
| Detailed market stats | `/coins/{id}` | `MarketStats` → `AssetStatistics` |
| Historical price / volume | `/coins/{id}/market_chart/range` | `HistoricalPrice`, `VolumeData`, `ChartSeries` |
| OHLC data path | `/coins/{id}/ohlc` | `OHLCData` |

The chart painter receives a provider-neutral bounded line series through `ChartDataAdapter`; it does not parse JSON or invent OHLC values. OHLC is available to a future candlestick renderer only when the configured provider plan returns actual candle data.

## Configuration and security

`.env.example` documents development placeholders only. It is not read at runtime. Pass non-secret configuration locally with `--dart-define`:

```bash
flutter run \
  --dart-define=AURUM_MARKET_DATA_MODE=remote \
  --dart-define=AURUM_MARKET_PROVIDER=coingecko \
  --dart-define=AURUM_MARKET_API_BASE_URL=https://api.coingecko.com/api/v3 \
  --dart-define=AURUM_MARKET_API_KEY=YOUR_DEVELOPMENT_DEMO_KEY \
  --dart-define=AURUM_ENABLE_NETWORK_LOGGING=true
```

For offline UI work or tests:

```bash
flutter run --dart-define=AURUM_MARKET_DATA_MODE=mock
```

- No key is committed.
- The client never logs headers, keys, passwords, tokens, raw bodies or personal data.
- Only HTTPS base URLs are accepted.
- `x-cg-demo-api-key` is attached only when a development key is configured.
- A key in a distributed mobile binary is not safe. For a production build, set `AURUM_MARKET_API_BASE_URL` to an AURUM backend proxy and keep provider credentials, licence enforcement, user rate policy and aggregate caching on the server.
- Remote failure never silently switches to mock data. Mock mode is explicit in configuration and its snapshot source reads `Demo mock data`.

## Reliability policy

### API client

`HttpMarketApiClient` centralizes:

- HTTPS base URI validation and request construction
- JSON decoding and response-type validation
- 12-second request timeout
- A single retry only for transient connection/timeout failure
- In-flight request coalescing per full URI
- typed `NetworkException`, `ApiTimeoutException`, `UnauthorizedException`, `RateLimitException`, `ServerException`, `ParsingException`, and `UnknownApiException`
- `Retry-After` handling and a local rate-limit cool-down
- debug-only method/path/status/duration logging

It never exposes raw provider response text to the UI.

### Cache, freshness and rate protection

`RemoteMarketRepository` has a bounded in-memory cache with typed entries and the following starting TTLs:

| Data | TTL | Failure behavior |
| --- | ---:| --- |
| Market list / featured / global overview | 60 seconds | Return stale cached snapshot when present; otherwise typed error |
| Watchlist quotes | 30 seconds | Request only watchlisted canonical IDs |
| Asset stats | 5 minutes | Return stale cached snapshot when present |
| Historical chart | 5 minutes | Retain previous range while refresh fails when provider state is retained |
| OHLC | 15 minutes | Typed unavailable/error state; never synthesize candles |
| Search results | 90 seconds | Debounced query and cache per normalized search |

The adapter limits chart line/candle data to 180 rendered points/candles. It does not load thousands of points into the phone chart. Search waits 360 ms after the latest keystroke and does not request when the query is empty.

### Real-time policy

Phase 4 intentionally uses on-demand loading, pull-to-refresh and TTL-based refresh—not an always-running WebSocket or background poller. It produces real provider snapshots while avoiding duplicate background traffic and stops naturally when no screen requests data. Streaming is deferred until a backend proxy, entitlement/licensing decision and foreground lifecycle policy are approved.

## UI bindings

- **Overview** uses real global market cap, 24h global change, volume and BTC dominance, with provider/source/freshness wording.
- **Featured assets** and **Markets** use remote ranked listings, current USD price, 24h change, volume, market cap/rank and provider sparklines where returned.
- **Markets search** uses the provider search → canonical ID → bounded quote lookup flow.
- **Asset Detail** uses real asset quote, 24h movement, stats and provider-derived historical chart data. The displayed interval label is explicit rather than claiming a native candle interval that was not returned.
- **Watchlist** fetches only saved asset IDs from the real repository; it does not refetch the entire market list.
- Existing Phase 3 AI, technical indicator and signal cards remain visibly demo/Phase 5 preview content. Phase 4 does not add an AI/signal engine or trade execution.

## Automated test source added

- `market_data_models_test.dart`: numeric/string/null parsing, timestamp tuples, OHLC and missing nested data
- `market_api_client_test.dart`: successful JSON, HTTP 429, 5xx and timeout mappings using `http` mocks
- `remote_market_repository_test.dart`: remote mapping, cache reuse and selected-ID watchlist request behavior with a fake client
- `market_providers_test.dart`: Riverpod market snapshot resolution with mock repository override

These tests are network-independent. They must be run with `flutter test` after the official local Flutter toolchain is available.

## Required local/device acceptance sequence

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

On the USB-connected Android phone, validate initial/refresh/load-error/stale flows on Overview, Markets, Asset Detail and Watchlist; then disable/re-enable data to verify cached/error/retry behavior. Do not call Phase 4 device-validated until these commands and tests pass on that workstation.
