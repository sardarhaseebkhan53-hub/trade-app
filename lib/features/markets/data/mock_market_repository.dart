import 'package:flutter/material.dart';

import '../../../domain/market_entities.dart';
import '../../../shared/models/market_data_models.dart';
import '../data/market_memory_cache.dart';
import '../../shared/services/repositories.dart';

/// Simple high-quality mock for development and testing
class MockMarketRepository implements MarketRepository {
  static const _latency = Duration(milliseconds: 280);

  static final List<Asset> _assets = [
    Asset(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 68420.50,
      change24h: 3.42,
      volume: 24.8e9,
      marketCap: 1.35e12,
      rank: 1,
      sparkline: [44, 47, 45, 50, 49, 54, 53, 58, 57, 62, 65, 67],
      iconColor: const Color(0xFFF7931A),
    ),
    Asset(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      price: 3012.18,
      change24h: 2.11,
      volume: 15.2e9,
      marketCap: 362e9,
      rank: 2,
      sparkline: [50, 49, 52, 51, 54, 56, 55, 58, 59, 62, 61, 66],
      iconColor: const Color(0xFF7A88D1),
    ),
    Asset(
      id: 'solana',
      symbol: 'SOL',
      name: 'Solana',
      price: 153.67,
      change24h: -1.23,
      volume: 4.6e9,
      marketCap: 72e9,
      rank: 3,
      sparkline: [65, 62, 63, 61, 58, 56, 57, 54, 55, 51, 50, 48],
      iconColor: const Color(0xFF8A64E8),
    ),
    Asset(
      id: 'bnb',
      symbol: 'BNB',
      name: 'BNB',
      price: 595.04,
      change24h: 0.83,
      volume: 1.98e9,
      marketCap: 87e9,
      rank: 4,
      sparkline: [38, 40, 39, 41, 42, 44, 43, 46, 45, 47, 48, 49],
    ),
    Asset(
      id: 'xrp',
      symbol: 'XRP',
      name: 'XRP',
      price: 0.5187,
      change24h: -0.62,
      volume: 1.6e9,
      marketCap: 29e9,
      rank: 5,
      sparkline: [59, 61, 60, 58, 59, 57, 56, 54, 55, 52, 51, 50],
    ),
  ];

  @override
  Future<MarketSnapshot<List<Asset>>> getMarkets({String query = ''}) async {
    await Future.delayed(_latency);
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _assets
        : _assets.where((a) => a.name.toLowerCase().contains(q) || a.symbol.toLowerCase().contains(q)).toList();
    return _snapshot(filtered);
  }

  @override
  Future<MarketSnapshot<List<Asset>>> getFeaturedAssets() async {
    await Future.delayed(_latency);
    return _snapshot(_assets.take(3).toList());
  }

  @override
  Future<MarketSnapshot<List<Asset>>> getAssetsByIds(Iterable<String> ids) async {
    await Future.delayed(_latency);
    final set = ids.toSet();
    return _snapshot(_assets.where((a) => set.contains(a.id)).toList());
  }

  @override
  Future<MarketSnapshot<Asset>> getAsset(String assetId) async {
    await Future.delayed(_latency);
    final asset = _assets.firstWhere((a) => a.id == assetId, orElse: () => _assets.first);
    return MarketSnapshot<Asset>(
      data: asset,
      asOf: DateTime.now().toUtc(),
      source: 'Mock',
      isCached: false,
      isStale: false,
    );
  }

  @override
  Future<MarketSnapshot<MarketOverview>> getOverview() async {
    await Future.delayed(_latency);
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
    await Future.delayed(_latency);
    final asset = (await getAsset(assetId)).data;
    return _snapshot(AssetStatistics(
      marketCap: asset.marketCap,
      volume24h: asset.volume,
      dayHigh: asset.price * 1.028,
      dayLow: asset.price * 0.967,
      circulatingSupply: asset.id == 'bitcoin' ? '19.8M' : '—',
      allTimeHigh: asset.id == 'bitcoin' ? 73750.07 : asset.price * 1.45,
    ));
  }

  @override
  Future<MarketSnapshot<List<ChartPoint>>> getChart(String assetId, String timeframe) async {
    await Future.delayed(const Duration(milliseconds: 420));
    final base = (await getAsset(assetId)).data;
    final multiplier = switch (timeframe) {
      '1H' => 0.55,
      '4H' => 0.7,
      '1D' => 1.0,
      '1W' => 1.35,
      _ => 1.75,
    };
    final now = DateTime.now().toUtc();
    final points = List.generate(base.sparkline.length, (i) {
      return ChartPoint(
        timestamp: now.subtract(Duration(minutes: (base.sparkline.length - i) * 8)),
        price: base.sparkline[i] * multiplier,
      );
    });
    return MarketSnapshot(
      data: points,
      asOf: now,
      source: 'Mock',
      isCached: false,
      isStale: false,
    );
  }

  MarketSnapshot<T> _snapshot<T>(T data) => MarketSnapshot<T>(
        data: data,
        asOf: DateTime.now().toUtc(),
        source: 'Mock Data',
        isCached: false,
        isStale: false,
      );
}
