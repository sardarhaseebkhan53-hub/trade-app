import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import 'aurum_primitives.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({required this.height, super.key, this.width});

  final double height;
  final double? width;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AurumColors.surfaceElevated.withOpacity(0.6 + _controller.value * 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  const LoadingList({required this.count, super.key, this.itemHeight = 76});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AurumSpacing.lg),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
      itemBuilder: (_, __) => LoadingSkeleton(height: itemHeight),
    );
  }
}

class AurumEmptyState extends StatelessWidget {
  const AurumEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AurumSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AurumColors.textTertiary),
            const SizedBox(height: AurumSpacing.lg),
            Text(title, style: AurumTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: AurumSpacing.xs),
            Text(
              message,
              style: AurumTypography.body,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AurumSpacing.xl),
              AurumButton(
                label: actionLabel!,
                variant: AurumButtonVariant.secondary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AurumErrorState extends StatelessWidget {
  const AurumErrorState({
    required this.title,
    required this.message,
    super.key,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AurumSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AurumColors.negative),
            const SizedBox(height: AurumSpacing.lg),
            Text(title, style: AurumTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: AurumSpacing.sm),
            Text(message, style: AurumTypography.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AurumSpacing.xl),
              AurumButton(label: 'Try again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
