import 'dart:async';

import 'package:flutter/material.dart';

import '../models/market_data_models.dart';
import '../models/market_models.dart';
import 'repositories.dart';

/// Phase 3 demo-only repositories. Replace these behind the same interfaces in Phase 4+.
class MockMarketRepository implements MarketRepository {
  static const _latency = Duration(milliseconds: 420);

  static const List<MarketAsset> _assets = <MarketAsset>[
    MarketAsset(
      id: 'bitcoin',
      rank: 1,
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 68420.50,
      change24h: 3.42,
      volume: 24.8e9,
      marketCap: 1.35e12,
      iconColor: Color(0xFFF7931A),
      sparkline: <double>[44, 47, 45, 50, 49, 54, 53, 58, 57, 62, 65, 67],
      description: 'The original decentralized digital asset.',
    ),
    MarketAsset(
      id: 'ethereum',
      rank: 2,
      name: 'Ethereum',
      symbol: 'ETH',
      price: 3012.18,
      change24h: 2.11,
      volume: 15.2e9,
      marketCap: 362e9,
      iconColor: Color(0xFF7A88D1),
      sparkline: <double>[50, 49, 52, 51, 54, 56, 55, 58, 59, 62, 61, 66],
      description: 'A programmable smart-contract network.',
    ),
    MarketAsset(
      id: 'solana',
      rank: 3,
      name: 'Solana',
      symbol: 'SOL',
      price: 153.67,
      change24h: -1.23,
      volume: 4.6e9,
      marketCap: 72e9,
      iconColor: Color(0xFF8A64E8),
      sparkline: <double>[65, 62, 63, 61, 58, 56, 57, 54, 55, 51, 50, 48],
      description: 'A high-throughput smart-contract network.',
    ),
    MarketAsset(
      id: 'bnb',
      rank: 4,
      name: 'BNB',
      symbol: 'BNB',
      price: 595.04,
      change24h: 0.83,
      volume: 1.98e9,
      marketCap: 87e9,
      iconColor: Color(0xFFF3BA2F),
      sparkline: <double>[38, 40, 39, 41, 42, 44, 43, 46, 45, 47, 48, 49],
    ),
    MarketAsset(
      id: 'xrp',
      rank: 5,
      name: 'XRP',
      symbol: 'XRP',
      price: 0.5187,
      change24h: -0.62,
      volume: 1.6e9,
      marketCap: 29e9,
      iconColor: Color(0xFFF1F4F8),
      sparkline: <double>[59, 61, 60, 58, 59, 57, 56, 54, 55, 52, 51, 50],
    ),
    MarketAsset(
      id: 'cardano',
      rank: 6,
      name: 'Cardano',
      symbol: 'ADA',
      price: 0.4561,
      change24h: 1.04,
      volume: 482e6,
      marketCap: 16.1e9,
      iconColor: Color(0xFF3CC8C8),
      sparkline: <double>[40, 42, 41, 43, 44, 46, 45, 47, 50, 49, 51, 53],
    ),
    MarketAsset(
      id: 'avalanche',
      rank: 7,
      name: 'Avalanche',
      symbol: 'AVAX',
      price: 35.28,
      change24h: -0.34,
      volume: 567e6,
      marketCap: 14.3e9,
      iconColor: Color(0xFFE84142),
      sparkline: <double>[58, 59, 57, 58, 56, 55, 53, 54, 52, 53, 51, 50],
    ),
  ];

  @override
  Future<MarketSnapshot<MarketAsset>> getAsset(String assetId) async {
    await Future<void>.delayed(_latency);
    final asset = _assets.firstWhere(
      (MarketAsset item) => item.id == assetId,
      orElse: () => _assets.first,
    );
    return _snapshot(asset);
  }

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getAssetsByIds(
    Iterable<String> assetIds,
  ) async {
    await Future<void>.delayed(_latency);
    final requested = assetIds.toSet();
    return _snapshot(
      _assets.where((MarketAsset asset) => requested.contains(asset.id)).toList(growable: false),
    );
  }

