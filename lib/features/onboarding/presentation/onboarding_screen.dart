import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_radius.dart';
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
  var _index = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.auto_graph_rounded,
      eyebrow: 'AURUM MARKET INTELLIGENCE',
      title: 'A calmer way to read crypto markets.',
      body: 'Track market context, price movement and the assets that deserve a closer look.',
    ),
    _OnboardingPageData(
      icon: Icons.candlestick_chart_rounded,
      eyebrow: 'TECHNICAL CONTEXT',
      title: 'Explore data before you form a view.',
      body: 'Inspect clean charts, indicators, market statistics and time-bound source information.',
    ),
    _OnboardingPageData(
      icon: Icons.auto_awesome_outlined,
      eyebrow: 'AI-ASSISTED RESEARCH',
      title: 'Evidence-led insights, not a noisy chatbot.',
      body: 'AURUM presents observations, scenarios and counterpoints with visible uncertainty.',
    ),
    _OnboardingPageData(
      icon: Icons.shield_outlined,
      eyebrow: 'RISK CONTEXT',
      title: 'Analysis can inform decisions. It cannot remove risk.',
      body: 'Markets are volatile. AURUM is for analysis and education only, not financial advice or a promise of outcomes.',
      isDisclosure: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AurumColors.canvas,
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text('Skip', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
          ),
          const SizedBox(width: AurumSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.lg),
          child: Column(
            children: <Widget>[
              const Align(alignment: Alignment.centerLeft, child: AurumBrand(compact: true)),
              const SizedBox(height: AurumSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int index) => _OnboardingPanel(data: _pages[index]),
                ),
              ),
              Row(
                children: List<Widget>.generate(_pages.length, (int index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: AurumSpacing.xs),
                    height: 4,
                    width: _index == index ? 28 : 10,
                    decoration: BoxDecoration(
                      color: _index == index ? AurumColors.gold : AurumColors.borderStrong,
                      borderRadius: AurumRadius.pill,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AurumSpacing.lg),
              AurumButton(
                label: last ? 'Get started' : 'Continue',
                icon: last ? Icons.arrow_forward_rounded : null,
                onPressed: () {
                  if (last) {
                    context.go('/home');
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                  }
                },
              ),
              const SizedBox(height: AurumSpacing.sm),
              AurumButton(
                label: 'Sign in to sync your workspace',
                variant: AurumButtonVariant.text,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.data});
  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AurumColors.surfaceElevated,
              borderRadius: AurumRadius.hero,
              border: Border.all(color: AurumColors.border),
            ),
            child: Icon(data.icon, color: AurumColors.gold, size: 36),
          ),
          const SizedBox(height: AurumSpacing.xxxl),
          Text(data.eyebrow, style: AurumTypography.label.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.4)),
          const SizedBox(height: AurumSpacing.sm),
          Text(data.title, style: AurumTypography.display),
          const SizedBox(height: AurumSpacing.md),
          Text(data.body, style: AurumTypography.bodyLarge),
          if (data.isDisclosure) ...<Widget>[
            const SizedBox(height: AurumSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AurumSpacing.md),
              decoration: BoxDecoration(
                color: AurumColors.warning.withOpacity(0.08),
                border: Border.all(color: AurumColors.warning.withOpacity(0.45)),
                borderRadius: AurumRadius.card,
              ),
              child: Text('By continuing, you acknowledge that market data and AI commentary can be incomplete, delayed or wrong.', style: AurumTypography.body),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.isDisclosure = false,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  final bool isDisclosure;
}
