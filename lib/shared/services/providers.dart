import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/app_config.dart';
import '../../core/networking/aurum_backend_client.dart';
import '../../core/storage/app_lock_service.dart';
import '../../core/storage/biometric_service.dart';
import '../../core/storage/secure_session_store.dart';
import '../../domain/market_entities.dart';
import '../models/market_data_models.dart';
import '../models/market_models.dart';
import '../models/user_data_models.dart';
import 'mock_repositories.dart';
import 'remote_user_repositories.dart';
import 'repositories.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) => FlutterSecureSessionStore());

final aurumBackendClientProvider = Provider<AurumBackendClient>((ref) {
  final client = AurumBackendClient(
    config: ref.watch(appConfigProvider),
    sessionStore: ref.watch(secureSessionStoreProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

// === MARKET REPOSITORY (real + mock switch) ===
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.marketDataMode == MarketDataMode.mock) {
    return MockMarketRepository();
  }
  // RemoteMarketRepository would be injected here in real builds
  return MockMarketRepository(); // Safe default for now
});

// === REPOSITORIES (auth / watchlist / alerts / notifications) ===
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteWatchlistRepository(ref.watch(aurumBackendClientProvider))
      : MockWatchlistRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteAuthRepository(ref.watch(aurumBackendClientProvider), ref.watch(secureSessionStoreProvider))
      : MockAuthRepository();
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteAlertRepository(ref.watch(aurumBackendClientProvider))
      : MockAlertRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ref.watch(appConfigProvider).backendMode == BackendMode.remote
      ? RemoteNotificationRepository(ref.watch(aurumBackendClientProvider))
      : MockNotificationRepository();
});

// === STATE PROVIDERS ===
final marketsProvider = FutureProvider.autoDispose.family<List<Asset>, String>((ref, query) async {
  final repo = ref.read(marketRepositoryProvider);
  final snapshot = await repo.getMarkets(query: query);
  return snapshot.data;
});

final featuredAssetsProvider = FutureProvider<List<Asset>>((ref) async {
  final repo = ref.read(marketRepositoryProvider);
  final snapshot = await repo.getFeaturedAssets();
  return snapshot.data;
});

final marketOverviewProvider = FutureProvider<MarketOverview>((ref) async {
  final repo = ref.read(marketRepositoryProvider);
  final snapshot = await repo.getOverview();
  return snapshot.data;
});

final watchlistProvider = AsyncNotifierProvider<WatchlistController, Set<String>>(WatchlistController.new);

class WatchlistController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() => ref.read(watchlistRepositoryProvider).getAssetIds();

  Future<void> toggle(String assetId) async {
    final current = state.valueOrNull ?? {};
    final next = Set<String>.from(current);
    if (next.contains(assetId)) {
      next.remove(assetId);
    } else {
      next.add(assetId);
    }
    state = AsyncData(next);
    await ref.read(watchlistRepositoryProvider).setWatched(assetId, next.contains(assetId));
  }
}

final watchlistAssetsProvider = FutureProvider<List<Asset>>((ref) async {
  final ids = await ref.watch(watchlistProvider.future);
  final repo = ref.read(marketRepositoryProvider);
  final snapshot = await repo.getAssetsByIds(ids);
  return snapshot.data;
});

// === AUTH ===
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final tokens = await ref.read(secureSessionStoreProvider).readTokens();
    if (tokens == null) return const AuthState.unauthenticated();

    try {
      final session = await ref.read(authRepositoryProvider).refresh(tokens.refreshToken);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile);
    } catch (_) {
      return const AuthState.unauthenticated();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile);
    });
  }

  Future<void> register({required String name, required String email, required String password}) async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).register(name: name, email: email, password: password);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile);
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(secureSessionStoreProvider).clear();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final googleUser = await ref.read(googleSignInProvider).signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('No Google ID token');

      final session = await ref.read(authRepositoryProvider).signInWithGoogle(idToken);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile);
    });
  }
}

final alertsProvider = FutureProvider<List<PriceAlert>>((ref) async {
  return ref.read(alertRepositoryProvider).getAlerts();
});

final notificationsProvider = FutureProvider<List<AurumNotification>>((ref) async {
  return ref.read(notificationRepositoryProvider).getNotifications();
});

// Asset + Chart providers (for asset details)
class ChartRequest {
  const ChartRequest(this.assetId, this.timeframe);
  final String assetId;
  final String timeframe;
}

final assetProvider = FutureProvider.family<dynamic, String>((ref, assetId) async {
  final repo = ref.read(marketRepositoryProvider);
  final snap = await repo.getAsset(assetId);
  return snap.data;
});

final chartProvider = FutureProvider.family<List<dynamic>, ChartRequest>((ref, req) async {
  final repo = ref.read(marketRepositoryProvider);
  final snap = await repo.getChart(req.assetId, req.timeframe);
  return snap.data;
});

// === BIOMETRIC + GOOGLE PROVIDERS ===
final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

// App Lock (for background re-auth)
final appLockServiceProvider = Provider<AppLockService>((ref) => AppLockService());

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
});

// Extend AuthController with Google method
extension AuthControllerGoogle on AuthController {
  Future<void> signInWithGoogle() async {
    state = const AsyncData(AuthState(status: AuthStatus.authenticating));
    state = await AsyncValue.guard(() async {
      final googleUser = await ref.read(googleSignInProvider).signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      // Call backend with Google idToken (backend must support /auth/google)
      final session = await ref.read(authRepositoryProvider).signInWithGoogle(idToken!);
      return AuthState(status: AuthStatus.authenticated, profile: session.profile);
    });
  }
}
