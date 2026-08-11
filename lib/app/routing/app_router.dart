import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_analysis/presentation/ai_analysis_screen.dart';
import '../../features/asset_details/presentation/asset_detail_screen.dart';
import '../../features/authentication/presentation/auth_screens.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/markets/presentation/markets_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/signals/presentation/signals_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../shared/widgets/aurum_primitives.dart';
import 'aurum_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter build() => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: AurumRoutes.splash,
        routes: <RouteBase>[
          GoRoute(path: AurumRoutes.splash, builder: (_, __) => const SplashScreen()),
          GoRoute(path: AurumRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
          GoRoute(path: AurumRoutes.login, builder: (_, __) => const LoginScreen()),
          GoRoute(path: AurumRoutes.register, builder: (_, __) => const RegisterScreen()),
          GoRoute(path: AurumRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
          StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) => AurumAppShell(navigationShell: navigationShell),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(routes: <RouteBase>[GoRoute(path: AurumRoutes.home, builder: (_, __) => const HomeScreen())]),
              StatefulShellBranch(routes: <RouteBase>[GoRoute(path: AurumRoutes.markets, builder: (_, __) => const MarketsScreen())]),
              StatefulShellBranch(routes: <RouteBase>[GoRoute(path: AurumRoutes.signals, builder: (_, __) => const SignalsScreen())]),
              StatefulShellBranch(routes: <RouteBase>[GoRoute(path: AurumRoutes.aiAnalysis, builder: (_, GoRouterState state) => AiAnalysisScreen(initialAssetId: state.uri.queryParameters['asset']))]),
              StatefulShellBranch(routes: <RouteBase>[GoRoute(path: AurumRoutes.profile, builder: (_, __) => const ProfileScreen())]),
            ],
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '${AurumRoutes.asset}/:assetId',
            pageBuilder: (_, GoRouterState state) => _transitionPage(state, AssetDetailScreen(assetId: state.pathParameters['assetId']!)),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: AurumRoutes.watchlist,
            pageBuilder: (_, GoRouterState state) => _transitionPage(state, const WatchlistScreen()),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: AurumRoutes.notifications,
            pageBuilder: (_, GoRouterState state) => _transitionPage(state, const NotificationsScreen()),
          ),
        ],
      );

  static CustomTransitionPage<void> _transitionPage(GoRouterState state, Widget child) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)), child: child),
        ),
      );
}

class AurumAppShell extends StatelessWidget {
  const AurumAppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AurumBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}
