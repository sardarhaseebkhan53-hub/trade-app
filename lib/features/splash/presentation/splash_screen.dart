import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  )..forward();

  @override
  void initState() {
    super.initState();
    _continueBootstrap();
  }

  Future<void> _continueBootstrap() async {
    // Phase 3 mock bootstrap. Phase 6 replaces this with consent/session checks.
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (mounted) context.go('/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: AurumColors.ink,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: reduceMotion ? const AlwaysStoppedAnimation<double>(1) : CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 1.8, color: AurumColors.gold),
                ),
                const SizedBox(height: AurumSpacing.sm),
                Text('Preparing your market workspace', style: AurumTypography.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
