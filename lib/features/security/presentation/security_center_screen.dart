import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/storage/app_lock_service.dart';
import '../../../core/storage/biometric_service.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class SecurityCenterScreen extends ConsumerWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricServiceProvider);

    // Mock data for first-launch compliant demo (would come from backend in prod)
    final activeDevices = [
      _DeviceInfo(
        id: 'dev-1',
        name: 'iPhone 15 Pro',
        lastActive: 'Just now',
        location: 'Attock, PK',
        isCurrent: true,
      ),
      _DeviceInfo(
        id: 'dev-2',
        name: 'MacBook Pro',
        lastActive: '2h ago',
        location: 'Lahore, PK',
        isCurrent: false,
      ),
      _DeviceInfo(
        id: 'dev-3',
        name: 'Android Pixel 8',
        lastActive: 'Yesterday',
        location: 'Unknown',
        isCurrent: false,
      ),
    ];

    final securityEvents = [
      _SecurityEvent(
        time: 'Today 09:41',
        type: 'Login',
        device: 'iPhone 15 Pro',
        location: 'Attock, PK',
        status: 'Success',
      ),
      _SecurityEvent(
        time: 'Yesterday 22:14',
        type: 'Login',
        device: 'MacBook Pro',
        location: 'Lahore, PK',
        status: 'Success',
      ),
      _SecurityEvent(
        time: 'Aug 9 14:02',
        type: 'Password Changed',
        device: 'iPhone 15 Pro',
        location: 'Attock, PK',
        status: 'Success',
      ),
      _SecurityEvent(
        time: 'Aug 5 11:30',
        type: 'Failed Login Attempt',
        device: 'Unknown',
        location: 'Unknown',
        status: 'Blocked',
      ),
    ];

    return Scaffold(
      appBar: const AurumAppBar(title: 'Security Center'),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          _SectionHeader('ACCOUNT SECURITY'),
          _SecurityTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change flow coming soon')),
              );
            },
          ),
          FutureBuilder<bool>(
            future: biometric.isBiometricEnabled(),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return _SecurityTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: enabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: enabled,
                  activeColor: AurumColors.gold,
                  onChanged: (val) async {
                    await biometric.setBiometricEnabled(val);
                    if (val) {
                      await biometric.storeBiometricToken('biometric-session');
                    } else {
                      await biometric.clearBiometricData();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Biometric enabled' : 'Biometric disabled')),
                      );
                    }
                  },
                ),
              );
            },
          ),

          // App Lock (V3 configurable)
          _buildAppLockSection(context),

          _SecurityTile(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Coming soon',
            onTap: () => context.push('/security/2fa'),
          ),
          const SizedBox(height: AurumSpacing.lg),

          // === ACTIVE DEVICES (Enhanced per security prompt) ===
          _SectionHeader('ACTIVE DEVICES'),
          ...activeDevices.map((device) => _ActiveDeviceTile(
                device: device,
                onSignOut: device.isCurrent
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Signed out ${device.name}')),
                        );
                      },
              )),
          const SizedBox(height: AurumSpacing.sm),
          AurumButton(
            label: 'SIGN OUT ALL OTHER DEVICES',
            variant: AurumButtonVariant.secondary,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),

          const SizedBox(height: AurumSpacing.lg),

          // === LOGIN HISTORY & SECURITY EVENTS (Enhanced) ===
          _SectionHeader('SECURITY EVENTS & LOGIN HISTORY'),
          ...securityEvents.map((e) => _SecurityEventTile(event: e)),

          const SizedBox(height: AurumSpacing.lg),
          _SectionHeader('CONNECTED ACCOUNTS'),
          _SecurityTile(
            icon: Icons.account_circle,
            title: 'Google Account',
            subtitle: 'Connected',
            onTap: () {},
          ),
          const SizedBox(height: AurumSpacing.xl),

          AurumButton(
            label: 'Sign out all devices',
            variant: AurumButtonVariant.secondary,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: AurumSpacing.md),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requires support contact.')),
              );
            },
            child: const Text('Delete Account', style: TextStyle(color: AurumColors.negative)),
          ),
        ],
      ),
    );
  }
}

// Simple internal models for demo (production: backend-backed)
class _DeviceInfo {
  const _DeviceInfo({
    required this.id,
    required this.name,
    required this.lastActive,
    required this.location,
    required this.isCurrent,
  });
  final String id;
  final String name;
  final String lastActive;
  final String location;
  final bool isCurrent;
}

