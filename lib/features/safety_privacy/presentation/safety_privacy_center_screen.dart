import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/storage/first_launch_store.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class SafetyPrivacyCenterScreen extends StatefulWidget {
  const SafetyPrivacyCenterScreen({super.key});

  @override
  State<SafetyPrivacyCenterScreen> createState() => _SafetyPrivacyCenterScreenState();
}

class _SafetyPrivacyCenterScreenState extends State<SafetyPrivacyCenterScreen> {
  final Map<String, bool> _acknowledgements = {
    'risk': false,
    'ai': false,
    'privacy': false,
    'terms': false,
  };

  bool get _allAcknowledged => _acknowledgements.values.every((v) => v);

  Future<void> _continue() async {
    if (!_allAcknowledged) return;

    final store = FirstLaunchStore();
    await store.markSafetyFlowCompleted();

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurumColors.canvas,
      appBar: AppBar(
        backgroundColor: AurumColors.canvas,
        elevation: 0,
        title: const Text('YOUR SAFETY MATTERS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please review how AURUM protects your account, data and decision-making.',
                style: AurumTypography.bodyLarge,
              ),
              const SizedBox(height: AurumSpacing.xxl),

              _SafetyCard(
                icon: Icons.warning_amber_rounded,
                title: 'Financial Risk',
                subtitle: 'Cryptocurrency markets are highly volatile',
                onTap: () => _showDisclosure(context, 'Financial Risk', _financialRiskContent()),
              ),
              _SafetyCard(
                icon: Icons.auto_awesome_outlined,
                title: 'AI Limitations',
                subtitle: 'AI can make mistakes and produce incomplete analysis',
                onTap: () => _showDisclosure(context, 'AI Limitations', _aiLimitationsContent()),
              ),
              _SafetyCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'What data AURUM processes and why',
                onTap: () => _showDisclosure(context, 'Privacy Summary', _privacyContent()),
              ),
              _SafetyCard(
                icon: Icons.shield_outlined,
                title: 'Account Security',
                subtitle: 'How we protect your login and sessions',
                onTap: () => _showDisclosure(context, 'Account Security', _securityContent()),
              ),
              _SafetyCard(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications & Permissions',
                subtitle: 'What we request and why',
                onTap: () => context.push('/permissions'),
              ),
              _SafetyCard(
                icon: Icons.gavel_outlined,
                title: 'Terms & Policies',
                subtitle: 'Legal agreements',
                onTap: () => context.push('/legal'),
              ),
              const SizedBox(height: AurumSpacing.lg),
              const AntiScamNotice(),

              const SizedBox(height: AurumSpacing.xxl),
              const Text('Required Acknowledgements', style: AurumTypography.h3),
              const SizedBox(height: AurumSpacing.sm),

              _AcknowledgementCheckbox(
                value: _acknowledgements['risk']!,
                label: 'I understand that AURUM provides analytical information, not guaranteed financial results, and that cryptocurrency markets are highly volatile.',
                onChanged: (v) => setState(() => _acknowledgements['risk'] = v ?? false),
              ),
              _AcknowledgementCheckbox(
                value: _acknowledgements['ai']!,
                label: 'I understand that AI analysis and signals can be incorrect, incomplete, or based on stale data, and that "Analysis Strength" scores are not probabilities of profit.',
                onChanged: (v) => setState(() => _acknowledgements['ai'] = v ?? false),
              ),
              _AcknowledgementCheckbox(
                value: _acknowledgements['privacy']!,
                label: 'I have reviewed the Privacy Summary and understand what data AURUM processes.',
                onChanged: (v) => setState(() => _acknowledgements['privacy'] = v ?? false),
              ),
              _AcknowledgementCheckbox(
                value: _acknowledgements['terms']!,
                label: 'I agree to the Terms of Service and Privacy Policy.',
                onChanged: (v) => setState(() => _acknowledgements['terms'] = v ?? false),
              ),

              const SizedBox(height: AurumSpacing.xxl),
              AurumButton(
                label: 'CONTINUE TO AURUM',
                onPressed: _allAcknowledged ? _continue : null,
              ),
              const SizedBox(height: AurumSpacing.sm),
              const Center(
                child: Text(
                  'AURUM • Analysis only. Not financial advice.',
                  style: AurumTypography.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisclosure(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AurumColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AurumTypography.h2),
              const SizedBox(height: AurumSpacing.lg),
              Text(content, style: AurumTypography.body),
              const SizedBox(height: AurumSpacing.xxl),
              AurumButton(
                label: 'I understand',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _financialRiskContent() => '''
IMPORTANT RISK NOTICE

Cryptocurrency markets are highly volatile. Prices can change rapidly and dramatically.

Market analysis, technical indicators, market regime detection, signals, and AI-generated information may be:

• Incorrect
• Incomplete
• Delayed
• Based on stale data
• Unavailable during network or provider issues

AURUM does NOT guarantee:
- Profit
- Returns
- Accuracy
- Signal success
- Future prices
- Market direction

AURUM is an analytical and informational tool only.

You are solely responsible for your financial decisions.

Never treat AURUM as a guaranteed trading system or investment advice.
''';

  String _aiLimitationsContent() => '''
ABOUT AURUM AI

AURUM AI provides analytical explanations based on available market information at the time of analysis.

AI can:
- Make mistakes
- Misinterpret data
- Produce incomplete analysis
- Fail to understand unusual or extreme market conditions
- Become temporarily unavailable
- Produce outdated conclusions if underlying data is stale

AI output must never be represented as guaranteed truth or financial advice.

Always check data freshness indicators.
''';

  String _privacyContent() => '''
PRIVACY SUMMARY

AURUM processes the following information when necessary:

• Account information (name, email)
• Authentication tokens and sessions
• User preferences and settings
• Watchlists and alerts you create
• AI conversation history (if you use the AI Analyst)
• Device information for push notifications (if enabled)
• Security events for account protection

We use this data to:
- Provide the service
- Secure your account
- Deliver notifications you requested
- Improve the product (with your consent where required)

We do NOT:
- Sell your data
- Store raw biometric information (handled by your device)
- Require private keys or seed phrases

Full details are in the Privacy Policy.
''';

  String _securityContent() => '''
ACCOUNT SECURITY

AURUM uses industry-standard security practices:

• Passwords are hashed using Argon2id (never stored in plaintext)
• Authentication tokens are securely stored on your device
• Sessions can be revoked from the Security Center
• Biometric login uses your device’s secure APIs only
• We never ask for your seed phrase, private key, or recovery codes

You can:
- Enable/disable biometric login
- View active devices
- Sign out all other devices
- Review security activity

Report any suspicious activity immediately.
''';

  String _permissionsContent() => '''
NOTIFICATIONS & PERMISSIONS

AURUM requests the following only when needed:

• Notifications – to deliver price alerts, signals, and security events you have enabled.
• Biometric APIs – to allow fast, secure unlock of your account on this device.

We explain why we need each permission before requesting it.

You can change these settings at any time in your device settings or in-app Privacy controls.

Denying permissions will limit some features (for example, you won’t receive alerts if notifications are disabled).
''';
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AurumColors.gold, size: 28),
            const SizedBox(width: AurumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AurumTypography.h3),
                  Text(subtitle, style: AurumTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _AcknowledgementCheckbox extends StatelessWidget {
  const _AcknowledgementCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AurumTypography.body),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AurumColors.gold,
      contentPadding: EdgeInsets.zero,
    );
  }
}
