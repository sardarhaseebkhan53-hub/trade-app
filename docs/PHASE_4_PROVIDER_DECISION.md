# AURUM — Phase 4 market-data provider decision

**Decision:** Use **CoinGecko Demo API** as the Phase 4 development provider through an adapter boundary. The Flutter source never depends on CoinGecko JSON outside the data-service layer. AURUM production traffic must move through an AURUM backend proxy before a private/paid provider credential, commercial entitlement, aggregation policy, or higher-frequency workload is introduced.

## Evaluation criteria

AURUM needs ranked asset market data, price/change/market-cap/volume, asset lookup/search, global overview, historical price/volume/market-cap series, and an OHLC path. It also needs a provider whose IDs can be kept stable behind a repository, rather than binding UI widgets to exchange symbols.

| Provider | Development access / auth | Market list, rank and global overview | Search / asset detail | Historical / OHLC fit | Streaming | Decision |
| --- | --- | --- | --- | --- | --- | --- |
| **CoinGecko Demo** | Free Demo tier; documented key/header model and rate/call limits. Key is development configuration only, not a production mobile secret. | Strong fit: `/coins/markets`, `/global` | `/search`, `/coins/{id}` | Strong Phase 4 fit: market-chart/range and OHLC endpoints. Granularity/retention are plan-sensitive and must be displayed honestly. | Paid tiers offer WebSocket; not used in Phase 4. | **Selected.** Best breadth for a market-analysis dashboard. |
| CoinPaprika Free | Keyless/free endpoints available; free-tier limits and commercial/data-history terms require review. | Market/global/ticker support | Search and coin endpoints | Free OHLCV/history access is materially more constrained than AURUM’s required chart experience. | Enterprise-oriented. | Fallback candidate, not selected. |
| CoinCap | Public/free access is available, with higher limits when keyed. | Asset market-cap, volume and rank support | Asset endpoints | Historical price support is useful, but portable full OHLC/candlestick support is not the primary fit. | Market streaming available. | Useful quote-stream fallback, not selected. |
| Binance market data | Public market-data endpoints and WebSocket streams; exchange/jurisdiction availability must be checked. | Exchange-specific; not a neutral whole-market ranking/market-cap source. | Symbol-centric | Excellent candles/klines, but not sufficient by itself for AURUM’s global market-cap/ranking scope. | Strong WebSocket support. | Future supplementary exchange feed only. |

## Provider facts used in this decision

- CoinGecko’s current plan documentation describes a Demo tier with market data, search, global data, historical market data and OHLC chart capability, and its published plan/call limits are appropriate for a cached development build. The provider’s current documentation also states that HTTP 429 represents rate limiting and that Demo authentication uses `x-cg-demo-api-key`.
  Sources: [CoinGecko API plans](https://www.coingecko.com/en/api/pricing), [CoinGecko errors/rate limits](https://docs.coingecko.com/docs/common-errors-rate-limit), [market-chart range reference](https://docs.coingecko.com/v3.0.1/reference/coins-id-market-chart-range).
- CoinGecko documents plan-sensitive historical granularity: chart data must not be labelled as an exact 1H/4H series when the returned granularity differs. The AURUM adapter records the provider interval label and uses its documented mapping rather than fabricating candles.
  Source: [CoinGecko historical-data guidance](https://www.coingecko.com/learn/coingecko-api-troubleshooting-guide-and-solutions).
- CoinPaprika documents a free tier, but its own plan matrix restricts free historical OHLCV depth/granularity compared with the Phase 4 chart requirement.
  Source: [CoinPaprika API plans](https://docs.coinpaprika.com/api-plans).
- CoinCap documents keyless access and historical data, but the adapter evaluation keeps it as a fallback because AURUM needs the selected provider’s broader market-analytics endpoint family.
  Source: [CoinCap quickstart](https://coincapapi.mintlify.app/quickstart).
- Binance documents public kline data and market-data WebSocket services, but these are exchange-specific and do not replace a market-cap/ranking aggregator.
  Sources: [Binance market-data-only URLs](https://developers.binance.com/docs/binance-spot-api-docs/faqs/market_data_only), [Binance kline reference](https://developers.binance.com/docs/binance-spot-api-docs/websocket-api/market-data-requests).

## Security and deployment policy

1. The **development** adapter accepts a key only from `--dart-define=AURUM_MARKET_API_KEY=...`; `.env.example` is documentation only and is not loaded at runtime.
2. No real key is committed, printed, placed in a widget, or logged. The client logger records only the method, path, status and duration in debug builds.
3. A compiled mobile application cannot protect an API credential. For production, configure `AURUM_MARKET_API_BASE_URL` to an AURUM backend proxy; the proxy owns provider credentials, commercial licensing/attribution, provider switching, shared cache, rate policy, and abuse controls.
4. API base URLs must be HTTPS. `RemoteMarketRepository` never silently falls back to mock values. A user sees a typed failure or visible cached snapshot.

## Real-time choice

Phase 4 uses **foreground-only, deduplicated REST polling** rather than a WebSocket. On a market screen, a caller may request a refresh at a sensible interval; the repository coalesces duplicate requests and respects TTL/rate limits. Chart/detail requests are on-demand. Streams are deferred until a backend and entitlement policy are approved.

## Chart interval truthfulness

The selected API does not make every requested AURUM label a guaranteed native candle interval on every plan. The adapter maps AURUM selections to a provider request/range and returns `sourceIntervalLabel`:

| AURUM control | Request strategy | UI source label |
| --- | --- | --- |
| 1H | recent market-chart range; use returned fine-grained close points | `provider-derived intraday` |
| 4H | recent market-chart range; sample bounded close points | `provider-derived intraday` |
| 1D | 1-day market-chart range | `provider-derived daily view` |
| 1W | 7-day market-chart range | `provider-derived weekly view` |
| 1M | 30-day market-chart range | `provider-derived monthly view` |
| 1Y | 365-day market-chart range | `provider-derived yearly view` |

`OHLCData` is supported by the data architecture and service endpoint where the configured provider plan makes it available. The Phase 3 line-chart painter consumes a provider-neutral close series through a chart adapter; it never invents OHLC values from a line series.
