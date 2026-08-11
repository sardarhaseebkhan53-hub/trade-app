import 'package:aurum/shared/services/mock_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockMarketRepository', () {
    test('returns a deterministic market list', () async {
      final repository = MockMarketRepository();

      final snapshot = await repository.getMarkets();
      final assets = snapshot.data;

      expect(assets, isNotEmpty);
      expect(snapshot.source, 'Demo mock data');
      expect(assets.first.id, 'bitcoin');
      expect(assets.every((asset) => asset.sparkline.isNotEmpty), isTrue);
    });

    test('filters by asset symbol', () async {
      final repository = MockMarketRepository();

      final assets = (await repository.getMarkets(query: 'eth')).data;

      expect(assets.single.symbol, 'ETH');
    });
  });
}
