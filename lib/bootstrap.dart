import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/aurum_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Add crash reporting / analytics init in production
  runApp(const ProviderScope(child: AurumApp()));
}
