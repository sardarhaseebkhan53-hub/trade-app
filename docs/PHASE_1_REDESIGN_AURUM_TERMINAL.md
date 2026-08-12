# AURUM TERMINAL — Phase 1 Complete Product Redesign

**Status:** APPROVAL GATE — no implementation until you approve.  
**Date:** 2026-08-12  
**Device target:** Flutter Android, TECNO K15k / Android 12 first, then other phone sizes.  
**Not a website. Not a desktop terminal. A phone-first trading-analysis product.**

This document replaces the previous Phase 2 Obsidian blueprint as the product direction. The current app and the older concept art are treated as an unapproved prototype.

---

## 1. Analysis of the current AURUM problem

I inspected the running product architecture, every primary screen, the analysis engines, the backend schema, and the existing concept images. The diagnosis is product-level, not a polish ticket.

### 1.1 What the current app actually is

AURUM today is a **collection of screens bolted onto a useful engine**, not one professional market product.

| Surface | What exists | Why it fails |
| --- | --- | --- |
| Home | Greeting, two duplicated “Market Overview” cards, featured list, null AI card, null signal card, Quick Tools icon grid | Does not answer “what is happening right now?” Feels like a settings hub. |
| Asset | Price, line chart, hardcoded RSI/MACD, fabricated 24h high/low (`price * 1.028`) | Looks like a wallet quote page, not a trading desk. |
| Chart | Custom-painted gold polyline + “Volume (demo)” | No candles, no crosshair, no S/R, no 1m–1W set. |
| Signals | Bias language (`Strong bullish bias`) and session memory | Never presented as BUY / SELL / WAIT with a transparent score. |
| AI | Separate `ai_analysis` and `ai_analyst` routes; home passes `analysis: null` | Feels like a chatbot stub, not a market analyst. |
| Scanner | Gainers / Losers / High Vol chips on featured assets | Not a multi-factor scanner. |
| Watchlist | Price list | No trend, no signal, no strength. |
| Portfolio | Local `_holdings` list with two hardcoded rows | No allocation, no AI risk brief, no persistence contract. |
| Navigation | Home / Markets / Analysis / AI / Portfolio | Analysis and AI compete. Watchlist and Scanner are buried. |
| Visual system | Obsidian gold-on-graphite cards | Tokens exist, but screens are generic stacked cards. Older mockups are **desktop stock dashboards** (AAPL, NVDA, S&P 500). Wrong product, wrong form factor. |

### 1.2 What is actually strong (do not throw away)

The prototype is not empty. The **brain** is more real than the **face**.

- Pure-Dart `TechnicalAnalysisService`: SMA, EMA, RSI, MACD, volume, volatility, range structure.
- `MarketAnalysisEngine` with published weights, factor scores, supporting / conflicting / risk / invalidation text.
- `SignalEngine` + immutable `SignalHistoryStore` (does not rewrite history).
- Domain models already distinguish insufficient data from a real assessment.
- Backend Prisma: users, sessions, watchlist, alerts, notifications, signals, AI analyses.
- Secure session store, biometric lock, backend client, Riverpod + GoRouter, Android host.

The product problem is not “we have no engine.” It is: **the engine is hidden behind a generic dashboard that does not feel live, intelligent, or trading-focused.**

### 1.3 Root causes

1. **No single product question.** Home greets the user. It does not brief the market.
2. **Wrong visual metaphor.** Cards + gold icons + “Quick Tools” = fintech starter kit. A trading-analysis app should feel like a **compressed terminal**.
3. **Wrong previous mockups.** Desktop equities. AURUM is a **crypto market-analysis phone app**.
4. **Signals are shy.** The engine already scores 0–100. The UI refuses to say BUY / SELL / WAIT, so the core promise never appears.
5. **AI is decorative.** Home AI card is `null`. There is no data → TA → signal → AI context pipeline on screen.
6. **Live status is fake-friendly.** Freshness widgets exist, then get hardcoded to `LIVE` with `lastUpdated: null`.
7. **Too many half-screens.** Scanner, journal, analysis, AI, AI history, signals, safety center — none is the hero.

### 1.4 Existing-code verdict

