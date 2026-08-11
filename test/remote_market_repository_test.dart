import 'package:aurum/core/networking/market_api_client.dart';
import 'package:aurum/features/markets/data/coin_gecko_market_service.dart';
import 'package:aurum/features/markets/data/remote_market_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote repository maps a provider list and serves a fresh cache', () async {
    final client = _FakeMarketApiClient();
    final repository = RemoteMarketRepository(service: CoinGeckoMarketService(client));

    final first = await repository.getMarkets();
    final second = await repository.getMarkets();

    expect(first.data.single.name, 'Bitcoin');
    expect(first.isCached, isFalse);
    expect(second.isCached, isTrue);
    expect(client.marketRequests, 1);
  });

  test('remote repository returns only requested watchlist assets', () async {
    final repository = RemoteMarketRepository(service: CoinGeckoMarketService(_FakeMarketApiClient()));

    final snapshot = await repository.getAssetsByIds(<String>['bitcoin']);

    expect(snapshot.data.map((asset) => asset.id), <String>['bitcoin']);
  });
}

class _FakeMarketApiClient implements MarketApiClient {
  var marketRequests = 0;

  @override
  Future<ApiPayload> getJson(String path, {Map<String, String> query = const <String, String>{}}) async {
    if (path == '/coins/markets') {
      marketRequests++;
      return ApiPayload(
        statusCode: 200,
        receivedAt: DateTime.now().toUtc(),
        body: <Object?>[
          <String, Object?>{
            'id': 'bitcoin',
            'name': 'Bitcoin',
            'symbol': 'btc',
            'market_cap_rank': 1,
            'current_price': 68420.5,
            'price_change_percentage_24h': 3.42,
            'market_cap': 1350000000000,
            'total_volume': 24800000000,
            'high_24h': 69000,
            'low_24h': 66000,
            'last_updated': '2026-08-11T00:00:00.000Z',
            'sparkline_in_7d': <String, Object?>{'price': <Object?>[1, 2, 3]},
          },
        ],
      );
    }
    throw StateError('Unexpected path: $path');
  }
}
