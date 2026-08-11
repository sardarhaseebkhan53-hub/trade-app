import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'theme/aurum_theme.dart';

class AurumApp extends StatefulWidget {
  const AurumApp({super.key});

  @override
  State<AurumApp> createState() => _AurumAppState();
}

class _AurumAppState extends State<AurumApp> {
  late final _router = AppRouter.build();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'AURUM',
        debugShowCheckedModeBanner: false,
        theme: AurumTheme.dark,
        routerConfig: _router,
      );
}