| Component | Verdict | Why |
| --- | --- | --- |
| Flutter / Riverpod / GoRouter / Android host | **KEEP** | Correct stack. |
| `TechnicalAnalysisService`, `MarketAnalysisEngine`, `SignalEngine`, history store | **KEEP + EXTEND** | Real methodology. Add BUY/SELL mapping, Bollinger, multi-horizon, score breakdown UI. |
| Domain models, data integrity, failures | **KEEP** | Sound. |
| Backend Prisma + auth + watchlist + alerts + signal/AI tables | **KEEP + EXTEND** | Add portfolio holdings, scanner snapshots, event alerts, news cache. |
| Market repository / CoinGecko adapter / cache | **REFACTOR** | Wire remote path for real; never default production to mock. |
| Theme tokens, primitives, charts, all feature screens | **REPLACE visually / REFACTOR structurally** | New design system and screen compositions. Keep controllers where they are clean. |
| Hardcoded regime, null AI cards, fake high/low, “Volume (demo)” | **REMOVE** | Dishonest. |
| Desktop stock concept art as implementation target | **REMOVE** | Wrong product. |
| Trade execution, custody, deposits, “guaranteed profit” | **NEVER ADD** | Product boundary. |

---

## 2. New product vision

**AURUM POCKET BROKER** is a broker desk that fits in one hand.

It should feel like **Zerodha Kite / Webull / a compact dealing ticket** — not a magazine, not a desktop terminal, not a luxury brochure.

```
pocket broker quotes
        ×
one-thumb chart ticket
        ×
live tape
        ×
BUY / WAIT / SELL analytical state
        ×
AI that explains the ticket
```

It is **not** an exchange. The BUY and SELL controls open the **why**, they do **not** place orders, hold coins, or move money.

### The first-second promise

When the user opens AURUM they must immediately know:

1. Is the market live or stale?
2. What is the market doing?
3. What asset is moving?
4. Why might it be moving?
5. What does the data say?
6. What does the AI think?
7. What are the bullish and bearish conditions?
8. What are the important levels?
9. What is the risk?
10. Is the analytical state **STRONG BUY / BUY / WAIT / SELL / STRONG SELL**?

### One sentence

> AURUM feels like a pocket broker: live quotes, a chart ticket, and a BUY / WAIT / SELL state you can tap to see the evidence — without ever placing an order.

### Brand character

| Be | Do not be |
| --- | --- |
| Precise, live, intelligent | Generic, chatty, gamified |
| Calm luxury metal on void | Neon exchange / purple AI orb |
| Evidence-first | “Trust the model” |
| Mobile-dense | Desktop Bloomberg clone |
| Honest about missing data | Fake live prices |

---

## 3. Complete feature architecture

```text
┌──────────────────────────────────────────────────────────┐
│                     AURUM CLIENT                         │
│  Presentation (screens) → Riverpod controllers           │
└───────────────▲────────────────────────────▲─────────────┘
                │                            │
        domain use cases              local cache / secure store
                │
┌───────────────┴──────────────────────────────────────────┐
│              AURUM MARKET INTELLIGENCE ENGINE            │
│                                                          │
│  Ingest → Validate → Technical → Structure → Regime      │
│       → Signal score → Event detect → AI context         │
│       → Alerts / briefing / scenarios                    │
└───────────────▲──────────────────────────────────────────┘
                │
┌───────────────┴──────────────────────────────────────────┐
│                    AURUM BACKEND                         │
│  Auth, entitlements, secrets, normalization,             │
│  scheduled monitoring, push, news proxy, AI orchestration│
└───────────────▲──────────────────────────────────────────┘
                │
     licensed market / news / AI providers
```

### Engine modules

| Module | Input | Output |
| --- | --- | --- |
| **Ingest** | Quotes, OHLCV, volume, news headlines, fear/greed | Timestamped snapshots + `asOf` |
| **Integrity** | Raw snapshot | LIVE / DELAYED / STALE / OFFLINE / UNAVAILABLE |
| **Technical** | Candles | SMA, EMA, RSI, MACD, Bollinger, volume, volatility |
| **Structure** | Price series | Support 1/2, Resistance 1/2, range state |
| **Regime** | Multi-asset + BTC dominance + volatility | Risk-on / risk-off / mixed + short/mid/long horizon |
| **Signal** | Factor scores | STRONG BUY → STRONG SELL + 0–100 + why / risks / invalidation |
| **Event** | Delta vs baseline | Breakout, volume spike, trend change, signal change |
| **AI Analyst** | Validated engine context only | Structured brief + scenarios + answers |
| **Scanner** | Universe + filters | Ranked matches with signal + score |
| **Portfolio analytics** | User-entered holdings + live marks | Value, allocation, concentration, risk brief |

If any module lacks data it returns **DATA UNAVAILABLE** or **LAST UPDATED**, never a invented number.

