import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/networking/market_api_client.dart';
import '../../features/markets/data/coin_gecko_market_service.dart';
import '../../features/markets/data/remote_market_repository.dart';
import '../models/market_data_models.dart';
import '../models/market_models.dart';
import 'mock_repositories.dart';
import 'repositories.dart';

final appConfigProvider = Provider<AppConfig>((Ref ref) => AppConfig.fromEnvironment());

final marketApiClientProvider = Provider<MarketApiClient>((Ref ref) {
  final client = HttpMarketApiClient(config: ref.watch(appConfigProvider));
  ref.onDispose(client.dispose);
  return client;
});

final marketRepositoryProvider = Provider<MarketRepository>((Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (config.marketDataMode == MarketDataMode.mock) return MockMarketRepository();
  return RemoteMarketRepository(
    service: CoinGeckoMarketService(ref.watch(marketApiClientProvider)),
  );
});

final signalRepositoryProvider = Provider<SignalRepository>((Ref ref) => MockSignalRepository());
final aiAnalysisRepositoryProvider = Provider<AiAnalysisRepository>((Ref ref) => MockAiAnalysisRepository());
final watchlistRepositoryProvider = Provider<WatchlistRepository>((Ref ref) => MockWatchlistRepository());
final notificationRepositoryProvider = Provider<NotificationRepository>((Ref ref) => MockNotificationRepository());
final authRepositoryProvider = Provider<AuthRepository>((Ref ref) => MockAuthRepository());

final marketsProvider = FutureProvider.autoDispose.family<MarketSnapshot<List<MarketAsset>>, String>(
  (Ref ref, String query) => ref.read(marketRepositoryProvider).getMarkets(query: query),
);
final featuredAssetsProvider = FutureProvider<MarketSnapshot<List<MarketAsset>>>(
  (Ref ref) => ref.read(marketRepositoryProvider).getFeaturedAssets(),
);
final marketOverviewProvider = FutureProvider<MarketSnapshot<MarketOverview>>(
  (Ref ref) => ref.read(marketRepositoryProvider).getOverview(),
);
final marketInsightProvider = FutureProvider<MarketInsight>(
  (Ref ref) => ref.read(aiAnalysisRepositoryProvider).getMarketInsight(),
);
final assetProvider = FutureProvider.autoDispose.family<MarketSnapshot<MarketAsset>, String>(
  (Ref ref, String assetId) => ref.read(marketRepositoryProvider).getAsset(assetId),
);
final statisticsProvider = FutureProvider.autoDispose.family<MarketSnapshot<AssetStatistics>, String>(
  (Ref ref, String assetId) => ref.read(marketRepositoryProvider).getStatistics(assetId),
);
final indicatorsProvider = FutureProvider.autoDispose.family<List<TechnicalIndicator>, String>(
  (Ref ref, String assetId) => ref.read(marketRepositoryProvider).getIndicators(assetId),
);
final assetSignalsProvider = FutureProvider.autoDispose.family<List<AnalysisSignal>, String>(
  (Ref ref, String assetId) => ref.read(signalRepositoryProvider).getForAsset(assetId),
);
final signalsProvider = FutureProvider<List<AnalysisSignal>>(
  (Ref ref) => ref.read(signalRepositoryProvider).getSignals(),
);
final notificationsProvider = FutureProvider<List<AurumNotification>>(
  (Ref ref) => ref.read(notificationRepositoryProvider).getNotifications(),
);
final aiAnalysisProvider = FutureProvider.autoDispose.family<AiAnalysis, String>(
  (Ref ref, String assetId) => ref.read(aiAnalysisRepositoryProvider).getAnalysis(assetId),
);

class ChartRequest {
  const ChartRequest(this.assetId, this.timeframe);
  final String assetId;
  final String timeframe;

  @override
  bool operator ==(Object other) =>
      other is ChartRequest && other.assetId == assetId && other.timeframe == timeframe;

  @override
  int get hashCode => Object.hash(assetId, timeframe);
}

final chartProvider = FutureProvider.autoDispose.family<MarketSnapshot<ChartSeries>, ChartRequest>(
  (Ref ref, ChartRequest request) =>
      ref.read(marketRepositoryProvider).getChart(request.assetId, request.timeframe),
);
final ohlcProvider = FutureProvider.autoDispose.family<MarketSnapshot<List<OHLCData>>, ChartRequest>(
  (Ref ref, ChartRequest request) =>
      ref.read(marketRepositoryProvider).getOhlc(request.assetId, request.timeframe),
);

class WatchlistController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => ref.read(watchlistRepositoryProvider).getAssetIds();

  Future<void> toggle(String assetId) async {
    final existing = state.valueOrNull ?? <String>{};
    final shouldWatch = !existing.contains(assetId);
    state = AsyncData(<String>{
      if (shouldWatch) ...existing else ...existing.where((String id) => id != assetId),
      if (shouldWatch) assetId,
    });
    try {
      await ref.read(watchlistRepositoryProvider).setWatched(assetId, shouldWatch);
    } catch (_) {
      state = AsyncData(existing);
      rethrow;
    }
  }
}

final watchlistProvider = AsyncNotifierProvider<WatchlistController, Set<String>>(
  WatchlistController.new,
);

final watchlistAssetsProvider = FutureProvider<MarketSnapshot<List<MarketAsset>>>((Ref ref) async {
  final ids = await ref.watch(watchlistProvider.future);
  return ref.read(marketRepositoryProvider).getAssetsByIds(ids);
});

class AuthController extends AsyncNotifier<AurumProfile> {
  @override
  Future<AurumProfile> build() async => const AurumProfile(
        name: 'Guest analyst',
        email: '',
        isGuest: true,
        currency: 'USD',
        reducedMotion: false,
      );

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email: email, password: password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(AurumProfile(
      name: 'Guest analyst',
      email: '',
      isGuest: true,
      currency: 'USD',
      reducedMotion: false,
    ));
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AurumProfile>(
  AuthController.new,
);
