class MarketSnapshot<T> {
  const MarketSnapshot({
    required this.data,
    required this.asOf,
    required this.source,
    required this.isCached,
    required this.isStale,
    this.sourceIntervalLabel,
  });

  final T data;
  final DateTime asOf;
  final String source;
  final bool isCached;
  final bool isStale;
  final String? sourceIntervalLabel;

  String get freshnessLabel {
    if (isStale) return 'Cached • update unavailable';
    if (isCached) return 'Cached';
    return 'Updated';
  }

  MarketSnapshot<R> map<R>(R Function(T value) mapper) => MarketSnapshot<R>(
        data: mapper(data),
        asOf: asOf,
        source: source,
        isCached: isCached,
        isStale: isStale,
        sourceIntervalLabel: sourceIntervalLabel,
      );
}

class CryptoAsset {
  const CryptoAsset({
    required this.id,
    required this.name,
    required this.symbol,
    this.rank,
    this.imageUrl,
  });

  factory CryptoAsset.fromJson(Map<String, Object?> json) => CryptoAsset(
        id: JsonRead.string(json['id']) ?? '',
        name: JsonRead.string(json['name']) ?? 'Unknown asset',
        symbol: (JsonRead.string(json['symbol']) ?? '—').toUpperCase(),
        rank: JsonRead.integer(json['market_cap_rank']),
        imageUrl: JsonRead.string(json['large']) ?? JsonRead.string(json['thumb']),
      );

  final String id;
  final String name;
  final String symbol;
  final int? rank;
  final String? imageUrl;
}

class MarketTicker {
  const MarketTicker({
    required this.asset,
    required this.priceUsd,
    required this.change24h,
    required this.marketCapUsd,
    required this.volume24hUsd,
    required this.high24h,
    required this.low24h,
    required this.lastUpdated,
    required this.sparkline,
  });

  factory MarketTicker.fromCoinGecko(Map<String, Object?> json) {
    final asset = CryptoAsset(
      id: JsonRead.string(json['id']) ?? '',
      name: JsonRead.string(json['name']) ?? 'Unknown asset',
      symbol: (JsonRead.string(json['symbol']) ?? '—').toUpperCase(),
      rank: JsonRead.integer(json['market_cap_rank']),
      imageUrl: JsonRead.string(json['image']),
    );
    return MarketTicker(
      asset: asset,
      priceUsd: JsonRead.decimal(json['current_price']) ?? 0,
      change24h: JsonRead.decimal(json['price_change_percentage_24h']) ?? 0,
      marketCapUsd: JsonRead.decimal(json['market_cap']) ?? 0,
      volume24hUsd: JsonRead.decimal(json['total_volume']) ?? 0,
      high24h: JsonRead.decimal(json['high_24h']),
      low24h: JsonRead.decimal(json['low_24h']),
      lastUpdated: JsonRead.dateTime(json['last_updated']) ?? DateTime.now().toUtc(),
      sparkline: JsonRead.numberListFromMap(json['sparkline_in_7d'], 'price'),
    );
  }

  final CryptoAsset asset;
  final double priceUsd;
  final double change24h;
  final double marketCapUsd;
  final double volume24hUsd;
  final double? high24h;
  final double? low24h;
  final DateTime lastUpdated;
  final List<double> sparkline;
}

class MarketOverview {
  const MarketOverview({
    required this.totalMarketCapUsd,
    required this.totalVolumeUsd,
    required this.marketCapChange24h,
    required this.btcDominance,
    required this.activeCryptocurrencies,
    required this.updatedAt,
  });

  factory MarketOverview.fromCoinGecko(Map<String, Object?> json) {
    final data = JsonRead.map(json['data']);
    return MarketOverview(
      totalMarketCapUsd: JsonRead.currencyValue(data['total_market_cap'], 'usd') ?? 0,
      totalVolumeUsd: JsonRead.currencyValue(data['total_volume'], 'usd') ?? 0,
      marketCapChange24h: JsonRead.decimal(data['market_cap_change_percentage_24h_usd']) ?? 0,
      btcDominance: JsonRead.decimal(JsonRead.map(data['market_cap_percentage'])['btc']) ?? 0,
      activeCryptocurrencies: JsonRead.integer(data['active_cryptocurrencies']) ?? 0,
      updatedAt: JsonRead.unixSeconds(data['updated_at']) ?? DateTime.now().toUtc(),
    );
  }

  final double totalMarketCapUsd;
  final double totalVolumeUsd;
  final double marketCapChange24h;
  final double btcDominance;
  final int activeCryptocurrencies;
  final DateTime updatedAt;
}

