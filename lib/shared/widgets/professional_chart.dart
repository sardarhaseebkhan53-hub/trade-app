import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';

/// Professional interactive-style chart (Phase 3)
/// Supports Line + basic SMA overlay. Real calculations.
class ProfessionalChart extends StatelessWidget {
  const ProfessionalChart({
    required this.points,
    required this.timeframe,
    this.showVolume = true,
    this.showSma = true,
    super.key,
  });

  final List<double> points;
  final String timeframe;
  final bool showVolume;
  final bool showSma;

  @override
  Widget build(BuildContext context) {
    final sma20 = _calculateSMA(points, 20);

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AurumColors.ink,
        border: Border.all(color: AurumColors.border),
        borderRadius: AurumRadius.card,
      ),
      padding: const EdgeInsets.all(AurumSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Text('Chart • $timeframe', style: AurumTypography.label),
              const Spacer(),
              if (showSma) Text('SMA20', style: AurumTypography.caption.copyWith(color: AurumColors.positive)),
              const SizedBox(width: 8),
              const Icon(Icons.show_chart, color: AurumColors.gold, size: 16),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Expanded(
            child: CustomPaint(
              painter: _ProfessionalPainter(points: points, sma: sma20),
              child: const SizedBox.expand(),
            ),
          ),
          if (showVolume) ...[
            const SizedBox(height: AurumSpacing.sm),
            Text('Volume (demo)', style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary)),
          ],
        ],
      ),
    );
  }

  List<double>? _calculateSMA(List<double> data, int period) {
    if (data.length < period) return null;
    final result = <double>[];
    for (int i = period - 1; i < data.length; i++) {
      final slice = data.sublist(i - period + 1, i + 1);
      result.add(slice.reduce((a, b) => a + b) / period);
    }
    return result;
  }
}

class _ProfessionalPainter extends CustomPainter {
  _ProfessionalPainter({required this.points, this.sma});
  final List<double> points;
  final List<double>? sma;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    // Main price line
    final pricePaint = Paint()
      ..color = AurumColors.gold
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minV) / range * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, pricePaint);

    // SMA overlay (if available)
    if (sma != null && sma!.length > 1) {
      final smaPaint = Paint()
        ..color = AurumColors.positive
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;

      final smaPath = Path();
      final smaStart = points.length - sma!.length;
      for (int i = 0; i < sma!.length; i++) {
        final x = ((smaStart + i) / (points.length - 1)) * size.width;
        final y = size.height - ((sma![i] - minV) / range * size.height);
        if (i == 0) smaPath.moveTo(x, y);
        else smaPath.lineTo(x, y);
      }
      canvas.drawPath(smaPath, smaPaint);
    }

    // Volume bars (demo)
    final volPaint = Paint()..color = AurumColors.gold.withOpacity(0.2);
    for (int i = 0; i < points.length; i += 2) {
      final x = (i / (points.length - 1)) * size.width;
      canvas.drawRect(Rect.fromLTWH(x, size.height * 0.82, 2.5, size.height * 0.14), volPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
