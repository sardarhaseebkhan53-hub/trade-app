import 'market_data_models.dart';
import 'market_models.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, sessionExpired, loggingOut }

enum AlertCondition { above, below }

enum AlertStatus { active, triggered, paused, cancelled }

class UserSession {
  const UserSession({
    required this.profile,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final AurumProfile profile;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;
}

class AuthState {
  const AuthState({required this.status, this.profile, this.expiresAt});
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AurumProfile? profile;
  final DateTime? expiresAt;

  bool get isAuthenticated => status == AuthStatus.authenticated && profile != null;
}

class UserPreferences {
  const UserPreferences({
    required this.quoteCurrency,
    required this.defaultTimeframe,
    required this.theme,
  });

  final String quoteCurrency;
  final String defaultTimeframe;
  final String theme;
}

class UserNotificationPreferences {
  const UserNotificationPreferences({
    required this.signalEnabled,
    required this.priceAlertEnabled,
    required this.marketMovementEnabled,
    required this.aiAnalysisEnabled,
    required this.systemEnabled,
    required this.pushEnabled,
  });

  final bool signalEnabled;
  final bool priceAlertEnabled;
  final bool marketMovementEnabled;
  final bool aiAnalysisEnabled;
  final bool systemEnabled;
  final bool pushEnabled;
}

class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.assetId,
    required this.condition,
    required this.targetPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String assetId;
  final AlertCondition condition;
  final double targetPrice;
  final AlertStatus status;
  final DateTime createdAt;
}

class BackendNotification {
  const BackendNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.kind,
    required this.createdAt,
    required this.readAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationKind kind;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;
}

abstract final class BackendJson {
  static Map<String, Object?> map(Object? value) => JsonRead.map(value);
  static String string(Map<String, Object?> value, String key, {String fallback = ''}) =>
      JsonRead.string(value[key]) ?? fallback;
  static DateTime date(Map<String, Object?> value, String key) =>
      JsonRead.dateTime(value[key]) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  static bool boolean(Map<String, Object?> value, String key, {bool fallback = false}) =>
      value[key] is bool ? value[key] as bool : fallback;
  static double decimal(Map<String, Object?> value, String key, {double fallback = 0}) =>
      JsonRead.decimal(value[key]) ?? fallback;
}