class MarketStats {
  const MarketStats({
    required this.marketCapUsd,
    required this.volume24hUsd,
    required this.high24h,
    required this.low24h,
    required this.circulatingSupply,
    required this.allTimeHigh,
  });

  factory MarketStats.fromCoinGeckoDetail(Map<String, Object?> json) {
    final data = JsonRead.map(json['market_data']);
    return MarketStats(
      marketCapUsd: JsonRead.currencyValue(data['market_cap'], 'usd'),
      volume24hUsd: JsonRead.currencyValue(data['total_volume'], 'usd'),
      high24h: JsonRead.currencyValue(data['high_24h'], 'usd'),
      low24h: JsonRead.currencyValue(data['low_24h'], 'usd'),
      circulatingSupply: JsonRead.decimal(data['circulating_supply']),
      allTimeHigh: JsonRead.currencyValue(data['ath'], 'usd'),
    );
  }

  final double? marketCapUsd;
  final double? volume24hUsd;
  final double? high24h;
  final double? low24h;
  final double? circulatingSupply;
  final double? allTimeHigh;
}

class HistoricalPrice {
  const HistoricalPrice({required this.timestamp, required this.priceUsd});

  factory HistoricalPrice.fromTuple(List<Object?> tuple) {
    if (tuple.length < 2) throw const FormatException('Price tuple is incomplete.');
    final timestamp = JsonRead.unixMilliseconds(tuple[0]);
    final value = JsonRead.decimal(tuple[1]);
    if (timestamp == null || value == null) throw const FormatException('Price tuple is invalid.');
    return HistoricalPrice(timestamp: timestamp, priceUsd: value);
  }

  final DateTime timestamp;
  final double priceUsd;
}

class VolumeData {
  const VolumeData({required this.timestamp, required this.volumeUsd});

  factory VolumeData.fromTuple(List<Object?> tuple) {
    if (tuple.length < 2) throw const FormatException('Volume tuple is incomplete.');
    final timestamp = JsonRead.unixMilliseconds(tuple[0]);
    final value = JsonRead.decimal(tuple[1]);
    if (timestamp == null || value == null) throw const FormatException('Volume tuple is invalid.');
    return VolumeData(timestamp: timestamp, volumeUsd: value);
  }

  final DateTime timestamp;
  final double volumeUsd;
}

class OHLCData {
  const OHLCData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  factory OHLCData.fromTuple(List<Object?> tuple) {
    if (tuple.length < 5) throw const FormatException('OHLC tuple is incomplete.');
    final timestamp = JsonRead.unixMilliseconds(tuple[0]);
    final open = JsonRead.decimal(tuple[1]);
    final high = JsonRead.decimal(tuple[2]);
    final low = JsonRead.decimal(tuple[3]);
    final close = JsonRead.decimal(tuple[4]);
    if (timestamp == null || open == null || high == null || low == null || close == null) {
      throw const FormatException('OHLC tuple is invalid.');
    }
    return OHLCData(timestamp: timestamp, open: open, high: high, low: low, close: close, volume: tuple.length > 5 ? JsonRead.decimal(tuple[5]) : null);
  }

  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
}

class ChartSeries {
  const ChartSeries({
    required this.prices,
    required this.volumes,
    required this.sourceIntervalLabel,
    required this.requestedTimeframe,
  });

  final List<HistoricalPrice> prices;
  final List<VolumeData> volumes;
  final String sourceIntervalLabel;
  final String requestedTimeframe;

  List<double> get closeValues => prices.map((HistoricalPrice point) => point.priceUsd).toList(growable: false);
}

abstract final class JsonRead {
  static Map<String, Object?> map(Object? value) {
    if (value is Map) return Map<String, Object?>.from(value);
    return <String, Object?>{};
  }

  static List<Object?> list(Object? value) => value is List ? List<Object?>.from(value) : <Object?>[];

  static String? string(Object? value) => value is String && value.trim().isNotEmpty ? value : null;

  static double? decimal(Object? value) {
    if (value is num && value.isFinite) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? integer(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? dateTime(Object? value) {
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }

  static DateTime? unixSeconds(Object? value) {
    final seconds = decimal(value);
    return seconds == null ? null : DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round(), isUtc: true);
  }

  static DateTime? unixMilliseconds(Object? value) {
    final milliseconds = decimal(value);
    return milliseconds == null ? null : DateTime.fromMillisecondsSinceEpoch(milliseconds.round(), isUtc: true);
  }

  static double? currencyValue(Object? value, String currency) {
    if (value is Map) return decimal(value[currency]);
    return null;
  }

  static List<double> numberListFromMap(Object? value, String key) {
    if (value is! Map) return const <double>[];
    return list(value[key]).map(decimal).whereType<double>().toList(growable: false);
  }
}
