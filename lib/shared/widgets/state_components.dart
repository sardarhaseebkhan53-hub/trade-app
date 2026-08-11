import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import 'aurum_primitives.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.height = 72, this.width = double.infinity});
  final double height;
  final double width;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.of(context).disableAnimations;
    if (disableMotion) return _buildBox(0.65);
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => _buildBox(0.45 + (_controller.value * 0.28)),
    );
  }

  Widget _buildBox(double opacity) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AurumColors.surfaceElevated.withOpacity(opacity),
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AurumSpacing.lg),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
      itemBuilder: (_, __) => const LoadingSkeleton(height: 82),
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
          children: <Widget>[
            Icon(icon, color: AurumColors.gold, size: 36),
            const SizedBox(height: AurumSpacing.md),
            Text(title, textAlign: TextAlign.center, style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.xs),
            Text(message, textAlign: TextAlign.center, style: AurumTypography.body),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: AurumSpacing.lg),
              AurumButton(label: actionLabel!, onPressed: onAction, expand: false),
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
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AurumSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_outlined, color: AurumColors.warning, size: 36),
            const SizedBox(height: AurumSpacing.md),
            Text(title, textAlign: TextAlign.center, style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.xs),
            Text(message, textAlign: TextAlign.center, style: AurumTypography.body),
            const SizedBox(height: AurumSpacing.lg),
            AurumButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}