  @override
  Future<MarketSnapshot<ChartSeries>> getChart(String assetId, String timeframe) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final asset = (await getAsset(assetId)).data;
    final multiplier = switch (timeframe) {
      '1H' => 0.55,
      '4H' => 0.7,
      '1D' => 1.0,
      '1W' => 1.35,
      '1M' => 1.75,
      _ => 2.1,
    };
    final now = DateTime.now().toUtc();
    final prices = List<HistoricalPrice>.generate(
      asset.sparkline.length,
      (int index) => HistoricalPrice(
        timestamp: now.subtract(Duration(minutes: (asset.sparkline.length - index) * 5)),
        priceUsd: asset.sparkline[index] * multiplier,
      ),
      growable: false,
    );
    return _snapshot(
      ChartSeries(
        prices: prices,
        volumes: const <VolumeData>[],
        requestedTimeframe: timeframe,
        sourceIntervalLabel: 'demo-derived $timeframe view',
      ),
      interval: 'demo-derived $timeframe view',
    );
  }

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getFeaturedAssets() async {
    await Future<void>.delayed(_latency);
    return _snapshot(_assets.take(3).toList(growable: false));
  }

  @override
  Future<List<TechnicalIndicator>> getIndicators(String assetId) async {
    await Future<void>.delayed(_latency);
    return const <TechnicalIndicator>[
      TechnicalIndicator(
        label: 'RSI (14)',
        value: '58.2',
        interpretation: 'Demo neutral momentum',
        direction: MarketDirection.neutral,
      ),
      TechnicalIndicator(
        label: 'MACD',
        value: 'Positive',
        interpretation: 'Demo momentum context',
        direction: MarketDirection.bullish,
      ),
      TechnicalIndicator(
        label: 'EMA 20/50',
        value: 'Above',
        interpretation: 'Demo trend context',
        direction: MarketDirection.bullish,
      ),
      TechnicalIndicator(
        label: 'Volume',
        value: '1.08×',
        interpretation: 'Demo volume context',
        direction: MarketDirection.neutral,
      ),
    ];
  }

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getMarkets({String query = ''}) async {
    await Future<void>.delayed(_latency);
    final normalized = query.trim().toLowerCase();
    final values = normalized.isEmpty
        ? _assets
        : _assets
            .where(
              (MarketAsset asset) =>
                  asset.name.toLowerCase().contains(normalized) ||
                  asset.symbol.toLowerCase().contains(normalized),
            )
            .toList(growable: false);
    return _snapshot(values);
  }

  @override
  Future<MarketSnapshot<List<OHLCData>>> getOhlc(String assetId, String timeframe) async {
    final chart = await getChart(assetId, timeframe);
    final candles = chart.data.prices.map((HistoricalPrice point) => OHLCData(
      timestamp: point.timestamp,
      open: point.priceUsd * 0.995,
      high: point.priceUsd * 1.01,
      low: point.priceUsd * 0.99,
      close: point.priceUsd,
    )).toList(growable: false);
    return _snapshot(candles, interval: 'demo-derived OHLC');
  }

  @override
  Future<MarketSnapshot<MarketOverview>> getOverview() async {
    await Future<void>.delayed(_latency);
    return _snapshot(MarketOverview(
      totalMarketCapUsd: 2.48e12,
      totalVolumeUsd: 86.2e9,
      marketCapChange24h: 1.8,
      btcDominance: 54.2,
      activeCryptocurrencies: 12400,
      updatedAt: DateTime.now().toUtc(),
    ));
  }

  @override
  Future<MarketSnapshot<AssetStatistics>> getStatistics(String assetId) async {
    await Future<void>.delayed(_latency);
    final asset = (await getAsset(assetId)).data;
    return _snapshot(AssetStatistics(
      marketCap: asset.marketCap,
      volume24h: asset.volume,
      dayHigh: asset.price * 1.028,
      dayLow: asset.price * 0.967,
      circulatingSupply: asset.id == 'bitcoin' ? '19.8M BTC' : '—',
      allTimeHigh: asset.id == 'bitcoin' ? 73750.07 : asset.price * 1.45,
    ));
  }

  MarketSnapshot<T> _snapshot<T>(T data, {String? interval}) => MarketSnapshot(
    data: data,
    asOf: DateTime.now().toUtc(),
    source: 'Demo mock data',
    isCached: false,
    isStale: false,
    sourceIntervalLabel: interval,
  );

}

