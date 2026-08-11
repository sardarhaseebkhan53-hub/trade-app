import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import 'aurum_primitives.dart';

class AurumBottomSheet extends StatelessWidget {
  const AurumBottomSheet({required this.title, required this.child, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xl),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AurumColors.borderStrong, borderRadius: AurumRadius.pill))),
        const SizedBox(height: AurumSpacing.lg),
        Text(title, style: AurumTypography.h2),
        const SizedBox(height: AurumSpacing.lg),
        child,
      ]),
    ),
  );
}

class AurumConfirmationDialog extends StatelessWidget {
  const AurumConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    super.key,
    this.cancelLabel = 'Cancel',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AurumColors.surface,
    title: Text(title, style: AurumTypography.h2),
    content: Text(message, style: AurumTypography.body),
    actionsPadding: const EdgeInsets.fromLTRB(AurumSpacing.md, 0, AurumSpacing.md, AurumSpacing.md),
    actions: <Widget>[
      AurumButton(label: cancelLabel, variant: AurumButtonVariant.text, expand: false, onPressed: () => Navigator.of(context).pop()),
      AurumButton(label: confirmLabel, expand: false, onPressed: onConfirm),
    ],
  );
}
