import 'dart:math' as math;

import '../../../domain/market_entities.dart';
import '../../../shared/models/market_data_models.dart';

/// Lightweight technical analysis (moved into domain layer for Phase 6+)
class TechnicalAnalysisService {
  const TechnicalAnalysisService();

  Map<String, dynamic> analyze(List<double> closes, {int rsiPeriod = 14}) {
    if (closes.length < 20) {
      return {'trend': 'INSUFFICIENT_DATA', 'strength': 0};
    }

    final sma20 = _sma(closes, 20);
    final sma50 = _sma(closes, 50);
    final rsi = _rsi(closes, rsiPeriod);

    String trend = 'NEUTRAL';
    if (sma20 != null && sma50 != null) {
      trend = closes.last > sma20 && sma20 > sma50 ? 'BULLISH' : 'BEARISH';
    }

    final strength = (rsi != null && rsi > 55) ? 68 : 52;

    return {
      'trend': trend,
      'rsi': rsi,
      'strength': strength,
      'support': closes.reduce(math.min),
      'resistance': closes.reduce(math.max),
    };
  }

  double? _sma(List<double> values, int period) {
    if (values.length < period) return null;
    return values.sublist(values.length - period).reduce((a, b) => a + b) / period;
  }

  double? _rsi(List<double> values, int period) {
    if (values.length <= period) return null;
    double gains = 0, losses = 0;
    for (int i = values.length - period; i < values.length; i++) {
      final delta = values[i] - values[i - 1];
      if (delta > 0) gains += delta; else losses -= delta;
    }
    if (losses == 0) return 100;
    final rs = gains / losses;
    return 100 - (100 / (1 + rs));
  }
}
