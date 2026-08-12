import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/app_lock_service.dart';
import '../shared/models/user_data_models.dart';
import '../shared/services/providers.dart';
import 'routing/app_router.dart';
import 'theme/aurum_theme.dart';

class AurumApp extends ConsumerStatefulWidget {
  const AurumApp({super.key});

  @override
  ConsumerState<AurumApp> createState() => _AurumAppState();
}

class _AurumAppState extends ConsumerState<AurumApp> with WidgetsBindingObserver {
  final AppLockService _appLock = AppLockService();
  bool _lockShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLock.recordActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppLock();
    } else if (state == AppLifecycleState.paused) {
      _appLock.recordActivity();
    }
  }

  Future<void> _checkAppLock() async {
    final shouldLock = await _appLock.shouldRequireUnlock();
    final auth = ref.read(authControllerProvider).valueOrNull;

    if (shouldLock && auth?.isAuthenticated == true && !_lockShown && mounted) {
      _lockShown = true;
      // Show re-auth overlay / route
      final router = ref.read(appRouterProvider);
      // For simplicity, we navigate to login (which will fall back to biometric if enabled)
      // In a full build we would show an in-app lock modal with biometric.
      router.go('/login');
      await Future.delayed(const Duration(milliseconds: 400));
      _lockShown = false;
    }
    await _appLock.recordActivity();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, next) {
      final state = next.valueOrNull;
      if (state?.status == AuthStatus.sessionExpired) {
        router.go('/login');
      }
    });

    return MaterialApp.router(
      title: 'AURUM',
      debugShowCheckedModeBanner: false,
      theme: AurumTheme.dark,
      routerConfig: router,
    );
  }
}
