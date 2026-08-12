import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';

class MiniChart extends StatelessWidget {
  const MiniChart({required this.points, required this.isPositive, super.key});
  final List<double> points;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 28,
        width: 62,
        child: CustomPaint(
          painter: _LinePainter(points: points, color: AurumColors.movement(isPositive)),
        ),
      ),
    );
  }
}

class MarketChart extends StatefulWidget {
  const MarketChart({required this.points, required this.timeframe, super.key});
  final List<double> points;
  final String timeframe;

  @override
  State<MarketChart> createState() => _MarketChartState();
}

class _MarketChartState extends State<MarketChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final selectedValue = _selectedIndex == null ? null : widget.points[_selectedIndex!];
    return Semantics(
      label: 'Market chart, ${widget.timeframe} range. Long press or drag to inspect values.',
      child: Container(
        height: 242,
        decoration: BoxDecoration(
          color: AurumColors.ink,
          border: Border.all(color: AurumColors.border),
          borderRadius: AurumRadius.card,
        ),
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.show_chart_rounded, color: AurumColors.gold, size: 16),
                const SizedBox(width: AurumSpacing.xs),
                Text('${widget.timeframe} price context', style: AurumTypography.label),
                const Spacer(),
                Text(
                  selectedValue == null ? 'Drag to inspect' : selectedValue.toStringAsFixed(2),
                  style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft),
                ),
              ],
            ),
            const SizedBox(height: AurumSpacing.sm),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    onPanDown: (DragDownDetails details) => _select(details.localPosition.dx, constraints.maxWidth),
                    onPanUpdate: (DragUpdateDetails details) => _select(details.localPosition.dx, constraints.maxWidth),
                    onPanEnd: (_) => setState(() => _selectedIndex = null),
                    child: CustomPaint(
                      painter: _MarketPainter(
                        points: widget.points,
                        selectedIndex: _selectedIndex,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AurumSpacing.xs),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Start', style: AurumTypography.caption),
                Text('Mid range', style: AurumTypography.caption),
                Text('Now', style: AurumTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _select(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    setState(() => _selectedIndex = (fraction * (widget.points.length - 1)).round());
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.points, required this.color});
  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final range = _range(points);
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = (index / (points.length - 1)) * size.width;
      final y = size.height - ((points[index] - range.min) / range.delta * size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.7..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => oldDelegate.points != points || oldDelegate.color != color;
}

class _MarketPainter extends CustomPainter {
  const _MarketPainter({required this.points, this.selectedIndex});
  final List<double> points;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final gridPaint = Paint()..color = AurumColors.border.withValues(alpha: 0.7)..strokeWidth = 1;
    for (var step = 1; step < 4; step++) {
      final y = size.height / 4 * step;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final range = _range(points);
    final path = Path();
    final fill = Path();
    for (var index = 0; index < points.length; index++) {
      final x = (index / (points.length - 1)) * size.width;
      final y = size.height - ((points[index] - range.min) / range.delta * size.height);
      if (index == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();
    canvas.drawPath(fill, Paint()..color = AurumColors.positive.withValues(alpha: 0.08));
    canvas.drawPath(path, Paint()..color = AurumColors.positive..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    if (selectedIndex != null) {
      final x = (selectedIndex! / (points.length - 1)) * size.width;
      final y = size.height - ((points[selectedIndex!] - range.min) / range.delta * size.height);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = AurumColors.gold.withValues(alpha: 0.65)..strokeWidth = 1);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AurumColors.gold);
      canvas.drawCircle(Offset(x, y), 7, Paint()..color = AurumColors.gold.withValues(alpha: 0.22));
    }
  }

  @override
  bool shouldRepaint(covariant _MarketPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.selectedIndex != selectedIndex;
}

({double min, double delta}) _range(List<double> points) {
  final min = points.reduce((double a, double b) => a < b ? a : b);
  final max = points.reduce((double a, double b) => a > b ? a : b);
  final delta = (max - min).abs();
  return (
    min: min - (delta == 0 ? 1 : delta * 0.08),
    delta: delta == 0 ? 1 : delta * 1.16,
  );
}
