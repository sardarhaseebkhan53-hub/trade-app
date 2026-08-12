import 'package:flutter/material.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'Legal & Policies'),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          _PolicyTile(
            title: 'Terms of Service',
            onTap: () => _showPolicy(context, 'Terms of Service', _termsContent()),
          ),
          _PolicyTile(
            title: 'Privacy Policy',
            onTap: () => _showPolicy(context, 'Privacy Policy', _privacyPolicyContent()),
          ),
          _PolicyTile(
            title: 'Financial Risk Disclosure',
            onTap: () => _showPolicy(context, 'Financial Risk Disclosure', _financialRiskContent()),
          ),
          _PolicyTile(
            title: 'AI & Analysis Disclaimer',
            onTap: () => _showPolicy(context, 'AI & Analysis Disclaimer', _aiDisclaimerContent()),
          ),
          _PolicyTile(
            title: 'Third-Party Services',
            onTap: () => _showPolicy(context, 'Third-Party Services', _thirdPartyContent()),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const Text(
            'Policy versions are recorded when you acknowledge them during first launch or updates.',
            style: AurumTypography.caption,
          ),
        ],
      ),
    );
  }

  void _showPolicy(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AurumColors.surface,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (ctx, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AurumTypography.h2),
              const SizedBox(height: AurumSpacing.lg),
              Text(content, style: AurumTypography.body),
              const SizedBox(height: AurumSpacing.xxl),
              AurumButton(label: 'Close', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  String _termsContent() => '''
AURUM TERMS OF SERVICE

AURUM is a market analysis and decision-support tool.

By using AURUM you agree that:

1. You understand cryptocurrency markets are extremely volatile.
2. All analysis, signals, AI output, and charts are for informational purposes only.
3. AURUM does not provide financial, investment, or trading advice.
4. You are solely responsible for all decisions you make.
5. AURUM may change or discontinue features at any time.
6. You will not misuse the service or attempt to reverse-engineer it.

Full legal terms apply as per the current version shown in the app.
''';

  String _privacyPolicyContent() => '''
PRIVACY POLICY

We collect and process only the data necessary to provide the AURUM service:

- Account details (name, email)
- Authentication data
- Preferences, watchlists, and alerts
- AI conversation history (optional)
- Device tokens for notifications (if you enable them)
- Security events for protecting your account

We do not:
- Sell your personal data
- Store raw biometric data (your device handles this)
- Require or store cryptocurrency private keys or seed phrases

You can request data export or deletion from the Security Center or by contacting support.

Full policy is available in the app and on our website.
''';

  String _financialRiskContent() => '''
FINANCIAL RISK DISCLOSURE

Cryptocurrency markets involve substantial risk of loss.

Past performance, technical indicators, market regime detection, signals, and AI analysis do not guarantee future results.

AURUM may display data that is delayed, incomplete, or based on third-party sources.

You could lose some or all of your capital.

Only invest what you can afford to lose.

AURUM is not a substitute for your own research and professional advice.
''';

  String _aiDisclaimerContent() => '''
AI & ANALYSIS DISCLAIMER

AURUM AI and all analytical features provide explanations based on available data at the time of processing.

They can be wrong, incomplete, or outdated.

"Analysis Strength" scores (e.g. 78/100) represent the strength of the signal according to our methodology. They are NOT probabilities of profit or future price movement.

Always verify data freshness.

Never make financial decisions based solely on AURUM output.
''';

  String _thirdPartyContent() => '''
THIRD-PARTY SERVICES

AURUM may use the following categories of third-party services (actual providers are listed in the app at the time of use):

- Authentication providers (Google Sign-In)
- Market data providers
- AI / LLM providers (when AI features are used)
- Push notification services
- Analytics and crash reporting (when enabled)

We only share the minimum data required for the service to function.
''';
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({required this.title, required this.onTap, super.key});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(child: Text(title, style: AurumTypography.label)),
            const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
