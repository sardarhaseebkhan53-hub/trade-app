import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionTokens {
  const SecureSessionTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// OS-backed token boundary. Widgets never read/write token values directly.
abstract interface class SecureSessionStore {
  Future<void> writeTokens(SecureSessionTokens tokens);
  Future<SecureSessionTokens?> readTokens();
  Future<void> clear();
}

class FlutterSecureSessionStore implements SecureSessionStore {
  FlutterSecureSessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessTokenKey = 'aurum_access_token';
  static const _refreshTokenKey = 'aurum_refresh_token';

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<SecureSessionTokens?> readTokens() async {
    final values = await _storage.readAll();
    final accessToken = values[_accessTokenKey];
    final refreshToken = values[_refreshTokenKey];
    if (accessToken == null || refreshToken == null) return null;
    return SecureSessionTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> writeTokens(SecureSessionTokens tokens) {
    return _storage.write(key: _accessTokenKey, value: tokens.accessToken).then(
      (_) => _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    );
  }
}
