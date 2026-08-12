import '../../core/errors/backend_api_exception.dart';
import '../../core/networking/aurum_backend_client.dart';
import '../../core/storage/secure_session_store.dart';
import '../models/market_data_models.dart';
import '../models/market_models.dart';
import '../models/user_data_models.dart';
import 'repositories.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._client, this._store);
  final AurumBackendClient _client;
  final SecureSessionStore _store;

  @override
  Future<AurumProfile> me() async => _profile(await _client.get('/auth/me'));

  @override
  Future<UserSession> register({required String name, required String email, required String password}) async {
    final data = await _client.post('/auth/register', body: <String, Object?>{'name': name, 'email': email, 'password': password}, authenticated: false);
    return _saveSession(data);
  }

  @override
  Future<void> resetPassword({required String token, required String password}) async {
    await _client.post('/auth/reset-password', body: <String, Object?>{'token': token, 'password': password}, authenticated: false);
  }

  @override
  Future<UserSession> signIn({required String email, required String password}) async {
    final data = await _client.post('/auth/login', body: <String, Object?>{'email': email, 'password': password}, authenticated: false);
    return _saveSession(data);
  }

  @override
  Future<UserSession> refresh(String refreshToken) async {
    final sessionData = await _client.post('/auth/refresh', body: <String, Object?>{'refreshToken': refreshToken}, authenticated: false);
    final accessToken = BackendJson.string(sessionData, 'accessToken');
    final nextRefreshToken = BackendJson.string(sessionData, 'refreshToken');
    await _store.writeTokens(SecureSessionTokens(accessToken: accessToken, refreshToken: nextRefreshToken));
    final profile = await me();
    return _session(sessionData, profile);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.post('/auth/forgot-password', body: <String, Object?>{'email': email}, authenticated: false);
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _store.clear();
    }
  }

  @override
  Future<UserSession> signInWithGoogle(String idToken) async {
    final data = await _client.post('/auth/google', body: {'idToken': idToken}, authenticated: false);
    return _saveSession(data);
  }

  Future<UserSession> _saveSession(Map<String, Object?> data) async {
    final profile = _profile(BackendJson.map(data['user']));
    final session = _session(BackendJson.map(data['session']), profile);
    await _store.writeTokens(SecureSessionTokens(accessToken: session.accessToken, refreshToken: session.refreshToken));
    return session;
  }

  UserSession _session(Map<String, Object?> data, AurumProfile profile) => UserSession(
    profile: profile,
    accessToken: BackendJson.string(data, 'accessToken'),
    refreshToken: BackendJson.string(data, 'refreshToken'),
    accessExpiresAt: BackendJson.date(data, 'accessExpiresAt'),
    refreshExpiresAt: BackendJson.date(data, 'refreshExpiresAt'),
  );

  AurumProfile _profile(Map<String, Object?> data) => AurumProfile(
    name: BackendJson.string(data, 'name', fallback: 'AURUM member'),
    email: BackendJson.string(data, 'email'),
    isGuest: false,
    currency: 'USD',
    reducedMotion: false,
  );
}

class RemoteWatchlistRepository implements WatchlistRepository {
  RemoteWatchlistRepository(this._client);
  final AurumBackendClient _client;

  @override
  Future<Set<String>> getAssetIds() async {
    final values = await _client.getList('/watchlist');
    return values
        .map(BackendJson.map)
        .map((Map<String, Object?> item) => BackendJson.string(item, 'assetId'))
        .where((String id) => id.isNotEmpty)
        .toSet();
  }

  @override
  Future<void> setWatched(String assetId, bool isWatched) async {
    if (isWatched) {
      await _client.post('/watchlist', body: <String, Object?>{'assetId': assetId});
    } else {
      await _client.delete('/watchlist/$assetId');
    }
  }
}

class RemoteNotificationRepository implements NotificationRepository {
  RemoteNotificationRepository(this._client);
  final AurumBackendClient _client;

  @override
  Future<List<AurumNotification>> getNotifications() async {
    final page = await _client.get('/notifications');
    final values = page['items'] is List ? List<Object?>.from(page['items'] as List) : <Object?>[];
    return values.map(BackendJson.map).map((Map<String, Object?> item) => AurumNotification(
      id: BackendJson.string(item, 'id'),
      title: BackendJson.string(item, 'title'),
      body: BackendJson.string(item, 'message'),
      kind: _notificationKind(BackendJson.string(item, 'type')),
      createdAt: BackendJson.date(item, 'createdAt'),
      isRead: item['readAt'] != null,
    )).toList(growable: false);
  }

  @override
  Future<void> markRead(String notificationId) async {
    await _client.patch('/notifications/$notificationId/read');
  }

