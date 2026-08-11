import 'dart:convert';

import 'package:aurum/core/config/app_config.dart';
import 'package:aurum/core/errors/backend_api_exception.dart';
import 'package:aurum/core/networking/aurum_backend_client.dart';
import 'package:aurum/core/storage/secure_session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  AppConfig config() => AppConfig(
        environment: 'test',
        apiBaseUrl: 'https://api.example.test',
        enableTelemetry: false,
        backendMode: BackendMode.remote,
        marketDataMode: MarketDataMode.mock,
        marketProvider: 'coingecko',
        marketApiBaseUrl: 'https://market.example.test',
        marketApiKey: '',
        enableNetworkLogging: false,
      );

  test('backend client sends an opaque bearer token and unwraps success data', () async {
    final store = _MemoryStore(const SecureSessionTokens(accessToken: 'access-token', refreshToken: 'refresh-token'));
    final client = AurumBackendClient(
      config: config(),
      sessionStore: store,
      client: MockClient((http.Request request) async {
        expect(request.headers['authorization'], 'Bearer access-token');
        return http.Response(jsonEncode(<String, Object?>{'success': true, 'data': <String, Object?>{'name': 'Aurum User'}}), 200);
      }),
    );

    final response = await client.get('/auth/me');

    expect(response['name'], 'Aurum User');
  });

  test('backend client converts a session-expired response into a typed failure', () async {
    final store = _MemoryStore(const SecureSessionTokens(accessToken: 'access-token', refreshToken: 'refresh-token'));
    final client = AurumBackendClient(
      config: config(),
      sessionStore: store,
      client: MockClient((_) async => http.Response(jsonEncode(<String, Object?>{'success': false, 'error': <String, String>{'code': 'AUTH_SESSION_EXPIRED', 'message': 'expired'}}), 401)),
    );

    expect(client.get('/watchlist'), throwsA(isA<BackendUnauthorizedException>()));
  });
}

class _MemoryStore implements SecureSessionStore {
  _MemoryStore(this.tokens);
  SecureSessionTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<SecureSessionTokens?> readTokens() async => tokens;

  @override
  Future<void> writeTokens(SecureSessionTokens value) async => tokens = value;
}