class MockSignalRepository implements SignalRepository {
  static const _latency = Duration(milliseconds: 380);

  final List<AnalysisSignal> _signals = <AnalysisSignal>[
    AnalysisSignal(
      id: 'btc-context',
      assetId: 'bitcoin',
      pair: 'BTC / USDT',
      direction: MarketDirection.bullish,
      strength: SignalStrength.confirmed,
      riskLevel: RiskLevel.moderate,
      status: SignalStatus.active,
      issuedAt: DateTime.now().subtract(const Duration(minutes: 43)),
      priceSnapshot: 68420.50,
      entryZone: '\$67,200 – \$68,000',
      invalidation: 'Below \$65,200',
      thesis: 'Price remains above its short-term average while volume is steady.',
      indicators: <String>['RSI 58', 'MACD positive', 'EMA support'],
    ),
    AnalysisSignal(
      id: 'eth-watch',
      assetId: 'ethereum',
      pair: 'ETH / USDT',
      direction: MarketDirection.neutral,
      strength: SignalStrength.developing,
      riskLevel: RiskLevel.low,
      status: SignalStatus.watching,
      issuedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      priceSnapshot: 3012.18,
      entryZone: '\$2,980 – \$3,040',
      invalidation: 'Below \$2,850',
      thesis: 'Momentum is balanced while the asset tests a recent range boundary.',
      indicators: <String>['RSI 51', 'Range bound', 'Volume stable'],
    ),
    AnalysisSignal(
      id: 'sol-updated',
      assetId: 'solana',
      pair: 'SOL / USDT',
      direction: MarketDirection.bearish,
      strength: SignalStrength.developing,
      riskLevel: RiskLevel.elevated,
      status: SignalStatus.updated,
      issuedAt: DateTime.now().subtract(const Duration(hours: 5)),
      priceSnapshot: 153.67,
      entryZone: '\$150 – \$155',
      invalidation: 'Above \$161',
      thesis: 'Price is below its short-term trend line with uneven participation.',
      indicators: <String>['RSI 44', 'EMA resistance', 'Volume mixed'],
    ),
  ];

  @override
  Future<List<AnalysisSignal>> getForAsset(String assetId) async {
    await Future<void>.delayed(_latency);
    return _signals
        .where((AnalysisSignal signal) => signal.assetId == assetId)
        .toList(growable: false);
  }

  @override
  Future<List<AnalysisSignal>> getSignals({bool includeHistory = false}) async {
    await Future<void>.delayed(_latency);
    if (includeHistory) return _signals;
    return _signals
        .where((AnalysisSignal signal) => signal.status != SignalStatus.archived)
        .toList(growable: false);
  }
}

class MockAiAnalysisRepository implements AiAnalysisRepository {
  static const _latency = Duration(milliseconds: 650);

