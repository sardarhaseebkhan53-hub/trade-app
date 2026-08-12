import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardData(
      icon: Icons.auto_graph_rounded,
      title: 'Understand the market before you act.',
      subtitle: 'Real-time data, technical analysis, and explainable AI.',
    ),
    _OnboardData(
      icon: Icons.shield_outlined,
      title: 'Evidence, not promises.',
      subtitle: 'See supporting factors, conflicts, risks and invalidation conditions.',
    ),
    _OnboardData(
      icon: Icons.lock_outline_rounded,
      title: 'Your data stays yours.',
      subtitle: 'Secure authentication with optional biometric login.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AurumColors.canvas,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text('Skip', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: AurumBrand(compact: true)),
              const SizedBox(height: AurumSpacing.xxl),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardPage(data: _pages[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AurumColors.gold : AurumColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: AurumSpacing.xl),
              AurumButton(
                label: isLast ? 'Get Started' : 'Continue',
                onPressed: () {
                  if (isLast) {
                    context.go('/login');
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  const _OnboardData({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.data, super.key});
  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, size: 72, color: AurumColors.gold),
        const SizedBox(height: AurumSpacing.xxl),
        Text(data.title, style: AurumTypography.h1),
        const SizedBox(height: AurumSpacing.md),
        Text(data.subtitle, style: AurumTypography.bodyLarge),
      ],
    );
  }
}
