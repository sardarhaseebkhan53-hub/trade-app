import 'dart:async';
import 'dart:convert';

import 'package:aurum/core/config/app_config.dart';
import 'package:aurum/core/errors/market_api_exceptions.dart';
import 'package:aurum/core/networking/market_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  AppConfig config({bool logging = false}) => AppConfig(
        environment: 'test',
        apiBaseUrl: 'https://api.example.invalid',
        enableTelemetry: false,
        backendMode: BackendMode.mock,
        marketDataMode: MarketDataMode.remote,
        marketProvider: 'coingecko',
        marketApiBaseUrl: 'https://market.example.test/api/v3',
        marketApiKey: '',
        enableNetworkLogging: logging,
      );

  test('client decodes a successful JSON response', () async {
    final client = HttpMarketApiClient(
      config: config(),
      client: MockClient((http.Request request) async {
        expect(request.url.path, '/api/v3/global');
        return http.Response(jsonEncode(<String, Object?>{'data': <String, Object?>{'ok': true}}), 200);
      }),
    );

    final payload = await client.getJson('/global');

    expect(payload.statusCode, 200);
    expect(payload.body, isA<Map<String, dynamic>>());
  });

  test('client maps HTTP 429 to a rate-limit exception', () async {
    final client = HttpMarketApiClient(
      config: config(),
      client: MockClient((_) async => http.Response('', 429, headers: <String, String>{'retry-after': '7'})),
    );

    expect(client.getJson('/global'), throwsA(isA<RateLimitException>()));
  });

  test('client maps 5xx to a server exception', () async {
    final client = HttpMarketApiClient(
      config: config(),
      client: MockClient((_) async => http.Response('', 503)),
    );

    expect(client.getJson('/global'), throwsA(isA<ServerException>()));
  });

  test('client maps a timeout to a typed timeout exception', () async {
    final client = HttpMarketApiClient(
      config: config(),
      client: MockClient((_) => Future<http.Response>.error(TimeoutException('timed out'))),
    );

    expect(client.getJson('/global'), throwsA(isA<ApiTimeoutException>()));
  });
}
