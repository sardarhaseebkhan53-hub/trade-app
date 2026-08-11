import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/backend_api_exception.dart';
import '../../core/networking/aurum_backend_client.dart';
import '../../core/networking/market_api_client.dart';
import '../../core/storage/secure_session_store.dart';
import '../../features/analysis/data/analysis_repository.dart';
import '../../features/analysis/domain/analysis_models.dart';
import '../../features/analysis/domain/analysis_request.dart';
import '../../features/analysis/services/ai_analysis_service.dart';
import '../../features/analysis/services/signal_engine.dart';
import '../../features/analysis/services/technical_analysis_service.dart';
import '../../features/markets/data/coin_gecko_market_service.dart';
import '../../features/markets/data/remote_market_repository.dart';
import '../models/market_data_models.dart';
import '../models/market_models.dart';
import '../models/user_data_models.dart';
import 'mock_repositories.dart';
import 'remote_user_repositories.dart';
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

final secureSessionStoreProvider = Provider<SecureSessionStore>(
  (Ref ref) => FlutterSecureSessionStore(),
);

class SessionExpiryController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> expire() {
    state = true;
    return Future<void>.value();
  }

  void reset() => state = false;
}

final sessionExpiryProvider = NotifierProvider<SessionExpiryController, bool>(
  SessionExpiryController.new,
);

final aurumBackendClientProvider = Provider<AurumBackendClient>((Ref ref) {
  final client = AurumBackendClient(
    config: ref.watch(appConfigProvider),
    sessionStore: ref.watch(secureSessionStoreProvider),
    onUnauthorized: () => ref.read(sessionExpiryProvider.notifier).expire(),
  );
  ref.onDispose(client.dispose);
  return client;
});

final watchlistRepositoryProvider = Provider<WatchlistRepository>((Ref ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteWatchlistRepository(ref.watch(aurumBackendClientProvider))
      : MockWatchlistRepository();
});
final notificationRepositoryProvider = Provider<NotificationRepository>((Ref ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteNotificationRepository(ref.watch(aurumBackendClientProvider))
      : MockNotificationRepository();
});
final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteAuthRepository(ref.watch(aurumBackendClientProvider), ref.watch(secureSessionStoreProvider))
      : MockAuthRepository();
});
final userRepositoryProvider = Provider<UserRepository>((Ref ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteUserRepository(ref.watch(aurumBackendClientProvider))
      : MockUserRepository();
});
final alertRepositoryProvider = Provider<AlertRepository>((Ref ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteAlertRepository(ref.watch(aurumBackendClientProvider))
      : MockAlertRepository();
});

final marketsProvider = FutureProvider.autoDispose.family<MarketSnapshot<List<MarketAsset>>, String>(
  (Ref ref, String query) => ref.read(marketRepositoryProvider).getMarkets(query: query),
);
final featuredAssetsProvider = FutureProvider<MarketSnapshot<List<MarketAsset>>>(
  (Ref ref) => ref.read(marketRepositoryProvider).getFeaturedAssets(),
);
final marketOverviewProvider = FutureProvider<MarketSnapshot<MarketOverview>>(
  (Ref ref) => ref.read(marketRepositoryProvider).getOverview(),
);
final assetProvider = FutureProvider.autoDispose.family<MarketSnapshot<MarketAsset>, String>(
  (Ref ref, String assetId) => ref.read(marketRepositoryProvider).getAsset(assetId),
);
final statisticsProvider = FutureProvider.autoDispose.family<MarketSnapshot<AssetStatistics>, String>(
  (Ref ref, String assetId) => ref.read(marketRepositoryProvider).getStatistics(assetId),
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

final technicalAnalysisServiceProvider = Provider<TechnicalAnalysisService>(
  (Ref ref) => const TechnicalAnalysisService(),
);
final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (Ref ref) => AnalysisRepository(
    marketRepository: ref.watch(marketRepositoryProvider),
    technicalService: ref.watch(technicalAnalysisServiceProvider),
  ),
);
final technicalAnalysisProvider = FutureProvider.autoDispose.family<MarketAnalysis, AnalysisRequest>(
  (Ref ref, AnalysisRequest request) => ref.read(analysisRepositoryProvider).analyze(request),
);
final multiTimeframeAnalysisProvider = FutureProvider.autoDispose.family<Map<String, MarketAnalysis>, String>(
  (Ref ref, String assetId) => ref.read(analysisRepositoryProvider).analyzeMultipleTimeframes(assetId),
);

