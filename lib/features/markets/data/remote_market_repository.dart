import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../shared/models/market_data_models.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/repositories.dart';
import 'coin_gecko_market_service.dart';
import 'market_memory_cache.dart';

/// Provider-neutral repository. CoinGecko response details remain in the service.
class RemoteMarketRepository implements MarketRepository {
  RemoteMarketRepository({
    required CoinGeckoMarketService service,
    MarketMemoryCache? cache,
    DateTime Function()? clock,
  })  : _service = service,
        _cache = cache ?? MarketMemoryCache(),
        _clock = clock ?? DateTime.now;

  final CoinGeckoMarketService _service;
  final MarketMemoryCache _cache;
  final DateTime Function() _clock;
  static const _source = 'CoinGecko';

  @override
  Future<MarketSnapshot<MarketAsset>> getAsset(String assetId) async {
    final assets = await getAssetsByIds(<String>[assetId]);
    if (assets.data.isEmpty) throw const ServiceFailure('This asset is not currently available.');
    return assets.map((List<MarketAsset> values) => values.first);
  }

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getAssetsByIds(Iterable<String> assetIds) {
    final ids = assetIds.where((String id) => id.trim().isNotEmpty).toSet().toList()..sort();
    if (ids.isEmpty) {
      return Future<MarketSnapshot<List<MarketAsset>>>.value(_emptySnapshot());
    }
    return _load(
      key: 'assets:${ids.join(',')}',
      ttl: const Duration(seconds: 30),
      loader: () async {
        final response = await _service.fetchMarkets(ids: ids, perPage: ids.length);
        return ServiceResponse(
          data: response.data.map(_toMarketAsset).toList(growable: false),
          receivedAt: response.receivedAt,
        );
      },
    );
  }

  @override
  Future<MarketSnapshot<ChartSeries>> getChart(String assetId, String timeframe) => _load(
        key: 'chart:$assetId:$timeframe',
        ttl: const Duration(minutes: 5),
        loader: () => _service.fetchChart(assetId, timeframe),
      );

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getFeaturedAssets() => _load(
        key: 'featured',
        ttl: const Duration(seconds: 60),
        loader: () async {
          final response = await _service.fetchMarkets(perPage: 3);
          return ServiceResponse(
            data: response.data.map(_toMarketAsset).toList(growable: false),
            receivedAt: response.receivedAt,
          );
        },
      );

  @override
  Future<List<TechnicalIndicator>> getIndicators(String assetId) {
    // Technical calculation and indicator provenance are Phase 5 responsibilities.
    throw const ServiceFailure('Technical indicators will be available in Phase 5.');
  }

  @override
  Future<MarketSnapshot<List<MarketAsset>>> getMarkets({String query = ''}) {
    final normalized = query.trim().toLowerCase();
    return _load(
      key: normalized.isEmpty ? 'markets:top' : 'markets:search:$normalized',
      ttl: normalized.isEmpty ? const Duration(seconds: 60) : const Duration(seconds: 90),
      loader: () async {
        if (normalized.isEmpty) {
          final response = await _service.fetchMarkets(perPage: 50);
          return ServiceResponse(
            data: response.data.map(_toMarketAsset).toList(growable: false),
            receivedAt: response.receivedAt,
          );
        }
        final search = await _service.searchAssets(normalized);
        if (search.data.isEmpty) return ServiceResponse(data: const <MarketAsset>[], receivedAt: search.receivedAt);
        final quotes = await _service.fetchMarkets(ids: search.data.map((CryptoAsset item) => item.id), perPage: search.data.length);
        return ServiceResponse(
          data: quotes.data.map(_toMarketAsset).toList(growable: false),
          receivedAt: quotes.receivedAt,
        );
      },
    );
  }

  @override
  Future<MarketSnapshot<List<OHLCData>>> getOhlc(String assetId, String timeframe) => _load(
        key: 'ohlc:$assetId:$timeframe',
        ttl: const Duration(minutes: 15),
        loader: () => _service.fetchOhlc(assetId, timeframe),
      );

  @override
  Future<MarketSnapshot<MarketOverview>> getOverview() => _load(
        key: 'overview',
        ttl: const Duration(seconds: 60),
        loader: _service.fetchOverview,
      );

  @override
  Future<MarketSnapshot<AssetStatistics>> getStatistics(String assetId) => _load(
        key: 'stats:$assetId',
        ttl: const Duration(minutes: 5),
        loader: () async {
          final response = await _service.fetchStats(assetId);
          return ServiceResponse(data: _toStatistics(response.data), receivedAt: response.receivedAt);
        },
      );

  Future<MarketSnapshot<T>> _load<T>({
    required String key,
    required Duration ttl,
    required Future<ServiceResponse<T>> Function() loader,
  }) async {
    final now = _clock().toUtc();
    final fresh = _cache.readFresh<T>(key, ttl, now);
    final freshAt = _cache.savedAt(key);
    if (fresh != null && freshAt != null) {
      return MarketSnapshot(data: fresh, asOf: freshAt, source: _source, isCached: true, isStale: false);
    }
    try {
      final response = await loader();
      _cache.write<T>(key, response.data, response.receivedAt);
      return MarketSnapshot(
        data: response.data,
        asOf: response.receivedAt,
        source: _source,
        isCached: false,
        isStale: false,
        sourceIntervalLabel: response.sourceIntervalLabel,
      );
    } catch (_) {
      final stale = _cache.readAny<T>(key);
      final staleAt = _cache.savedAt(key);
      if (stale != null && staleAt != null) {
        return MarketSnapshot(data: stale, asOf: staleAt, source: _source, isCached: true, isStale: true);
      }
      rethrow;
    }
  }

  MarketSnapshot<List<MarketAsset>> _emptySnapshot() => MarketSnapshot(
        data: const <MarketAsset>[],
        asOf: _clock().toUtc(),
        source: _source,
        isCached: false,
        isStale: false,
      );

  MarketAsset _toMarketAsset(MarketTicker ticker) => MarketAsset(
        id: ticker.asset.id,
        rank: ticker.asset.rank ?? 0,
        name: ticker.asset.name,
        symbol: ticker.asset.symbol,
        price: ticker.priceUsd,
        change24h: ticker.change24h,
        volume: ticker.volume24hUsd,
        marketCap: ticker.marketCapUsd,
        iconColor: _assetColor(ticker.asset.id),
        sparkline: ticker.sparkline,
        description: 'Market data from $_source.',
      );

  AssetStatistics _toStatistics(MarketStats stats) => AssetStatistics(
        marketCap: stats.marketCapUsd,
        volume24h: stats.volume24hUsd,
        dayHigh: stats.high24h,
        dayLow: stats.low24h,
        circulatingSupply: stats.circulatingSupply == null ? 'Unavailable' : _supply(stats.circulatingSupply!),
        allTimeHigh: stats.allTimeHigh,
      );

  String _supply(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    return value.toStringAsFixed(0);
  }

  Color _assetColor(String id) {
    final seed = id.codeUnits.fold<int>(0, (int value, int code) => (value + code) % 360);
    return HSLColor.fromAHSL(1, seed.toDouble(), 0.62, 0.52).toColor();
  }
}
