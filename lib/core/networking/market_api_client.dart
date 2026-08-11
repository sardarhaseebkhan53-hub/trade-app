import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/market_api_exceptions.dart';

class ApiPayload {
  const ApiPayload({required this.body, required this.receivedAt, required this.statusCode});

  final Object? body;
  final DateTime receivedAt;
  final int statusCode;
}

abstract interface class MarketApiClient {
  Future<ApiPayload> getJson(String path, {Map<String, String> query = const <String, String>{}});
}

class HttpMarketApiClient implements MarketApiClient {
  HttpMarketApiClient({
    required AppConfig config,
    http.Client? client,
    DateTime Function()? clock,
  })  : _baseUri = _parseHttps(config.marketApiBaseUrl),
        _apiKey = config.marketApiKey.trim(),
        _enableLogging = config.enableNetworkLogging,
        _client = client ?? http.Client(),
        _ownsClient = client == null,
        _clock = clock ?? DateTime.now;

  final Uri _baseUri;
  final String _apiKey;
  final bool _enableLogging;
  final http.Client _client;
  final bool _ownsClient;
  final DateTime Function() _clock;
  final Map<Uri, Future<ApiPayload>> _inflight = <Uri, Future<ApiPayload>>{};
  DateTime? _rateLimitedUntil;

  static Uri _parseHttps(String raw) {
    final uri = Uri.parse(raw);
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError.value(raw, 'marketApiBaseUrl', 'Market API URLs must use HTTPS.');
    }
    return uri;
  }

  @override
  Future<ApiPayload> getJson(
    String path, {
    Map<String, String> query = const <String, String>{},
  }) {
    final blockedUntil = _rateLimitedUntil;
    if (blockedUntil != null && _clock().isBefore(blockedUntil)) {
      return Future<ApiPayload>.error(
        RateLimitException(retryAfter: blockedUntil.difference(_clock())),
      );
    }
    final uri = _baseUri.replace(
      path: '${_baseUri.path}${path.startsWith('/') ? path : '/$path'}',
      queryParameters: query,
    );
    final active = _inflight[uri];
    if (active != null) return active;

    final request = _performGet(uri);
    _inflight[uri] = request;
    return request.whenComplete(() => _inflight.remove(uri));
  }

  Future<ApiPayload> _performGet(Uri uri) async {
    MarketApiException? lastRecoverable;
    for (var attempt = 0; attempt < 2; attempt++) {
      final started = _clock();
      try {
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 12));
        _log(uri, response.statusCode, _clock().difference(started));
        final status = response.statusCode;
        if (status >= 200 && status < 300) {
          try {
            return ApiPayload(
              body: jsonDecode(response.body),
              receivedAt: _clock().toUtc(),
              statusCode: status,
            );
          } on FormatException catch (error) {
            throw ParsingException(cause: error);
          }
        }
        if (status == 401 || status == 403) throw UnauthorizedException(statusCode: status);
        if (status == 429) {
          final retryAfter = _retryAfter(response.headers['retry-after']);
          _rateLimitedUntil = _clock().add(retryAfter ?? const Duration(seconds: 30));
          throw RateLimitException(retryAfter: retryAfter, statusCode: status);
        }
        if (status >= 500) throw ServerException(statusCode: status);
        throw UnknownApiException(statusCode: status);
      } on TimeoutException catch (error) {
        lastRecoverable = ApiTimeoutException(cause: error);
      } on http.ClientException catch (error) {
        lastRecoverable = NetworkException(cause: error);
      } on SocketException catch (error) {
        lastRecoverable = NetworkException(cause: error);
      } on MarketApiException {
        rethrow;
      } catch (error) {
        throw UnknownApiException(cause: error);
      }
      if (attempt == 0) await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    throw lastRecoverable ?? const UnknownApiException();
  }

  Map<String, String> get _headers => <String, String>{
        'Accept': 'application/json',
        if (_apiKey.isNotEmpty) 'x-cg-demo-api-key': _apiKey,
      };

  Duration? _retryAfter(String? value) {
    final seconds = int.tryParse(value ?? '');
    return seconds == null ? null : Duration(seconds: seconds.clamp(1, 120).toInt());
  }

  void _log(Uri uri, int statusCode, Duration duration) {
    if (kDebugMode && _enableLogging) {
      debugPrint('[AURUM market] GET ${uri.path} → $statusCode in ${duration.inMilliseconds}ms');
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
