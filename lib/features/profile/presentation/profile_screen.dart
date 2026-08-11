import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_radius.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).valueOrNull?.profile ?? const AurumProfile(name: 'Guest analyst', email: '', isGuest: true, currency: 'USD', reducedMotion: false);
    return Scaffold(
      appBar: const AurumAppBar(title: 'Profile & settings'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
          children: <Widget>[
            _AccountCard(profile: profile, onTap: () => profile.isGuest ? context.push('/login') : null),
            const SizedBox(height: AurumSpacing.xxl),
            const _SettingsHeading(label: 'PREFERENCES'),
            const SizedBox(height: AurumSpacing.xs),
            _SettingTile(icon: Icons.tune_rounded, title: 'Preferences', subtitle: '${profile.currency} quote currency', onTap: () => _showMessage(context, 'Preferences')),
            _SettingTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Signal, price and market updates', onTap: () => context.push('/notifications')),
            _SettingTile(icon: Icons.add_alert_outlined, title: 'Price alerts', subtitle: 'Create and manage above or below alerts', onTap: () => context.push('/alerts')),
            _SettingTile(icon: Icons.dark_mode_outlined, title: 'Appearance', subtitle: 'Obsidian dark theme', onTap: () => _showMessage(context, 'Appearance')),
            const SizedBox(height: AurumSpacing.lg),
            const _SettingsHeading(label: 'ACCOUNT & SECURITY'),
            const SizedBox(height: AurumSpacing.xs),
            _SettingTile(icon: Icons.shield_outlined, title: 'Security', subtitle: 'Session and sign-in controls', onTap: () => _showMessage(context, 'Security')),
            _SettingTile(icon: Icons.lock_outline_rounded, title: 'Privacy & data', subtitle: 'Consent, data and analysis controls', onTap: () => _showMessage(context, 'Privacy & data')),
            const SizedBox(height: AurumSpacing.lg),
            const _SettingsHeading(label: 'ABOUT'),
            const SizedBox(height: AurumSpacing.xs),
            _SettingTile(icon: Icons.info_outline_rounded, title: 'About AURUM', subtitle: 'Phase 3 demo • Market analysis workspace', onTap: () => _showMessage(context, 'About AURUM')),
            const SizedBox(height: AurumSpacing.xxl),
            if (profile.isGuest)
              AurumButton(label: 'Sign in to sync your workspace', icon: Icons.login_rounded, onPressed: () => context.push('/login'))
            else
              AurumButton(label: 'Sign out', icon: Icons.logout_rounded, variant: AurumButtonVariant.secondary, onPressed: () async { await ref.read(authControllerProvider.notifier).signOut(); if (context.mounted) context.go('/login'); }),
            const SizedBox(height: AurumSpacing.lg),
            const Center(child: Text('AURUM • Demo data • Analysis only, not financial advice', textAlign: TextAlign.center, style: AurumTypography.caption)),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title settings are ready for Phase 6 persistence.')));
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile, this.onTap});
  final AurumProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AurumCard(
    onTap: onTap,
    child: Row(children: <Widget>[
      Container(width: 52, height: 52, decoration: const BoxDecoration(color: AurumColors.ink, shape: BoxShape.circle), child: const Icon(Icons.person_outline_rounded, color: AurumColors.gold, size: 26)),
      const SizedBox(width: AurumSpacing.sm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(profile.name, style: AurumTypography.h3), const SizedBox(height: AurumSpacing.xxs), Text(profile.isGuest ? 'Guest workspace • Sign in to sync' : profile.email, style: AurumTypography.body)])),
      Icon(profile.isGuest ? Icons.login_rounded : Icons.chevron_right_rounded, color: AurumColors.goldSoft),
    ]),
  );
}

class _SettingsHeading extends StatelessWidget {
  const _SettingsHeading({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Text(label, style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.2));
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AurumSpacing.xs),
    decoration: BoxDecoration(color: AurumColors.card, border: Border.all(color: AurumColors.border), borderRadius: AurumRadius.card),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AurumColors.goldSoft),
      title: Text(title, style: AurumTypography.label.copyWith(color: AurumColors.textPrimary)),
      subtitle: Text(subtitle, style: AurumTypography.caption),
      trailing: const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
    ),
  );
}
