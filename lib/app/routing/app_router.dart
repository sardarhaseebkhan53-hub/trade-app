import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_analysis/presentation/ai_analysis_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/analysis/presentation/analysis_screen.dart';
import '../../features/asset_details/presentation/asset_detail_screen.dart';
import '../../features/authentication/presentation/auth_screens.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/ai_history/presentation/ai_history_screen.dart';
import '../../features/safety_privacy/presentation/legal_policies_screen.dart';
import '../../features/safety_privacy/presentation/permission_explanation_screen.dart';
import '../../features/safety_privacy/presentation/privacy_center_screen.dart';
import '../../features/safety_privacy/presentation/safety_privacy_center_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/security/presentation/security_center_screen.dart';
import '../../features/security/presentation/two_factor_screen.dart';
import '../../features/signals/presentation/signals_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../shared/widgets/aurum_primitives.dart';
import 'aurum_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AurumRoutes.splash,
    routes: [
      GoRoute(path: AurumRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AurumRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AurumRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AurumRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AurumRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AurumAppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: AurumRoutes.home, builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AurumRoutes.markets, builder: (_, __) => const MarketsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AurumRoutes.analysis, builder: (_, __) => const AnalysisScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AurumRoutes.aiAnalysis, builder: (_, state) => AiAnalysisScreen(initialAssetId: state.uri.queryParameters['asset']))]),
          StatefulShellBranch(routes: [GoRoute(path: AurumRoutes.portfolio, builder: (_, __) => const PortfolioScreen())]),
        ],
      ),

      GoRoute(path: AurumRoutes.journal, builder: (_, __) => const JournalScreen()),
      GoRoute(path: AurumRoutes.scanner, builder: (_, __) => const ScannerScreen()),

      GoRoute(
        path: \'/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (_, __) => const SecurityCenterScreen(),
      ),
      GoRoute(
        path: '/security/2fa',
        builder: (_, __) => const TwoFactorScreen(),
      ),
      GoRoute(
        path: '/ai-history',
        builder: (_, __) => const AiHistoryScreen(),
      ),
      GoRoute(
        path: '/safety-privacy',
        builder: (_, __) => const SafetyPrivacyCenterScreen(),
      ),
      GoRoute(
        path: '/legal',
        builder: (_, __) => const LegalPoliciesScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (_, __) => const PermissionExplanationScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyCenterScreen(),
      ),

      GoRoute(
        path: '${AurumRoutes.asset}/:assetId',
        builder: (context, state) => AssetDetailScreen(assetId: state.pathParameters['assetId']!),
      ),
      GoRoute(path: AurumRoutes.watchlist, builder: (_, __) => const WatchlistScreen()),
      GoRoute(path: AurumRoutes.alerts, builder: (_, __) => const AlertsScreen()),
      GoRoute(path: AurumRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
    ],
  );
});

class AurumAppShell extends StatelessWidget {
  const AurumAppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AurumBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}
