import 'package:flutter_test/flutter_test.dart';
import 'package:aurum/features/markets/data/mock_market_repository.dart';

void main() {
  group('MockMarketRepository', () {
    final repo = MockMarketRepository();

    test('returns featured assets', () async {
      final snap = await repo.getFeaturedAssets();
      expect(snap.data.length, greaterThanOrEqualTo(1));
      expect(snap.data.first.symbol, isNotEmpty);
    });

    test('filters markets by query', () async {
      final results = await repo.getMarkets(query: 'eth');
      expect(results.data.any((a) => a.symbol == 'ETH'), isTrue);
    });

    test('provides chart data', () async {
      final chart = await repo.getChart('bitcoin', '1D');
      expect(chart.data.prices.length, greaterThan(5));
    });
  });
}
