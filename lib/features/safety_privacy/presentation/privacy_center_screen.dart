import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

/// Privacy Center (V3 requirement)
/// Shows what data is stored, user controls, rights, and policies.
class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'Privacy Center'),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          const Text(
            'You control your data. AURUM collects the minimum required to provide market intelligence.',
            style: AurumTypography.bodyLarge,
          ),
          const SizedBox(height: AurumSpacing.xxl),

          _SectionHeader('WHAT WE STORE'),
          _PrivacyCard(
            title: 'Account & Authentication',
            items: const [
              'Email, name (you provide)',
              'Password hash (Argon2id — never plaintext)',
              'Session tokens (hashed on server)',
            ],
          ),
          _PrivacyCard(
            title: 'Usage Data',
            items: const [
              'Watchlists & alerts you create',
              'AI conversation history (if you use AI Analyst)',
              'Notification preferences',
              'Security events (logins, device activity)',
            ],
          ),
          _PrivacyCard(
            title: 'Device Data',
            items: const [
              'Device registration for push (if enabled)',
              'Biometric setting (local flag only)',
            ],
          ),

          const SizedBox(height: AurumSpacing.lg),
          _SectionHeader('RETENTION'),
          AurumCard(
            child: const Text(
              '• Account data: retained while account is active\n'
              '• AI history: 90 days (configurable)\n'
              '• Security events: 1 year\n'
              '• Notifications: 30 days\n\n'
              'You can request deletion at any time.',
              style: AurumTypography.body,
            ),
          ),

          const SizedBox(height: AurumSpacing.lg),
          _SectionHeader('CONTROLS'),
          _PrivacyActionTile(
            icon: Icons.download_outlined,
            title: 'Export My Data',
            subtitle: 'Download a copy of your data',
            onTap: () => _showComingSoon(context),
          ),
          _PrivacyActionTile(
            icon: Icons.notifications_none,
            title: 'Notification Preferences',
            subtitle: 'Manage what you receive',
            onTap: () => context.push('/notifications'),
          ),
          _PrivacyActionTile(
            icon: Icons.auto_awesome_outlined,
            title: 'AI History',
            subtitle: 'Review or clear AI conversations',
            onTap: () => context.push('/ai-history'),
          ),

          const SizedBox(height: AurumSpacing.lg),
          _SectionHeader('YOUR RIGHTS'),
          _PrivacyActionTile(
            icon: Icons.delete_outline,
            title: 'Delete My Account',
            subtitle: 'Permanently remove your data',
            onTap: () => _showDeleteAccount(context),
            destructive: true,
          ),

          const SizedBox(height: AurumSpacing.xl),
          const AntiScamNotice(),

          const SizedBox(height: AurumSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.push('/legal'),
              child: const Text('View full Privacy Policy & Terms'),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export will be available soon.')),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and data.\n\n'
          'Some security records may be retained for legal compliance for up to 1 year.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In production this would call backend delete + local clear
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: AurumColors.negative),
            child: const Text('DELETE ACCOUNT'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AurumSpacing.sm, top: AurumSpacing.md),
        child: Text(label, style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.1)),
      );
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.title, required this.items, super.key});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AurumTypography.label),
            const SizedBox(height: AurumSpacing.xs),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: AurumTypography.caption),
                      Expanded(child: Text(i, style: AurumTypography.caption)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PrivacyActionTile extends StatelessWidget {
  const _PrivacyActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: destructive ? AurumColors.negative : AurumColors.goldSoft),
            const SizedBox(width: AurumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AurumTypography.label.copyWith(color: destructive ? AurumColors.negative : null)),
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

// Re-use existing AntiScamNotice
class AntiScamNotice extends StatelessWidget {
  const AntiScamNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      color: AurumColors.warning.withOpacity(0.06),
      borderColor: AurumColors.warning.withOpacity(0.25),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: AurumColors.warning),
          SizedBox(width: AurumSpacing.sm),
          Expanded(
            child: Text(
              'AURUM will never ask for your seed phrase, private key, password, or recovery codes.',
              style: AurumTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}