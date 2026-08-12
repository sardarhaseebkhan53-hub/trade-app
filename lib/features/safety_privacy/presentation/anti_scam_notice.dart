import 'package:flutter/material.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class AntiScamNotice extends StatelessWidget {
  const AntiScamNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      color: AurumColors.warning.withValues(alpha: 0.08),
      borderColor: AurumColors.warning.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gpp_maybe_outlined, color: AurumColors.warning),
              const SizedBox(width: AurumSpacing.sm),
              Text('AURUM will NEVER ask for:', style: AurumTypography.h3.copyWith(color: AurumColors.warning)),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          const Text('• Your seed phrase or private keys\n• Your password or recovery codes\n• Authentication codes outside the official app\n• Money or cryptocurrency to any address'),
          const SizedBox(height: AurumSpacing.sm),
          const Text(
            'If anyone claiming to be from AURUM asks for any of the above, it is a scam. Report it immediately.',
            style: AurumTypography.caption,
          ),
        ],
      ),
    );
  }
}