Signal detail actions are **History** and **View asset / AI analysis** only. There is never a Trade / Buy now / Place order control.

### Signal score (transparent, shown in UI)

| Factor | Max | Example |
| --- | --- | --- |
| Trend (EMA / SMA stack, price vs MA) | +20 | Price > EMA50 > EMA200 |
| Momentum (RSI regime) | +15 | RSI 55–68 supportive |
| MACD | +15 | Histogram positive / bullish cross |
| Volume | +10 | Volume > 20-period average |
| Structure (S/R location) | +10 | Hold above support |
| Volatility penalty | −10 to 0 | Extreme vol reduces conviction |
| Conflict penalty | −15 to 0 | Opposing factors |

**Mapping**

| Score | Analytical state |
| ---: | --- |
| 80–100 | STRONG BUY |
| 65–79 | BUY |
| 36–64 | WAIT |
| 21–35 | SELL |
| 0–20 | STRONG SELL |

This is an **automated analytical assessment**, never advice, never a win-rate, never “guaranteed.”

---

## 4. New navigation structure

Pocket-broker dock. Five destinations. The **center tab is TRADE** (chart + ticket), like a real broker app.

```text
WATCH     MARKETS     TRADE     PORTFOLIO     MORE
```

| Tab | Job |
| --- | --- |
| **WATCH** | Default home. Broker quote blotter: last, change, %, signal. |
| **MARKETS** | Universe, gainers/losers/volume, heatmap, scanner entry. |
| **TRADE** | Full-bleed chart + BUY / WAIT / SELL analytical ticket. |
| **PORTFOLIO** | Manual positions blotter + P/L. No custody. |
| **MORE** | AI analyst, alerts, news, journal, profile, security. |

### Secondary (search, More, sheets, deep links)

Scanner · Alerts · Signal detail · Signal history · Advanced chart · News · Journal · Notifications · Profile · Security · Privacy · Settings · Economic calendar

**Android back:** close keyboard → close sheet → pop detail → tab root → system exit. Never jump tabs.

**No FAB.** A floating gold button would imply “trade now.”

```text
Launch
  → Splash (real bootstrap only)
  → First-launch safety / disclosure
  → Login or guest (if approved)
  → HOME

HOME → asset / signal / AI brief / movers / watch
MARKETS → search → asset → chart / signal / AI
AI → ask about asset / compare / explain signal → history
WATCH → asset / alert
PORTFOLIO → holding → asset / AI portfolio brief

Notification → session gate → exact event (signal change, breakout, vol spike)
```

---

## 5. New AI / signal architecture

```text
MARKET DATA
    ↓ validate + freshness
TECHNICAL ANALYSIS
    ↓
STRUCTURE + REGIME
    ↓
SIGNAL ENGINE  →  STRONG BUY … STRONG SELL
    ↓
EVENT DETECTOR  →  alerts / push (opt-in, no spam)
    ↓
AI CONTEXT PACK  (numbers, levels, reasons, risks, asOf, version)
    ↓
AI ANALYST  (structured JSON only)
    ↓
UI: Analysis card / chat answer / briefing
```

### AI is a market analyst, not a chatbot

The user can ask:

- Analyze BTC.
- Why is BTC going up / falling?
- Should I wait?
- What are support / resistance levels?
- What changed in the last hour?
- Compare BTC and ETH.
- Explain this chart / this signal.

Every answer must be grounded in the context pack. If data is missing, the AI says so.

### Analysis card (every asset)

```text
BTC / USDT
MARKET VIEW     BULLISH
SIGNAL          BUY
STRENGTH        78 / 100
TREND           Bullish
MOMENTUM        Strong
VOLATILITY      High
SUPPORT         $66,210
RESISTANCE      $68,850
WHY             expand
RISKS           expand
INVALIDATION    price < $66,210
as of           10:42:15 · LIVE
```

### Scenario engine

| Scenario | Shows |
| --- | --- |
| Bullish | Conditions that support further upside |
| Base | Sideways / digestion |
| Bearish | Conditions that indicate downside |

Each has conditions, evidence, risks, invalidation.

### Monitoring honesty

Continuous monitoring is claimed **only** if the backend job / stream is actually running. Otherwise the UI says “refreshes when opened” or “last scan 10:41.”

Notifications: on/off, priority, quiet hours, asset selection. No spam.

---

## 6. New premium UI design direction

### Name: AURUM POCKET BROKER

This revision drops the editorial “AI magazine” layout. The phone must feel like a **dealing app**:

