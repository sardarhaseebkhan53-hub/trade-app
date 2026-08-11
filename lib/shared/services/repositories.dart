import '../models/market_models.dart';

abstract interface class MarketRepository {
  Future<List<MarketAsset>> getMarkets({String query = ''});
  Future<List<MarketAsset>> getFeaturedAssets();
  Future<MarketAsset> getAsset(String assetId);
  Future<MarketSentiment> getSentiment();
  Future<AssetStatistics> getStatistics(String assetId);
  Future<List<TechnicalIndicator>> getIndicators(String assetId);
  Future<List<double>> getChart(String assetId, String timeframe);
}

abstract interface class SignalRepository {
  Future<List<AnalysisSignal>> getSignals({bool includeHistory = false});
  Future<List<AnalysisSignal>> getForAsset(String assetId);
}

abstract interface class AiAnalysisRepository {
  Future<MarketInsight> getMarketInsight();
  Future<AiAnalysis> getAnalysis(String assetId);
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
  Future<AurumProfile> signIn({required String email, required String password});
  Future<AurumProfile> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
