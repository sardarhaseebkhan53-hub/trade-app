import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small boundary so session storage can be replaced or faked without touching UI.
abstract interface class SecureSessionStore {
  Future<void> writeAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> clear();
}

class FlutterSecureSessionStore implements SecureSessionStore {
  FlutterSecureSessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'aurum_access_token';

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);

  @override
  Future<String?> readAccessToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
}
