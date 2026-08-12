import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import '../../domain/data_integrity.dart';

export '../../domain/data_integrity.dart' show DataFreshness;

class DataFreshnessIndicator extends StatelessWidget {
  const DataFreshnessIndicator({
    required this.freshness,
    required this.lastUpdated,
    super.key,
  });

  final DataFreshness freshness;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (freshness) {
      DataFreshness.live => ('LIVE', AurumColors.positive, Icons.check_circle),
      DataFreshness.delayed => ('DELAYED', AurumColors.warning, Icons.access_time),
      DataFreshness.stale => ('STALE DATA', AurumColors.negative, Icons.warning_amber),
      DataFreshness.offline => ('OFFLINE', AurumColors.textTertiary, Icons.cloud_off),
    };

    final timeText = lastUpdated != null
        ? 'Updated ${_formatTime(lastUpdated!)}'
        : 'No timestamp available';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AurumTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(timeText, style: AurumTypography.caption),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
