import 'dart:math' as math;

import '../../../shared/models/market_data_models.dart';
import '../domain/analysis_models.dart';

class TechnicalSnapshot {
  const TechnicalSnapshot({
    required this.dataPoints,
    required this.lastPrice,
    required this.sma20,
    required this.sma50,
    required this.sma100,
    required this.sma200,
    required this.ema20,
    required this.ema50,
    required this.rsi,
    required this.macd,
    required this.volume,
    required this.volatility,
    required this.structure,
  });

  final int dataPoints;
  final double? lastPrice;
  final MovingAverageResult sma20;
  final MovingAverageResult sma50;
  final MovingAverageResult sma100;
  final MovingAverageResult sma200;
  final MovingAverageResult ema20;
  final MovingAverageResult ema50;
  final RsiResult rsi;
  final MacdResult macd;
  final VolumeAnalysis volume;
  final VolatilityAnalysis volatility;
  final PriceStructure structure;
}

/// Pure calculations only. This service never touches Flutter widgets or HTTP.
class TechnicalAnalysisService {
  const TechnicalAnalysisService();

  TechnicalSnapshot evaluate(ChartSeries series) {
    final closes = series.closeValues.where((double value) => value.isFinite && value > 0).toList(growable: false);
    return TechnicalSnapshot(
      dataPoints: closes.length,
      lastPrice: closes.isEmpty ? null : closes.last,
      sma20: MovingAverageResult(period: 20, type: 'SMA', value: latestSma(closes, 20)),
      sma50: MovingAverageResult(period: 50, type: 'SMA', value: latestSma(closes, 50)),
      sma100: MovingAverageResult(period: 100, type: 'SMA', value: latestSma(closes, 100)),
      sma200: MovingAverageResult(period: 200, type: 'SMA', value: latestSma(closes, 200)),
      ema20: MovingAverageResult(period: 20, type: 'EMA', value: latestEma(closes, 20)),
      ema50: MovingAverageResult(period: 50, type: 'EMA', value: latestEma(closes, 50)),
      rsi: rsi(closes),
      macd: macd(closes),
      volume: volume(series.volumes),
      volatility: volatility(closes),
      structure: priceStructure(closes),
    );
  }

  List<double?> smaSeries(List<double> values, int period) {
    if (period <= 0) throw ArgumentError.value(period, 'period', 'Must be positive.');
    final result = List<double?>.filled(values.length, null);
    if (values.length < period) return result;
    var sum = 0.0;
    for (var index = 0; index < values.length; index++) {
      sum += values[index];
      if (index >= period) sum -= values[index - period];
      if (index >= period - 1) result[index] = sum / period;
    }
    return result;
  }

  double? latestSma(List<double> values, int period) =>
      smaSeries(values, period).lastWhere((double? value) => value != null, orElse: () => null);

  List<double?> emaSeries(List<double> values, int period) {
    if (period <= 0) throw ArgumentError.value(period, 'period', 'Must be positive.');
    final result = List<double?>.filled(values.length, null);
    if (values.length < period) return result;
    final seed = values.take(period).reduce((double a, double b) => a + b) / period;
    result[period - 1] = seed;
    final multiplier = 2 / (period + 1);
    var previous = seed;
    for (var index = period; index < values.length; index++) {
      previous = ((values[index] - previous) * multiplier) + previous;
      result[index] = previous;
    }
    return result;
  }

  double? latestEma(List<double> values, int period) =>
      emaSeries(values, period).lastWhere((double? value) => value != null, orElse: () => null);

  RsiResult rsi(List<double> values, {int period = 14}) {
    final history = List<double?>.filled(values.length, null);
    if (values.length <= period) {
      return RsiResult(value: null, history: history, interpretation: 'Insufficient data for RSI');
    }
    var gains = 0.0;
    var losses = 0.0;
    for (var index = 1; index <= period; index++) {
      final delta = values[index] - values[index - 1];
      if (delta >= 0) {
        gains += delta;
      } else {
        losses -= delta;
      }
    }
    var averageGain = gains / period;
    var averageLoss = losses / period;
    history[period] = _rsiValue(averageGain, averageLoss);
    for (var index = period + 1; index < values.length; index++) {
      final delta = values[index] - values[index - 1];
      final gain = delta > 0 ? delta : 0.0;
      final loss = delta < 0 ? -delta : 0.0;
      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
      history[index] = _rsiValue(averageGain, averageLoss);
    }
    final latest = history.lastWhere((double? value) => value != null, orElse: () => null);
    final label = latest == null
        ? 'Insufficient data for RSI'
        : latest >= 70
            ? 'Overbought zone — momentum can remain elevated'
            : latest <= 30
                ? 'Oversold zone — momentum can remain weak'
                : 'Neutral momentum range';
    return RsiResult(value: latest, history: history, interpretation: label);
  }

  MacdResult macd(List<double> values, {int fastPeriod = 12, int slowPeriod = 26, int signalPeriod = 9}) {
    final fast = emaSeries(values, fastPeriod);
    final slow = emaSeries(values, slowPeriod);
    final macdValues = <double>[];
    for (var index = 0; index < values.length; index++) {
      final fastValue = fast[index];
      final slowValue = slow[index];
      if (fastValue != null && slowValue != null) macdValues.add(fastValue - slowValue);
    }
    if (macdValues.length < signalPeriod) {
      return const MacdResult(macdLine: null, signalLine: null, histogram: null, crossover: 'Insufficient data for MACD');
    }
    final signalValues = emaSeries(macdValues, signalPeriod).whereType<double>().toList(growable: false);
    if (signalValues.isEmpty) {
      return const MacdResult(macdLine: null, signalLine: null, histogram: null, crossover: 'Insufficient data for MACD');
    }
    final latestMacd = macdValues.last;
    final latestSignal = signalValues.last;
    final histogram = latestMacd - latestSignal;
    String crossover;
    if (macdValues.length > 1 && signalValues.length > 1) {
      final previousHistogram =
          macdValues[macdValues.length - 2] - signalValues[signalValues.length - 2];
      crossover = previousHistogram <= 0 && histogram > 0
          ? 'Bullish crossover context'
          : previousHistogram >= 0 && histogram < 0
              ? 'Bearish crossover context'
              : histogram >= 0
                  ? 'Positive momentum context'
                  : 'Negative momentum context';
    } else {
      crossover = histogram >= 0 ? 'Positive momentum context' : 'Negative momentum context';
    }
    return MacdResult(macdLine: latestMacd, signalLine: latestSignal, histogram: histogram, crossover: crossover);
  }

