import 'package:aurum/shared/models/market_data_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketTicker', () {
    test('parses numeric strings, null optional fields and sparkline safely', () {
      final ticker = MarketTicker.fromCoinGecko(<String, Object?>{
        'id': 'bitcoin',
        'name': 'Bitcoin',
        'symbol': 'btc',
        'market_cap_rank': '1',
        'current_price': '68420.50',
        'price_change_percentage_24h': 3.42,
        'market_cap': '1350000000000',
        'total_volume': 24800000000,
        'high_24h': null,
        'low_24h': '66000',
        'last_updated': '2026-08-11T10:00:00.000Z',
        'sparkline_in_7d': <String, Object?>{'price': <Object?>[1, '2.5', null, 'not-a-number']},
      });

      expect(ticker.asset.symbol, 'BTC');
      expect(ticker.asset.rank, 1);
      expect(ticker.priceUsd, 68420.50);
      expect(ticker.high24h, isNull);
      expect(ticker.low24h, 66000);
      expect(ticker.sparkline, <double>[1, 2.5]);
    });
  });

  group('chart values', () {
    test('parses timestamp tuples and rejects incomplete tuples', () {
      final point = HistoricalPrice.fromTuple(<Object?>[1723370400000, '68420.5']);

      expect(point.timestamp.isUtc, isTrue);
      expect(point.priceUsd, 68420.5);
      expect(() => HistoricalPrice.fromTuple(<Object?>[1723370400000]), throwsFormatException);
    });

    test('parses OHLC without requiring volume', () {
      final candle = OHLCData.fromTuple(<Object?>[1723370400000, '10', 12, 9, 11]);

      expect(candle.open, 10);
      expect(candle.close, 11);
      expect(candle.volume, isNull);
    });
  });

  test('market overview tolerates absent nested maps', () {
    final overview = MarketOverview.fromCoinGecko(<String, Object?>{'data': <String, Object?>{}});

    expect(overview.totalMarketCapUsd, 0);
    expect(overview.btcDominance, 0);
  });
}