class _SecurityEvent {
  const _SecurityEvent({
    required this.time,
    required this.type,
    required this.device,
    required this.location,
    required this.status,
  });
  final String time;
  final String type;
  final String device;
  final String location;
  final String status;
}

class _ActiveDeviceTile extends StatelessWidget {
  const _ActiveDeviceTile({
    required this.device,
    this.onSignOut,
    super.key,
  });

  final _DeviceInfo device;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        padding: const EdgeInsets.all(AurumSpacing.md),
        child: Row(
          children: [
            Icon(
              device.isCurrent ? Icons.phone_android : Icons.devices,
              color: AurumColors.goldSoft,
            ),
            const SizedBox(width: AurumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(device.name, style: AurumTypography.label),
                      if (device.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: AurumColors.positive.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('THIS DEVICE', style: AurumTypography.caption.copyWith(color: AurumColors.positive, fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${device.lastActive} • ${device.location}', style: AurumTypography.caption),
                ],
              ),
            ),
            if (onSignOut != null)
              TextButton(
                onPressed: onSignOut,
                style: TextButton.styleFrom(foregroundColor: AurumColors.negative),
                child: const Text('Sign out'),
              )
            else
              const Icon(Icons.check_circle, color: AurumColors.positive, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SecurityEventTile extends StatelessWidget {
  const _SecurityEventTile({required this.event, super.key});

  final _SecurityEvent event;

  @override
  Widget build(BuildContext context) {
    final isBlocked = event.status.toLowerCase().contains('block');
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: AurumCard(
        padding: const EdgeInsets.all(AurumSpacing.md),
        child: Row(
          children: [
            Icon(
              isBlocked ? Icons.block : Icons.history,
              color: isBlocked ? AurumColors.negative : AurumColors.goldSoft,
              size: 20,
            ),
            const SizedBox(width: AurumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.type, style: AurumTypography.label),
                  Text('${event.time} • ${event.device}', style: AurumTypography.caption),
                  if (event.location.isNotEmpty)
                    Text(event.location, style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: (isBlocked ? AurumColors.negative : AurumColors.positive).withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                event.status,
                style: AurumTypography.caption.copyWith(
                  color: isBlocked ? AurumColors.negative : AurumColors.positive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AurumSpacing.sm, top: AurumSpacing.sm),
    child: Text(label, style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.2)),
  );
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AurumSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AurumColors.goldSoft),
          const SizedBox(width: AurumSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AurumTypography.label),
                if (subtitle != null) Text(subtitle!, style: AurumTypography.caption),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
        ],
      ),
    );
  }
}

// === V3 App Lock Configurable Section ===
Widget _buildAppLockSection(BuildContext context) {
  final lockService = AppLockService();

  return FutureBuilder<bool>(
    future: lockService.isAppLockEnabled(),
    builder: (context, enabledSnap) {
      final enabled = enabledSnap.data ?? false;

      return FutureBuilder<AppLockTimeout>(
        future: lockService.getTimeout(),
        builder: (context, timeoutSnap) {
          final currentTimeout = timeoutSnap.data ?? AppLockTimeout.oneMinute;

          return Padding(
            padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
            child: AurumCard(
              padding: const EdgeInsets.all(AurumSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AurumColors.goldSoft),
                      const SizedBox(width: AurumSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('App Lock', style: AurumTypography.label),
                            Text(
                              enabled ? 'Protects app after background timeout' : 'Disabled',
                              style: AurumTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: enabled,
                        activeColor: AurumColors.gold,
                        onChanged: (val) async {
                          await lockService.setAppLockEnabled(val);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(val ? 'App Lock enabled' : 'App Lock disabled')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (enabled) ...[
                    const SizedBox(height: AurumSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AurumSpacing.sm),
                    Text('LOCK AFTER', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft)),
                    const SizedBox(height: AurumSpacing.xs),
                    Wrap(
                      spacing: 8,
                      children: AppLockTimeout.values.map((t) {
                        final selected = t == currentTimeout;
                        return ChoiceChip(
                          label: Text(t.displayName),
                          selected: selected,
                          onSelected: (_) async {
                            await lockService.setTimeout(t);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('App Lock timeout set to ${t.displayName}')),
                              );
                            }
                          },
                          selectedColor: AurumColors.gold.withOpacity(0.2),
                          labelStyle: AurumTypography.caption.copyWith(
                            color: selected ? AurumColors.gold : AurumColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
