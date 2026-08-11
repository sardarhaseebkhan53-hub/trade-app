import 'package:aurum/shared/services/mock_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockMarketRepository', () {
    test('returns a deterministic market list', () async {
      final repository = MockMarketRepository();

      final assets = await repository.getMarkets();

      expect(assets, isNotEmpty);
      expect(assets.first.id, 'bitcoin');
      expect(assets.every((asset) => asset.sparkline.isNotEmpty), isTrue);
    });

    test('filters by asset symbol', () async {
      final repository = MockMarketRepository();

      final assets = await repository.getMarkets(query: 'eth');

      expect(assets.single.symbol, 'ETH');
    });
  });
}
