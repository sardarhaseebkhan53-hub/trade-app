import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/models/user_data_models.dart';
import '../shared/services/providers.dart';
import 'routing/app_router.dart';
import 'theme/aurum_theme.dart';

class AurumApp extends ConsumerStatefulWidget {
  const AurumApp({super.key});

  @override
  ConsumerState<AurumApp> createState() => _AurumAppState();
}

class _AurumAppState extends ConsumerState<AurumApp> {
  late final _router = AppRouter.build();

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, AsyncValue<AuthState> next) {
      if (next.valueOrNull?.status == AuthStatus.sessionExpired) {
        _router.go('/login');
      }
    });
    return MaterialApp.router(
      title: 'AURUM',
      debugShowCheckedModeBanner: false,
      theme: AurumTheme.dark,
      routerConfig: _router,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }
}