- Quote blotter first, not greeting cards
- Sticky symbol + last + %
- Chart owns the TRADE tab
- Three-button ticket: **BUY · WAIT · SELL** (current state highlighted)
- Tiny caption on every ticket: `Analytical · not an order`
- Dense 52–56 dp rows, tabular last / chg / %
- Gold only on the wordmark and selected tab — green/red do the market work

### Color system (new tokens — not the old Obsidian set)

| Token | Hex | Role |
| --- | --- | --- |
| `void` | `#050608` | Root, splash, chart canvas |
| `canvas` | `#0A0C10` | Page |
| `panel` | `#11141A` | Cards / sheets |
| `panelRaised` | `#171B22` | Selected / raised |
| `hairline` | `#262B34` | 1 px borders, chart grid |
| `metal` | `#C4A35A` | Brand, selected tab, single primary action |
| `metalSoft` | `#E4D2A0` | Metal on dark text |
| `inkOnMetal` | `#1A1408` | Text on metal buttons |
| `bull` | `#2DB87A` | Positive move, BUY context |
| `bear` | `#E45A5A` | Negative move, SELL context |
| `wait` | `#9AA3B2` | WAIT / neutral |
| `caution` | `#D9A441` | Risk (distinct from metal) |
| `live` | `#3DDC97` | Live pulse only |
| `text` | `#F3F4F6` | Primary |
| `muted` | `#8B93A1` | Secondary |
| `faint` | `#5C6470` | Metadata |

**Rules**

- Metal is brand/focus. It is **never** “this will make money.”
- Green/red only on signed values, candles, and signal state — always with text (`+2.84%`, `BUY`).
- Do not wash the whole screen green or red.
- No purple AI, no neon, no rainbow heatmap, no glass orbs.

### Typography

| Use | Family | Notes |
| --- | --- | --- |
| Wordmark / display | **Syne** (or licensed equivalent) | Tight, architectural |
| UI / body | **Satoshi / Manrope** | Calm, modern |
| Prices, %, clocks | **IBM Plex Mono** tabular | Columns never jitter |

### Spacing and craft

- 16 dp page inset on small Android (TECNO K15k class), 20 dp on 360+.
- 48 dp minimum targets.
- Radius: 10 chips, 14 controls, 16 panels. Not every card is a pill.
- Elevation is a hairline, not a drop shadow.
- Motion: 160–220 ms. Number crossfade, not slot machines. Reduced-motion honored.

### Live status language (always visible on market surfaces)

```text
● LIVE        10:42:15
◐ DELAYED     10:39:02
○ STALE       09:11:40
✕ OFFLINE     last 09:11:40
— UNAVAILABLE
```

Stale data is never labeled live.

---

## 7. Complete screen plan

| # | Screen | Purpose |
| ---: | --- | --- |
| 1 | Splash | Real bootstrap only. Metal wordmark on void. |
| 2 | First-launch safety | Analysis-only, volatility, data freshness, privacy. Must acknowledge. |
| 3 | Login | Email / Google. Guest only if policy allows. |
| 4 | Sign up | Minimal fields + legal. |
| 5 | **Home** | Live briefing. See mockup 1. |
| 6 | **Markets** | Ranked universe + categories + heatmap entry. |
| 7 | Market heatmap | Cap / move / volume, 1H 24H 7D. |
| 8 | Search | Assets, news, AI history, journal. Recents. |
| 9 | **Asset / Trade view** | Price, candles, volume, TF, S/R, signal, AI. Mockup 2. |
| 10 | Advanced chart | Full-bleed candles, crosshair, zoom/pan, overlays. |
| 11 | **AI analysis card** | Structured brief. |
| 12 | **AI analyst** | Ask grounded questions. Mockup 3. |
| 13 | **Signal detail** | BUY/SELL/WAIT + score breakdown. Mockup 4. |
| 14 | Signal history | Immutable log. Never rewritten to look successful. |
| 15 | **Watchlist** | Intelligent rows. Mockup 6. |
| 16 | **Scanner** | Multi-factor scan. Mockup 5. |
| 17 | **Alerts** | Event intelligence. Mockup 8. |
| 18 | Alert preferences | On/off, quiet hours, assets, priority. |
| 19 | **Portfolio** | Manual holdings + AI risk. Mockup 7. |
| 20 | Portfolio risk | Concentration, vol, exposure. |
| 21 | Journal | User notes linked to asset/signal. |
| 22 | News | What happened / why it matters / affected assets / facts vs interpretation. Never invented. |
| 23 | Economic calendar | Dated events only from a real feed. |
| 24 | Notifications inbox | Deep link to the event. |
| 25 | Profile | Account, guest convert. |
| 26 | Security | Biometric, sessions, 2FA. |
| 27 | Privacy | Consent, export, delete. |
| 28 | Settings | Quote currency, default TF, reduced motion. |