  NotificationKind _notificationKind(String type) => switch (type) {
    'SIGNAL_CREATED' => NotificationKind.signal,
    'SIGNAL_INVALIDATED' => NotificationKind.signal,
    'PRICE_ALERT' => NotificationKind.price,
    'MARKET_MOVEMENT' => NotificationKind.market,
    _ => NotificationKind.system,
  };
}

class RemoteUserRepository implements UserRepository {
  RemoteUserRepository(this._client);
  final AurumBackendClient _client;

  @override
  Future<void> deleteAccount({required String password}) async {
    await _client.delete('/users/me', body: <String, Object?>{'password': password});
  }

  @override
  Future<UserNotificationPreferences> getNotificationPreferences() async => _notificationPreferences(await _client.get('/users/notification-preferences'));

  @override
  Future<UserPreferences> getPreferences() async => _preferences(await _client.get('/users/preferences'));

  @override
  Future<AurumProfile> updateProfile({required String name}) async {
    final data = await _client.patch('/users/me', body: <String, Object?>{'name': name});
    return AurumProfile(name: BackendJson.string(data, 'name'), email: BackendJson.string(data, 'email'), isGuest: false, currency: 'USD', reducedMotion: false);
  }

  @override
  Future<UserNotificationPreferences> updateNotificationPreferences(UserNotificationPreferences preferences) async => _notificationPreferences(await _client.patch('/users/notification-preferences', body: <String, Object?>{
    'signalEnabled': preferences.signalEnabled,
    'priceAlertEnabled': preferences.priceAlertEnabled,
    'marketMovementEnabled': preferences.marketMovementEnabled,
    'aiAnalysisEnabled': preferences.aiAnalysisEnabled,
    'systemEnabled': preferences.systemEnabled,
    'pushEnabled': preferences.pushEnabled,
  }));

  @override
  Future<UserPreferences> updatePreferences(UserPreferences preferences) async => _preferences(await _client.patch('/users/preferences', body: <String, Object?>{
    'quoteCurrency': preferences.quoteCurrency,
    'defaultTimeframe': preferences.defaultTimeframe,
    'theme': preferences.theme,
  }));

  UserPreferences _preferences(Map<String, Object?> data) => UserPreferences(
    quoteCurrency: BackendJson.string(data, 'quoteCurrency', fallback: 'USD'),
    defaultTimeframe: BackendJson.string(data, 'defaultTimeframe', fallback: '1D'),
    theme: BackendJson.string(data, 'theme', fallback: 'system'),
  );

  UserNotificationPreferences _notificationPreferences(Map<String, Object?> data) => UserNotificationPreferences(
    signalEnabled: BackendJson.boolean(data, 'signalEnabled', fallback: true),
    priceAlertEnabled: BackendJson.boolean(data, 'priceAlertEnabled', fallback: true),
    marketMovementEnabled: BackendJson.boolean(data, 'marketMovementEnabled'),
    aiAnalysisEnabled: BackendJson.boolean(data, 'aiAnalysisEnabled'),
    systemEnabled: BackendJson.boolean(data, 'systemEnabled', fallback: true),
    pushEnabled: BackendJson.boolean(data, 'pushEnabled'),
  );
}

class RemoteAlertRepository implements AlertRepository {
  RemoteAlertRepository(this._client);
  final AurumBackendClient _client;

  @override
  Future<PriceAlert> createAlert({required String assetId, required AlertCondition condition, required double targetPrice}) async =>
      _alert(await _client.post('/alerts', body: <String, Object?>{'assetId': assetId, 'condition': condition.name.toUpperCase(), 'targetPrice': targetPrice}));

  @override
  Future<void> deleteAlert(String id) async {
    await _client.delete('/alerts/$id');
  }

  @override
  Future<List<PriceAlert>> getAlerts() async => _client.getList('/alerts').then((List<Object?> values) => values.map(BackendJson.map).map(_alert).toList(growable: false));

  @override
  Future<void> updateAlert({required String id, AlertCondition? condition, double? targetPrice, bool? active}) async {
    await _client.patch('/alerts/$id', body: <String, Object?>{
      if (condition != null) 'condition': condition.name.toUpperCase(),
      if (targetPrice != null) 'targetPrice': targetPrice,
      if (active != null) 'active': active,
    });
  }

  PriceAlert _alert(Map<String, Object?> data) => PriceAlert(
    id: BackendJson.string(data, 'id'),
    assetId: BackendJson.string(data, 'assetId'),
    condition: BackendJson.string(data, 'condition') == 'BELOW' ? AlertCondition.below : AlertCondition.above,
    targetPrice: BackendJson.decimal(data, 'targetPrice'),
    status: switch (BackendJson.string(data, 'status')) {
      'TRIGGERED' => AlertStatus.triggered,
      'PAUSED' => AlertStatus.paused,
      'CANCELLED' => AlertStatus.cancelled,
      _ => AlertStatus.active,
    },
    createdAt: BackendJson.date(data, 'createdAt'),
  );
}
