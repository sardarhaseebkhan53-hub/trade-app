import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/storage/biometric_service.dart';
import '../../../core/storage/first_launch_store.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 1350));

    if (!mounted) return;

    final firstLaunchStore = FirstLaunchStore();
    final hasCompletedSafety = await firstLaunchStore.hasCompletedSafetyFlow();

    if (!hasCompletedSafety) {
      if (mounted) context.go('/safety-privacy');
      return;
    }

    final auth = ref.read(authControllerProvider).valueOrNull;

    if (auth?.isAuthenticated == true) {
      // Try biometric unlock for returning users
      final biometric = ref.read(biometricServiceProvider);
      final enabled = await biometric.isBiometricEnabled();
      final available = await biometric.isBiometricAvailable();

      if (enabled && available && mounted) {
        final success = await biometric.authenticate(reason: 'Unlock AURUM');
        if (success && mounted) {
          context.go('/home');
          return;
        } else if (mounted) {
          // Biometric failed → fallback to password
          context.go('/login');
          return;
        }
      }
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurumColors.ink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AurumColors.gold, width: 1.5),
                ),
                child: const Icon(Icons.insights_outlined, color: AurumColors.goldSoft, size: 36),
              ),
              const SizedBox(height: AurumSpacing.xl),
              const AurumBrand(),
              const SizedBox(height: AurumSpacing.sm),
              Text(
                'POCKET BROKER',
                style: AurumTypography.caption.copyWith(letterSpacing: 3.2, color: AurumColors.textSecondary),
              ),
              const SizedBox(height: AurumSpacing.xxxl),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AurumColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