Every major block has **loading / success / empty / error / offline / stale**.

---

## 8. UI mockups / visual concept

New mobile concepts (not screenshots of the current app, not the old desktop stock art):

| File | Screen |
| --- | --- |
| `assets/design/redesign/01_home.png` | Home — live briefing |
| `assets/design/redesign/02_asset_trade.png` | Asset / trading terminal |
| `assets/design/redesign/03_ai_analyst.png` | AI market analyst |
| `assets/design/redesign/04_signal.png` | Buy/Sell signal detail |
| `assets/design/redesign/05_scanner.png` | Market scanner |
| `assets/design/redesign/06_watchlist.png` | Intelligent watchlist |
| `assets/design/redesign/07_portfolio.png` | Portfolio intelligence |
| `assets/design/redesign/08_alerts.png` | Intelligent alerts |

### Home composition (locked intent)

```text
AURUM                         ● LIVE  10:42:15
                              search · bell

TOTAL MARKET          BTC DOM           SENTIMENT
$2.41T  +1.8%         54.2%             GREED 72

AI MARKET BRAIN
“BTC is leading a risk-on session. Breadth is positive
 but BTC is testing nearby resistance.”
BULLISH 78%  ████████░░  BEARISH 22%
[ VIEW FULL ANALYSIS ]

TOP SIGNAL
BTC / USDT                         STRONG BUY
$67,420   +2.84%                   78 / 100
Why: EMA stack · MACD · volume
[ ANALYZE ]

MOVERS     Gainers | Losers | Volume | Trending
WATCH      BTC BUY 78 · ETH BUY 71 · SOL WAIT 54
```

### Asset / trade composition

```text
←  BTC / USDT                              ★
$67,420.18
+1,862.40   (+2.84%)          ● LIVE 10:42:15

1m  5m  15m  30m  1H  4H  1D  1W
CANDLES + VOLUME + S1/S2 R1/R2 + crosshair

SHORT  BULLISH     MID  BULLISH     LONG  NEUTRAL
SIGNAL STRONG BUY  78/100
S1 66,210   S2 64,880   R1 68,850   R2 71,200
[ WHY ]  [ AI ANALYSIS ]
```

---

## 9. Implementation roadmap — only after approval

### Stage 0 — Design lock (this phase)

Approval of vision, tokens, nav, signal language, mockups.

### Stage 1 — Foundation

New design tokens and primitives. New 5-tab shell. Honest freshness. No fake LIVE.

### Stage 2 — Market core

Home briefing, Markets, Search, Asset header, candlestick chart (1m–1W), S/R overlays, integrity states. Physical-device chart gate on TECNO K15k.

### Stage 3 — Intelligence

Extend existing engines: BUY/SELL mapping, score breakdown, Bollinger, multi-horizon regime, signal history UI, scanner, event alerts.

### Stage 4 — AI analyst

Context pack → structured AI. Analysis card, ask-the-analyst, scenarios. No hardcoded answers in production.

### Stage 5 — Personal layer

Intelligent watchlist, manual portfolio + risk brief, news+AI (real headlines only), journal, notification policy.

### Stage 6 — Harden

Offline/stale, security, privacy, performance (cache, coalesce ticks, isolate chart), analyzer/tests, signed APK, physical-device QA.

Production never ships mock prices, mock signals, or mock news unlabeled.

---

## 10. Approval checkpoint

I have **not** started the rebuild.

Please review:

- [ ] Product vision (AURUM POCKET BROKER — quotes + chart ticket)
- [ ] Five-tab dock: Watch / Markets / TRADE / Portfolio / More
- [ ] BUY / WAIT / SELL ticket (analytical, never an order)
- [ ] AI explains the ticket from More, not a chatbot toy
- [ ] Dense broker blotter visual system
- [ ] Eight pocket-broker mobile mockups
- [ ] KEEP / REFACTOR / REPLACE / REMOVE of existing code
- [ ] Roadmap only after approval

---

# APPROVAL REQUIRED — Do you approve this AURUM design?

Reply with **APPROVE** or **REQUEST CHANGES**.

If you request changes I will revise the concept and mockups and ask again.  
I will not implement screens until you approve.
