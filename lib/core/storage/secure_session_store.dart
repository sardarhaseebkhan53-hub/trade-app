import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionTokens {
  const SecureSessionTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

abstract class SecureSessionStore {
  Future<void> writeTokens(SecureSessionTokens tokens);
  Future<SecureSessionTokens?> readTokens();
  Future<void> clear();
}

class FlutterSecureSessionStore implements SecureSessionStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<void> writeTokens(SecureSessionTokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  @override
  Future<SecureSessionTokens?> readTokens() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return SecureSessionTokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
