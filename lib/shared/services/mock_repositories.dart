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
