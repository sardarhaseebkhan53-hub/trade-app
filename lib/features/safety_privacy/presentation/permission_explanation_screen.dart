import 'package:flutter/material.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import 'anti_scam_notice.dart';

class PermissionExplanationScreen extends StatelessWidget {
  const PermissionExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'Permissions'),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          const Text(
            'AURUM only requests permissions when they are actually needed for features you choose to use.',
            style: AurumTypography.bodyLarge,
          ),
          const SizedBox(height: AurumSpacing.xxl),

          _PermissionCard(
            title: 'Notifications',
            why: 'To deliver price alerts, signal notifications, and important security events you have enabled.',
            ifDenied: 'You will not receive alerts or security notifications from AURUM.',
          ),
          _PermissionCard(
            title: 'Biometric / Fingerprint / Face',
            why: 'To allow fast and secure unlock of your AURUM account on this device using your phone\'s secure hardware.',
            ifDenied: 'You can still use your password to log in.',
          ),

          const SizedBox(height: AurumSpacing.xxl),
          const AntiScamNotice(),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.why,
    required this.ifDenied,
  });

  final String title;
  final String why;
  final String ifDenied;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.md),
      child: AurumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.sm),
            Text('WHY WE NEED IT', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft)),
            Text(why, style: AurumTypography.body),
            const SizedBox(height: AurumSpacing.sm),
            Text('WHAT HAPPENS IF YOU DENY IT', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft)),
            Text(ifDenied, style: AurumTypography.body),
          ],
        ),
      ),
    );
  }
}
