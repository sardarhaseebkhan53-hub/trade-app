import 'package:flutter/material.dart';

import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'Two-Factor Authentication'),
      body: Padding(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enhance your account security with 2FA (TOTP).', style: AurumTypography.bodyLarge),
            const SizedBox(height: AurumSpacing.xl),
            AurumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: Disabled', style: AurumTypography.h3),
                  const SizedBox(height: AurumSpacing.sm),
                  const Text('Use an authenticator app (Google Authenticator, Authy, etc.).'),
                  const SizedBox(height: AurumSpacing.lg),
                  AurumButton(
                    label: 'Enable 2FA (Coming Soon)',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('2FA setup will be available in a future update.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
