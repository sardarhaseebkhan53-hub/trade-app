import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/user_data_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  )..forward();
  var _routed = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, AsyncValue<AuthState> next) {
      final state = next.valueOrNull;
      if (state == null || _routed) return;
      _routed = true;
      if (state.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AurumColors.ink,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: reduceMotion
                ? const AlwaysStoppedAnimation<double>(1)
                : CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AurumColors.gold, width: 1.3),
                  ),
                  child: const Icon(Icons.insights_outlined, color: AurumColors.goldSoft, size: 34),
                ),
                const SizedBox(height: AurumSpacing.xl),
                const AurumBrand(),
                const SizedBox(height: AurumSpacing.sm),
                Text('MARKET INTELLIGENCE', style: AurumTypography.caption.copyWith(letterSpacing: 2.8, color: AurumColors.textSecondary)),
                const SizedBox(height: AurumSpacing.xxxl),
                const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 1.8, color: AurumColors.gold)),
                const SizedBox(height: AurumSpacing.sm),
                Text(
                  auth.valueOrNull?.status == AuthStatus.sessionExpired
                      ? 'Your session has ended'
                      : 'Restoring your secure workspace',
                  style: AurumTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
