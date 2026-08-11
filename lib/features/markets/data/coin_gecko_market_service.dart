import '../../../core/errors/market_api_exceptions.dart';
import '../../../core/networking/market_api_client.dart';
import '../../../shared/models/market_data_models.dart';

class ServiceResponse<T> {
  const ServiceResponse({required this.data, required this.receivedAt, this.sourceIntervalLabel});
  final T data;
  final DateTime receivedAt;
  final String? sourceIntervalLabel;
}

/// CoinGecko-specific response handling. No widget imports this class.
class CoinGeckoMarketService {
  CoinGeckoMarketService(this._client);
  final MarketApiClient _client;

  Future<ServiceResponse<List<MarketTicker>>> fetchMarkets({
    Iterable<String> ids = const <String>[],
    int page = 1,
    int perPage = 50,
  }) async {
    final payload = await _client.getJson('/coins/markets', query: <String, String>{
      'vs_currency': 'usd',
      'order': 'market_cap_desc',
      'per_page': perPage.clamp(1, 250).toString(),
      'page': page.toString(),
      'sparkline': 'true',
      'price_change_percentage': '24h',
      if (ids.isNotEmpty) 'ids': ids.join(','),
    });
    final values = JsonRead.list(payload.body);
    try {
      final tickers = values
          .map(JsonRead.map)
          .map(MarketTicker.fromCoinGecko)
          .where((MarketTicker ticker) => ticker.asset.id.isNotEmpty)
          .toList(growable: false);
      return ServiceResponse(data: tickers, receivedAt: payload.receivedAt);
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  Future<ServiceResponse<List<CryptoAsset>>> searchAssets(String query) async {
    if (query.trim().isEmpty) return ServiceResponse(data: const <CryptoAsset>[], receivedAt: DateTime.now().toUtc());
    final payload = await _client.getJson('/search', query: <String, String>{'query': query.trim()});
    final root = JsonRead.map(payload.body);
    try {
      final assets = JsonRead.list(root['coins'])
          .map(JsonRead.map)
          .map(CryptoAsset.fromJson)
          .where((CryptoAsset asset) => asset.id.isNotEmpty)
          .take(20)
          .toList(growable: false);
      return ServiceResponse(data: assets, receivedAt: payload.receivedAt);
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  Future<ServiceResponse<MarketOverview>> fetchOverview() async {
    final payload = await _client.getJson('/global');
    try {
      return ServiceResponse(data: MarketOverview.fromCoinGecko(JsonRead.map(payload.body)), receivedAt: payload.receivedAt);
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  Future<ServiceResponse<MarketStats>> fetchStats(String assetId) async {
    final payload = await _client.getJson('/coins/$assetId', query: _detailQuery);
    try {
      return ServiceResponse(data: MarketStats.fromCoinGeckoDetail(JsonRead.map(payload.body)), receivedAt: payload.receivedAt);
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  Future<ServiceResponse<ChartSeries>> fetchChart(String assetId, String timeframe) async {
    final range = CoinGeckoChartRange.forTimeframe(timeframe, DateTime.now().toUtc());
    final payload = await _client.getJson('/coins/$assetId/market_chart/range', query: <String, String>{
      'vs_currency': 'usd',
      'from': (range.from.millisecondsSinceEpoch ~/ 1000).toString(),
      'to': (range.to.millisecondsSinceEpoch ~/ 1000).toString(),
    });
    final root = JsonRead.map(payload.body);
    try {
      final prices = JsonRead.list(root['prices'])
          .map(JsonRead.list)
          .map(HistoricalPrice.fromTuple)
          .toList(growable: false);
      final volumes = JsonRead.list(root['total_volumes'])
          .map(JsonRead.list)
          .map(VolumeData.fromTuple)
          .toList(growable: false);
      return ServiceResponse(
        data: ChartSeries(
          prices: prices,
          volumes: volumes,
          requestedTimeframe: timeframe,
          sourceIntervalLabel: range.sourceIntervalLabel,
        ),
        receivedAt: payload.receivedAt,
        sourceIntervalLabel: range.sourceIntervalLabel,
      );
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  Future<ServiceResponse<List<OHLCData>>> fetchOhlc(String assetId, String timeframe) async {
    final range = CoinGeckoChartRange.forTimeframe(timeframe, DateTime.now().toUtc());
    final payload = await _client.getJson('/coins/$assetId/ohlc', query: <String, String>{
      'vs_currency': 'usd',
      'days': range.ohlcDays.toString(),
    });
    try {
      final candles = JsonRead.list(payload.body)
          .map(JsonRead.list)
          .map(OHLCData.fromTuple)
          .toList(growable: false);
      return ServiceResponse(data: candles, receivedAt: payload.receivedAt, sourceIntervalLabel: 'provider OHLC • ${range.sourceIntervalLabel}');
    } on FormatException catch (error) {
      throw ParsingException(cause: error);
    }
  }

  static const _detailQuery = <String, String>{
    'localization': 'false',
    'tickers': 'false',
    'community_data': 'false',
    'developer_data': 'false',
    'sparkline': 'false',
  };
}

class CoinGeckoChartRange {
  const CoinGeckoChartRange({
    required this.from,
    required this.to,
    required this.sourceIntervalLabel,
    required this.ohlcDays,
  });

  factory CoinGeckoChartRange.forTimeframe(String timeframe, DateTime now) {
    return switch (timeframe) {
      '1H' => CoinGeckoChartRange(from: now.subtract(const Duration(hours: 1)), to: now, sourceIntervalLabel: 'provider-derived intraday', ohlcDays: 1),
      '4H' => CoinGeckoChartRange(from: now.subtract(const Duration(hours: 4)), to: now, sourceIntervalLabel: 'provider-derived intraday', ohlcDays: 1),
      '1D' => CoinGeckoChartRange(from: now.subtract(const Duration(days: 1)), to: now, sourceIntervalLabel: 'provider-derived daily view', ohlcDays: 1),
      '1W' => CoinGeckoChartRange(from: now.subtract(const Duration(days: 7)), to: now, sourceIntervalLabel: 'provider-derived weekly view', ohlcDays: 7),
      '1M' => CoinGeckoChartRange(from: now.subtract(const Duration(days: 30)), to: now, sourceIntervalLabel: 'provider-derived monthly view', ohlcDays: 30),
      _ => CoinGeckoChartRange(from: now.subtract(const Duration(days: 365)), to: now, sourceIntervalLabel: 'provider-derived yearly view', ohlcDays: 365),
    };
  }

  final DateTime from;
  final DateTime to;
  final String sourceIntervalLabel;
  final int ohlcDays;
}
