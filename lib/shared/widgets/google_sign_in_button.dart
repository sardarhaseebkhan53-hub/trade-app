import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AurumColors.surface,
          side: const BorderSide(color: AurumColors.border),
          shape: RoundedRectangleBorder(borderRadius: AurumRadius.control),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AurumColors.textPrimary),
              )
            else ...[
              // Simple Google "G" icon using text for no-asset dependency
              const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AurumColors.gold)),
              const SizedBox(width: AurumSpacing.sm),
              Text(
                'Continue with Google',
                style: AurumTypography.label.copyWith(color: AurumColors.textPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