final aiAnalysisServiceProvider = Provider<AIAnalysisService>(
  (Ref ref) => MockAIAnalysisService(),
);
final aiAnalysisCacheProvider = Provider<AiAnalysisCache>((Ref ref) => AiAnalysisCache());
final aiAnalysisProvider = FutureProvider.autoDispose.family<AiMarketAnalysis, AnalysisRequest>(
  (Ref ref, AnalysisRequest request) async {
    final analysis = await ref.read(technicalAnalysisProvider(request).future);
    return ref.read(aiAnalysisCacheProvider).getOrCreate(
          analysis,
          ref.read(aiAnalysisServiceProvider),
        );
  },
);
final homeAiAnalysisProvider = FutureProvider<AiMarketAnalysis>((Ref ref) async {
  final featured = await ref.read(featuredAssetsProvider.future);
  if (featured.data.isEmpty) {
    throw const ServiceFailure('No featured market is available for analysis.');
  }
  final request = AnalysisRequest(assetId: featured.data.first.id, timeframe: '1D');
  return ref.read(aiAnalysisProvider(request).future);
});

final signalEngineProvider = Provider<SignalEngine>((Ref ref) => const SignalEngine());
final signalHistoryStoreProvider = Provider<SignalHistoryStore>((Ref ref) => SignalHistoryStore());
final signalFeedRepositoryProvider = Provider<SignalFeedRepository>(
  (Ref ref) => SignalFeedRepository(
    marketRepository: ref.watch(marketRepositoryProvider),
    analysisRepository: ref.watch(analysisRepositoryProvider),
    signalEngine: ref.watch(signalEngineProvider),
    history: ref.watch(signalHistoryStoreProvider),
  ),
);
final signalsProvider = FutureProvider<List<SignalRecord>>(
  (Ref ref) => ref.read(signalFeedRepositoryProvider).generateFeatured(),
);
final assetSignalRecordsProvider = FutureProvider.autoDispose.family<List<SignalRecord>, AnalysisRequest>(
  (Ref ref, AnalysisRequest request) => ref
      .read(signalFeedRepositoryProvider)
      .generateForAsset(request.assetId, timeframe: request.timeframe),
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

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    ref.listen<bool>(sessionExpiryProvider, (_, bool expired) {
      if (expired) {
        state = const AsyncData(AuthState(status: AuthStatus.sessionExpired));
      }
    });
    final tokens = await ref.read(secureSessionStoreProvider).readTokens();
    if (tokens == null) return const AuthState.unauthenticated();
    try {
      final session = await ref.read(authRepositoryProvider).refresh(tokens.refreshToken);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile, expiresAt: session.accessExpiresAt);
    } on BackendUnauthorizedException {
      await ref.read(secureSessionStoreProvider).clear();
      return const AuthState(status: AuthStatus.sessionExpired);
    } catch (_) {
      return const AuthState.unauthenticated();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
      ref.read(sessionExpiryProvider.notifier).reset();
      return AuthState(status: AuthStatus.authenticated, profile: session.profile, expiresAt: session.accessExpiresAt);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).register(name: name, email: email, password: password);
      ref.read(sessionExpiryProvider.notifier).reset();
      return AuthState(status: AuthStatus.authenticated, profile: session.profile, expiresAt: session.accessExpiresAt);
    });
  }

  Future<void> signOut() async {
    state = AsyncData(AuthState(status: AuthStatus.loggingOut, profile: state.valueOrNull?.profile));
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      await ref.read(secureSessionStoreProvider).clear();
      ref.read(sessionExpiryProvider.notifier).reset();
      state = const AsyncData(AuthState.unauthenticated());
    }
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final alertsProvider = FutureProvider<List<PriceAlert>>(
  (Ref ref) => ref.read(alertRepositoryProvider).getAlerts(),
);
