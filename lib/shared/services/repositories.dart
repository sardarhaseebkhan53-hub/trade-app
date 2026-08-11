import '../models/market_data_models.dart';
import '../models/market_models.dart';
import '../models/user_data_models.dart';

abstract interface class MarketRepository {
  Future<MarketSnapshot<List<MarketAsset>>> getMarkets({String query = ''});
  Future<MarketSnapshot<List<MarketAsset>>> getFeaturedAssets();
  Future<MarketSnapshot<List<MarketAsset>>> getAssetsByIds(Iterable<String> assetIds);
  Future<MarketSnapshot<MarketAsset>> getAsset(String assetId);
  Future<MarketSnapshot<MarketOverview>> getOverview();
  Future<MarketSnapshot<AssetStatistics>> getStatistics(String assetId);
  Future<MarketSnapshot<ChartSeries>> getChart(String assetId, String timeframe);
  Future<MarketSnapshot<List<OHLCData>>> getOhlc(String assetId, String timeframe);
}

abstract interface class WatchlistRepository {
  Future<Set<String>> getAssetIds();
  Future<void> setWatched(String assetId, bool isWatched);
}

abstract interface class NotificationRepository {
  Future<List<AurumNotification>> getNotifications();
  Future<void> markRead(String notificationId);
}

abstract interface class AuthRepository {
  Future<UserSession> signIn({required String email, required String password});
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AurumProfile> me();
  Future<UserSession> refresh(String refreshToken);
  Future<void> sendPasswordReset(String email);
  Future<void> resetPassword({required String token, required String password});
  Future<void> signOut();
}

abstract interface class UserRepository {
  Future<AurumProfile> updateProfile({required String name});
  Future<UserPreferences> getPreferences();
  Future<UserPreferences> updatePreferences(UserPreferences preferences);
  Future<UserNotificationPreferences> getNotificationPreferences();
  Future<UserNotificationPreferences> updateNotificationPreferences(UserNotificationPreferences preferences);
  Future<void> deleteAccount({required String password});
}

abstract interface class AlertRepository {
  Future<List<PriceAlert>> getAlerts();
  Future<PriceAlert> createAlert({required String assetId, required AlertCondition condition, required double targetPrice});
  Future<void> updateAlert({required String id, AlertCondition? condition, double? targetPrice, bool? active});
  Future<void> deleteAlert(String id);
}