  @override
  Future<AiAnalysis> getAnalysis(String assetId) async {
    await Future<void>.delayed(_latency);
    return AiAnalysis(
      assetId: assetId,
      headline: 'Neutral-to-bullish context',
      direction: MarketDirection.bullish,
      confidence: 72,
      summary:
          'Price is holding above a short-term trend reference while participation remains measured. This is analytical context, not a prediction.',
      technicalView: 'Price is above the 20-period average and tests a prior range high.',
      momentum: 'RSI is near the midpoint with improving MACD momentum.',
      volatility: 'Volatility is contained but may expand near visible range boundaries.',
      observations: const <String>[
        'Price holds above EMA 20 with stable volume.',
        'RSI remains neutral rather than extended.',
        'MACD histogram is improving but can reverse quickly.',
      ],
      scenarios: const <AnalysisScenario>[
        AnalysisScenario(
          label: 'Bullish scenario',
          condition: 'Price holds above the current support zone.',
          context: 'Momentum could continue toward the next visible range level.',
          direction: MarketDirection.bullish,
        ),
        AnalysisScenario(
          label: 'Neutral scenario',
          condition: 'Participation remains mixed near resistance.',
          context: 'A consolidation range may persist while indicators reset.',
          direction: MarketDirection.neutral,
        ),
        AnalysisScenario(
          label: 'Bearish scenario',
          condition: 'Price loses the current trend reference with volume.',
          context: 'The prior support zone becomes the next context to review.',
          direction: MarketDirection.bearish,
        ),
      ],
      risks: const <String>[
        'Crypto markets can move rapidly and data can become stale.',
        'Technical indicators are contextual, not guarantees.',
        'This demo analysis does not consider personal objectives or risk tolerance.',
      ],
      asOf: DateTime.now().subtract(const Duration(minutes: 8)),
    );
  }

  @override
  Future<MarketInsight> getMarketInsight() async {
    await Future<void>.delayed(_latency);
    return MarketInsight(
      title: 'AI market insight',
      summary: 'Capital is rotating into major assets while intraday volatility is contained.',
      direction: MarketDirection.bullish,
      observation: 'BTC remains above its short-term trend reference.',
      asOf: DateTime.now().subtract(const Duration(minutes: 8)),
    );
  }
}

class MockWatchlistRepository implements WatchlistRepository {
  final Set<String> _ids = <String>{'bitcoin', 'ethereum', 'solana'};

  @override
  Future<Set<String>> getAssetIds() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Set<String>.unmodifiable(_ids);
  }

  @override
  Future<void> setWatched(String assetId, bool isWatched) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (isWatched) {
      _ids.add(assetId);
    } else {
      _ids.remove(assetId);
    }
  }
}

class MockNotificationRepository implements NotificationRepository {
  final List<AurumNotification> _items = <AurumNotification>[
    AurumNotification(
      id: 'signal-1',
      title: 'BTC context updated',
      body: 'A BTC / USDT analytical signal has refreshed its supporting evidence.',
      kind: NotificationKind.signal,
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
      isRead: false,
    ),
    AurumNotification(
      id: 'price-1',
      title: 'ETH crossed your watch level',
      body: 'Ethereum is now above the price context saved in your watchlist.',
      kind: NotificationKind.price,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AurumNotification(
      id: 'market-1',
      title: 'Market pulse refreshed',
      body: 'The market sentiment source has published an updated reading.',
      kind: NotificationKind.market,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
  ];

  @override
  Future<List<AurumNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 340));
    return List<AurumNotification>.unmodifiable(_items);
  }

  @override
  Future<void> markRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _items.indexWhere((AurumNotification item) => item.id == notificationId);
    if (index != -1) {
      final current = _items[index];
      _items[index] = AurumNotification(
        id: current.id,
        title: current.title,
        body: current.body,
        kind: current.kind,
        createdAt: current.createdAt,
        isRead: true,
      );
    }
  }
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<AurumProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return AurumProfile(
      name: name,
      email: email,
      isGuest: false,
      currency: 'USD',
      reducedMotion: false,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  @override
  Future<AurumProfile> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return AurumProfile(
      name: 'Aurum Analyst',
      email: email,
      isGuest: false,
      currency: 'USD',
      reducedMotion: false,
    );
  }

  @override
  Future<void> signOut() => Future<void>.delayed(const Duration(milliseconds: 180));
}
