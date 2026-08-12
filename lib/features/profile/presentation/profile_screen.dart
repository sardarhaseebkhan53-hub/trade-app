import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/storage/first_launch_store.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.valueOrNull?.profile;

    return Scaffold(
      appBar: const AurumAppBar(title: 'Profile & Settings'),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          AurumCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AurumColors.surfaceElevated,
                  child: Icon(Icons.person_outline_rounded, color: AurumColors.gold, size: 28),
                ),
                const SizedBox(width: AurumSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.name ?? 'Guest Analyst', style: AurumTypography.h3),
                      Text(profile?.email ?? 'Not signed in', style: AurumTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const _SectionHeader('PREFERENCES'),
          _SettingTile(title: 'Price Alerts', subtitle: 'Manage price alerts', onTap: () => context.push('/alerts')),
          _SettingTile(title: 'Notifications', subtitle: 'Signal & market updates', onTap: () => context.push('/notifications')),
          const SizedBox(height: AurumSpacing.lg),
          const _SectionHeader('SECURITY'),
          _SettingTile(
            title: 'Security Center',
            subtitle: '2FA, sessions, biometric, App Lock & login history',
            onTap: () => context.push('/security'),
          ),
          _SettingTile(
            title: 'Privacy Center',
            subtitle: 'Data, controls, export & deletion',
            onTap: () => context.push('/privacy'),
          ),
          const SizedBox(height: AurumSpacing.sm),
          _SettingTile(
            title: 'Trade Journal',
            subtitle: 'Log trades, review performance',
            onTap: () => context.push('/journal'),
          ),
          const SizedBox(height: AurumSpacing.lg),
          const _SectionHeader('ACCOUNT'),
            if (profile != null && !profile.isGuest)
              Column(
                children: [
                  AurumButton(
                    label: 'Sign out',
                    variant: AurumButtonVariant.secondary,
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                  const SizedBox(height: AurumSpacing.sm),
                  TextButton(
                    onPressed: () async {
                      final biometric = ref.read(biometricServiceProvider);
                      await biometric.setBiometricEnabled(false);
                      await biometric.clearBiometricData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometric login disabled')),
                        );
                      }
                    },
                    child: const Text('Disable biometric login', style: TextStyle(color: AurumColors.textTertiary)),
                  ),
                ],
              )
            else
              AurumButton(
                label: 'Sign in to sync data',
                onPressed: () => context.push('/login'),
              ),
          const SizedBox(height: AurumSpacing.xxl),
          Center(
            child: Text(
              'AURUM • Analysis only. Not financial advice.',
              style: AurumTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),

          // Developer / Testing helper — visible only in debug
          if (const bool.fromEnvironment('dart.vm.product') == false) ...[
            const SizedBox(height: AurumSpacing.xxxl),
            const _SectionHeader('DEVELOPER TOOLS'),
            AurumCard(
              onTap: () async {
                final store = FirstLaunchStore();
                await store.resetSafetyFlowForTesting();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Safety & Privacy flow reset. Restart app or go to splash.')),
                  );
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.refresh, color: AurumColors.goldSoft),
                  SizedBox(width: AurumSpacing.md),
                  Expanded(child: Text('Reset First-Launch Safety Flow (for testing)', style: AurumTypography.label)),
                ],
              ),
            ),
          ],
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
        padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
        child: Text(label, style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.2)),
      );
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.title, required this.subtitle, required this.onTap, super.key});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AurumSpacing.md),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AurumTypography.label),
                Text(subtitle, style: AurumTypography.caption),
              ],
            )),
            const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
