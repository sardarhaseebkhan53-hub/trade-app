import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/backend_api_exception.dart';
import '../storage/secure_session_store.dart';

class AurumBackendClient {
  AurumBackendClient({
    required AppConfig config,
    required SecureSessionStore sessionStore,
    http.Client? client,
    this.onUnauthorized,
  })  : _baseUri = Uri.parse(config.apiBaseUrl),
        _sessionStore = sessionStore,
        _client = client ?? http.Client(),
        _ownsClient = client == null {
    if (_baseUri.host.isEmpty || (_baseUri.scheme != 'https' && config.environment != 'development')) {
      throw ArgumentError('AURUM backend URL must use HTTPS outside development.');
    }
  }

  final Uri _baseUri;
  final SecureSessionStore _sessionStore;
  final http.Client _client;
  final bool _ownsClient;
  final Future<void> Function()? onUnauthorized;

  Future<Map<String, Object?>> get(String path, {bool authenticated = true}) async =>
      _map(await getValue(path, authenticated: authenticated));

  Future<List<Object?>> getList(String path, {bool authenticated = true}) async =>
      _list(await getValue(path, authenticated: authenticated));

  Future<Map<String, Object?>> post(String path, {Object? body, bool authenticated = true}) async =>
      _map(await postValue(path, body: body, authenticated: authenticated));

  Future<Map<String, Object?>> patch(String path, {Object? body, bool authenticated = true}) async =>
      _map(await patchValue(path, body: body, authenticated: authenticated));

  Future<Map<String, Object?>> delete(String path, {Object? body, bool authenticated = true}) async =>
      _map(await deleteValue(path, body: body, authenticated: authenticated));

  Future<Object?> getValue(String path, {bool authenticated = true}) =>
      _request('GET', path, authenticated: authenticated);

  Future<Object?> postValue(String path, {Object? body, bool authenticated = true}) =>
      _request('POST', path, body: body, authenticated: authenticated);

  Future<Object?> patchValue(String path, {Object? body, bool authenticated = true}) =>
      _request('PATCH', path, body: body, authenticated: authenticated);

  Future<Object?> deleteValue(String path, {Object? body, bool authenticated = true}) =>
      _request('DELETE', path, body: body, authenticated: authenticated);

  Future<Object?> _request(
    String method,
    String path, {
    Object? body,
    required bool authenticated,
  }) async {
    final uri = _baseUri.replace(path: '${_baseUri.path}${path.startsWith('/') ? path : '/$path'}');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated) {
      final tokens = await _sessionStore.readTokens();
      if (tokens == null) throw const BackendUnauthorizedException();
      headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client.send(request).timeout(const Duration(seconds: 12));
      final response = await http.Response.fromStream(streamed);
      final decoded = response.body.isEmpty ? <String, Object?>{} : jsonDecode(response.body);
      final root = decoded is Map ? Map<String, Object?>.from(decoded) : <String, Object?>{};
      if (response.statusCode == 401) {
        await onUnauthorized?.call();
        throw const BackendUnauthorizedException();
      }
      if (response.statusCode < 200 || response.statusCode >= 300 || root['success'] != true) {
        final error = root['error'] is Map ? Map<String, Object?>.from(root['error'] as Map) : <String, Object?>{};
        throw BackendApiException(
          error['code'] as String? ?? 'BACKEND_UNAVAILABLE',
          error['message'] as String? ?? 'Unable to complete this request.',
          statusCode: response.statusCode,
        );
      }
      return root['data'];
    } on TimeoutException {
      throw const BackendApiException('BACKEND_TIMEOUT', 'The server did not respond in time. Please try again.');
    } on http.ClientException {
      throw const BackendApiException('BACKEND_NETWORK', 'Unable to reach AURUM services. Check your connection.');
    } on FormatException {
      throw const BackendApiException('BACKEND_RESPONSE_INVALID', 'The server response could not be read safely.');
    }
  }

  Map<String, Object?> _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : <String, Object?>{};

  List<Object?> _list(Object? value) =>
      value is List ? List<Object?>.from(value) : <Object?>[];

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