  VolumeAnalysis volume(List<VolumeData> volumes, {int period = 20}) {
    final values = volumes.map((VolumeData point) => point.volumeUsd).where((double value) => value.isFinite && value >= 0).toList(growable: false);
    if (values.length < period) {
      return const VolumeAnalysis(current: null, average: null, ratio: null, state: VolumeState.unavailable, explanation: 'Insufficient volume history');
    }
    final current = values.last;
    final average = values.sublist(values.length - period).reduce((double a, double b) => a + b) / period;
    final ratio = average == 0 ? null : current / average;
    final state = ratio == null
        ? VolumeState.unavailable
        : ratio >= 1.2
            ? VolumeState.confirming
            : ratio <= 0.75
                ? VolumeState.weak
                : VolumeState.neutral;
    final explanation = switch (state) {
      VolumeState.confirming => 'Current volume is above its recent average',
      VolumeState.weak => 'Current volume is below its recent average',
      VolumeState.neutral => 'Current volume is near its recent average',
      VolumeState.unavailable => 'Insufficient volume history',
    };
    return VolumeAnalysis(current: current, average: average, ratio: ratio, state: state, explanation: explanation);
  }

  VolatilityAnalysis volatility(List<double> values, {int period = 20}) {
    if (values.length < period + 1) {
      return const VolatilityAnalysis(rangePercent: null, returnDeviation: null, state: VolatilityState.insufficient, explanation: 'Insufficient history for volatility context');
    }
    final window = values.sublist(values.length - period);
    final last = window.last;
    if (last == 0) {
      return const VolatilityAnalysis(rangePercent: null, returnDeviation: null, state: VolatilityState.insufficient, explanation: 'Price is unavailable for volatility context');
    }
    final low = window.reduce((double a, double b) => a < b ? a : b);
    final high = window.reduce((double a, double b) => a > b ? a : b);
    final range = ((high - low) / last).abs() * 100;
    final returns = <double>[];
    for (var index = 1; index < window.length; index++) {
      if (window[index - 1] != 0) returns.add(((window[index] - window[index - 1]) / window[index - 1]) * 100);
    }
    final mean = returns.isEmpty ? 0.0 : returns.reduce((double a, double b) => a + b) / returns.length;
    final squaredDifferences = returns
        .map((double value) {
          final difference = value - mean;
          return difference * difference;
        })
        .toList(growable: false);
    final variance = squaredDifferences.isEmpty
        ? 0.0
        : squaredDifferences.reduce((double a, double b) => a + b) /
            squaredDifferences.length;
    final deviation = math.sqrt(variance);
    final state = range >= 15
        ? VolatilityState.extreme
        : range >= 8
            ? VolatilityState.elevated
            : range <= 3
                ? VolatilityState.low
                : VolatilityState.normal;
    final explanation = switch (state) {
      VolatilityState.extreme => 'Recent range is extreme relative to the latest price',
      VolatilityState.elevated => 'Recent range is elevated',
      VolatilityState.low => 'Recent range is compressed',
      VolatilityState.normal => 'Recent range is within a normal band',
      VolatilityState.insufficient => 'Insufficient history for volatility context',
    };
    return VolatilityAnalysis(rangePercent: range, returnDeviation: deviation, state: state, explanation: explanation);
  }

  PriceStructure priceStructure(List<double> values, {int lookback = 20}) {
    if (values.length < lookback) {
      return const PriceStructure(support: null, resistance: null, recentHigh: null, recentLow: null, state: PriceStructureState.insufficient, explanation: 'Insufficient history for support and resistance zones');
    }
    final window = values.sublist(values.length - lookback);
    final support = window.reduce((double a, double b) => a < b ? a : b);
    final resistance = window.reduce((double a, double b) => a > b ? a : b);
    final last = window.last;
    final range = resistance - support;
    final state = range == 0
        ? PriceStructureState.balanced
        : last >= support + (range * 0.65)
            ? PriceStructureState.constructive
            : last <= support + (range * 0.35)
                ? PriceStructureState.fragile
                : PriceStructureState.balanced;
    final explanation = switch (state) {
      PriceStructureState.constructive => 'Price is in the upper portion of its recent identified range',
      PriceStructureState.fragile => 'Price is in the lower portion of its recent identified range',
      PriceStructureState.balanced => 'Price is within the middle of its recent identified range',
      PriceStructureState.insufficient => 'Insufficient history for support and resistance zones',
    };
    return PriceStructure(
      support: support,
      resistance: resistance,
      recentHigh: resistance,
      recentLow: support,
      state: state,
      explanation: explanation,
    );
  }

  double _rsiValue(double averageGain, double averageLoss) {
    if (averageLoss == 0) return averageGain == 0 ? 50 : 100;
    final relativeStrength = averageGain / averageLoss;
    return 100 - (100 / (1 + relativeStrength));
  }
}
