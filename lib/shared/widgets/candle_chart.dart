import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_typography.dart';
import '../models/market_data_models.dart';

class CandleChart extends StatefulWidget {
  const CandleChart({
    required this.candles,
    required this.timeframe,
    this.support,
    this.resistance,
    super.key,
  });

  final List<OHLCData> candles;
  final String timeframe;
  final double? support;
  final double? resistance;

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final selected = _selected == null || _selected! >= widget.candles.length
        ? null
        : widget.candles[_selected!];
    return Semantics(
      label: 'Candlestick chart ${widget.timeframe}. Drag to inspect OHLC.',
      child: Container(
        height: 280,
        color: AurumColors.ink,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected != null)
              Text(
                'O ${selected.open.toStringAsFixed(2)}  H ${selected.high.toStringAsFixed(2)}  L ${selected.low.toStringAsFixed(2)}  C ${selected.close.toStringAsFixed(2)}',
                style: AurumTypography.caption.copyWith(fontFamily: 'monospace'),
              )
            else
              Text(widget.timeframe, style: AurumTypography.caption),
            const SizedBox(height: 6),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanDown: (details) => _pick(details.localPosition.dx, constraints.maxWidth),
                    onPanUpdate: (details) => _pick(details.localPosition.dx, constraints.maxWidth),
                    onPanEnd: (_) => setState(() => _selected = null),
                    child: CustomPaint(
                      painter: _CandlePainter(
                        candles: widget.candles,
                        selected: _selected,
                        support: widget.support,
                        resistance: widget.resistance,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pick(double dx, double width) {
    if (widget.candles.isEmpty) return;
    final fraction = (dx / width).clamp(0.0, 1.0);
    setState(() => _selected = (fraction * (widget.candles.length - 1)).round());
  }
}

class _CandlePainter extends CustomPainter {
  const _CandlePainter({
    required this.candles,
    required this.selected,
    this.support,
    this.resistance,
  });

  final List<OHLCData> candles;
  final int? selected;
  final double? support;
  final double? resistance;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    final lows = candles.map((c) => c.low);
    final highs = candles.map((c) => c.high);
    var minV = lows.reduce((a, b) => a < b ? a : b);
    var maxV = highs.reduce((a, b) => a > b ? a : b);
    if (support != null) minV = minV < support! ? minV : support!;
    if (resistance != null) maxV = maxV > resistance! ? maxV : resistance!;
    final pad = (maxV - minV).abs() * 0.08;
    minV -= pad == 0 ? 1 : pad;
    maxV += pad == 0 ? 1 : pad;
    final range = maxV - minV;
    final volumeH = size.height * 0.22;
    final plotH = size.height - volumeH - 4;

    final grid = Paint()
      ..color = AurumColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = plotH / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    double yFor(double price) => plotH - ((price - minV) / range * plotH);
    final slot = size.width / candles.length;
    final bodyW = (slot * 0.62).clamp(1.5, 8.0);

    var maxVol = 1.0;
    for (final c in candles) {
      final v = c.volume ?? (c.high - c.low).abs();
      if (v > maxVol) maxVol = v;
    }

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = slot * i + slot / 2;
      final up = c.close >= c.open;
      final color = up ? AurumColors.positive : AurumColors.negative;
      final paint = Paint()..color = color..strokeWidth = 1;
      canvas.drawLine(Offset(x, yFor(c.high)), Offset(x, yFor(c.low)), paint);
      final top = yFor(up ? c.close : c.open);
      final bottom = yFor(up ? c.open : c.close);
      canvas.drawRect(
        Rect.fromLTRB(x - bodyW / 2, top, x + bodyW / 2, bottom == top ? top + 1 : bottom),
        Paint()..color = color,
      );
      final vol = c.volume ?? (c.high - c.low).abs();
      final vh = (vol / maxVol) * volumeH;
      canvas.drawRect(
        Rect.fromLTWH(x - bodyW / 2, size.height - vh, bodyW, vh),
        Paint()..color = color.withValues(alpha: 0.35),
      );
    }

    if (support != null) {
      final y = yFor(support!);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = AurumColors.positive.withValues(alpha: 0.7)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
    if (resistance != null) {
      final y = yFor(resistance!);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = AurumColors.negative.withValues(alpha: 0.7)
          ..strokeWidth = 1,
      );
    }

    if (selected != null) {
      final x = slot * selected! + slot / 2;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()..color = AurumColors.gold.withValues(alpha: 0.55)..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.candles != candles || oldDelegate.selected != selected;
}
