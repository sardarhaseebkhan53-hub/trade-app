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

/// Pure technical-analysis calculations over provider-neutral market data.
class TechnicalAnalysisService {
  const TechnicalAnalysisService();

  TechnicalSnapshot evaluate(ChartSeries series) {
    final closes = series.closeValues
        .where((double value) => value.isFinite && value > 0)
        .toList(growable: false);
    final volumes = series.volumes
        .map((VolumeData point) => point.volumeUsd)
        .where((double value) => value.isFinite && value >= 0)
        .toList(growable: false);

    return TechnicalSnapshot(
      dataPoints: closes.length,
      lastPrice: closes.isEmpty ? null : closes.last,
      sma20: _movingAverage(closes, 20, 'SMA', latestSma),
      sma50: _movingAverage(closes, 50, 'SMA', latestSma),
      sma100: _movingAverage(closes, 100, 'SMA', latestSma),
      sma200: _movingAverage(closes, 200, 'SMA', latestSma),
      ema20: _movingAverage(closes, 20, 'EMA', latestEma),
      ema50: _movingAverage(closes, 50, 'EMA', latestEma),
      rsi: rsi(closes),
      macd: macd(closes),
      volume: _analyzeVolume(volumes),
      volatility: _analyzeVolatility(closes),
      structure: _analyzeStructure(closes),
    );
  }

  /// Lightweight summary retained for presentation widgets.
  Map<String, Object> analyze(List<double> closes, {int rsiPeriod = 14}) {
    final values = closes.where((double value) => value.isFinite && value > 0).toList(growable: false);
    if (values.length < 20) {
      return <String, Object>{'trend': 'INSUFFICIENT_DATA', 'strength': 0};
    }

    final sma20 = latestSma(values, 20);
    final sma50 = latestSma(values, 50);
    final rsiValue = rsi(values, period: rsiPeriod).value;
    var trend = 'NEUTRAL';
    if (sma20 != null && sma50 != null) {
      trend = values.last > sma20 && sma20 > sma50 ? 'BULLISH' : 'BEARISH';
    }

    return <String, Object>{
      'trend': trend,
      if (rsiValue != null) 'rsi': rsiValue,
      'strength': rsiValue != null && rsiValue > 55 ? 68 : 52,
      'support': values.reduce(math.min),
      'resistance': values.reduce(math.max),
    };
  }

  double? latestSma(List<double> values, int period) {
    if (period <= 0 || values.length < period) return null;
    final start = values.length - period;
    var total = 0.0;
    for (var index = start; index < values.length; index++) {
      total += values[index];
    }
    return total / period;
  }

  double? latestEma(List<double> values, int period) {
    final series = _emaSeries(values, period);
    return series.isEmpty ? null : series.last;
  }

  RsiResult rsi(List<double> values, {int period = 14}) {
    final history = List<double?>.filled(values.length, null, growable: false);
    if (period <= 0 || values.length <= period) {
      return RsiResult(
        value: null,
        history: history,
        interpretation: 'Insufficient RSI history',
      );
    }

    var gains = 0.0;
    var losses = 0.0;
    for (var index = 1; index <= period; index++) {
      final change = values[index] - values[index - 1];
      if (change > 0) {
        gains += change;
      } else {
        losses -= change;
      }
    }

    var averageGain = gains / period;
    var averageLoss = losses / period;
    history[period] = _rsiValue(averageGain, averageLoss);

    for (var index = period + 1; index < values.length; index++) {
      final change = values[index] - values[index - 1];
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? -change : 0.0;
      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
      history[index] = _rsiValue(averageGain, averageLoss);
    }

    final value = history.last;
    return RsiResult(
      value: value,
      history: history,
      interpretation: switch (value) {
        null => 'Insufficient RSI history',
        >= 70 => 'Overbought momentum context',
        <= 30 => 'Oversold momentum context',
        >= 52 => 'Positive momentum context',
        <= 48 => 'Negative momentum context',
        _ => 'Neutral momentum context',
      },
    );
  }

  MacdResult macd(
    List<double> values, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (values.length < slowPeriod || fastPeriod <= 0 || slowPeriod <= fastPeriod) {
      return const MacdResult(
        macdLine: null,
        signalLine: null,
        histogram: null,
        crossover: 'Insufficient MACD history',
      );
    }

    final fast = _emaHistory(values, fastPeriod);
    final slow = _emaHistory(values, slowPeriod);
    final macdValues = <double>[];
    for (var index = 0; index < values.length; index++) {
      final fastValue = fast[index];
      final slowValue = slow[index];
      if (fastValue != null && slowValue != null) {
        macdValues.add(fastValue - slowValue);
      }
    }

    final line = macdValues.isEmpty ? null : macdValues.last;
    final signal = latestEma(macdValues, signalPeriod);
    final histogram = line == null || signal == null ? null : line - signal;
    return MacdResult(
      macdLine: line,
      signalLine: signal,
      histogram: histogram,
      crossover: switch (histogram) {
        null => 'Insufficient signal history',
        > 0 => 'Bullish MACD context',
        < 0 => 'Bearish MACD context',
        _ => 'Neutral MACD context',
      },
    );
  }

  MovingAverageResult _movingAverage(
    List<double> values,
    int period,
    String type,
    double? Function(List<double>, int) calculate,
  ) {
    return MovingAverageResult(
      period: period,
      type: type,
      value: calculate(values, period),
    );
  }

  List<double> _emaSeries(List<double> values, int period) {
    if (period <= 0 || values.length < period) return const <double>[];
    final output = <double>[];
    var current = 0.0;
    for (var index = 0; index < period; index++) {
      current += values[index];
    }
    current /= period;
    output.add(current);
    final multiplier = 2 / (period + 1);
    for (var index = period; index < values.length; index++) {
      current = ((values[index] - current) * multiplier) + current;
      output.add(current);
    }
    return output;
  }

  List<double?> _emaHistory(List<double> values, int period) {
    final history = List<double?>.filled(values.length, null, growable: false);
    final emaValues = _emaSeries(values, period);
    for (var index = 0; index < emaValues.length; index++) {
      history[index + period - 1] = emaValues[index];
    }
    return history;
  }

  double _rsiValue(double averageGain, double averageLoss) {
    if (averageGain == 0 && averageLoss == 0) return 50;
    if (averageLoss == 0) return 100;
    if (averageGain == 0) return 0;
    final relativeStrength = averageGain / averageLoss;
    return 100 - (100 / (1 + relativeStrength));
  }

  VolumeAnalysis _analyzeVolume(List<double> values, {int period = 20}) {
    if (values.length < period) {
      return const VolumeAnalysis(
        current: null,
        average: null,
        ratio: null,
        state: VolumeState.unavailable,
        explanation: 'Insufficient volume history',
      );
    }
    final current = values.last;
    final average = latestSma(values, period)!;
    final ratio = average == 0 ? 0.0 : current / average;
    final state = ratio >= 1.1
        ? VolumeState.confirming
        : ratio < 0.75
            ? VolumeState.weak
            : VolumeState.neutral;
    return VolumeAnalysis(
      current: current,
      average: average,
      ratio: ratio,
      state: state,
      explanation: switch (state) {
        VolumeState.confirming => 'Volume is above its recent average',
        VolumeState.weak => 'Volume is below its recent average',
        _ => 'Volume is near its recent average',
      },
    );
  }

  VolatilityAnalysis _analyzeVolatility(List<double> values, {int period = 20}) {
    if (values.length < 2) {
      return const VolatilityAnalysis(
        rangePercent: null,
        returnDeviation: null,
        state: VolatilityState.insufficient,
        explanation: 'Insufficient volatility history',
      );
    }

    final sample = values.skip(math.max(0, values.length - period)).toList(growable: false);
    final low = sample.reduce(math.min);
    final high = sample.reduce(math.max);
    final rangePercent = low == 0 ? null : ((high - low) / low) * 100;
    final returns = <double>[];
    for (var index = 1; index < sample.length; index++) {
      if (sample[index - 1] != 0) {
        returns.add((sample[index] - sample[index - 1]) / sample[index - 1]);
      }
    }
    final deviation = returns.length < 2 ? null : _standardDeviation(returns) * 100;
    final state = switch (deviation) {
      null => VolatilityState.insufficient,
      < 1 => VolatilityState.low,
      < 3 => VolatilityState.normal,
      < 6 => VolatilityState.elevated,
      _ => VolatilityState.extreme,
    };
    return VolatilityAnalysis(
      rangePercent: rangePercent,
      returnDeviation: deviation,
      state: state,
      explanation: switch (state) {
        VolatilityState.low => 'Recent volatility is low',
        VolatilityState.normal => 'Recent volatility is within a normal range',
        VolatilityState.elevated => 'Recent volatility is elevated',
        VolatilityState.extreme => 'Recent volatility is extreme',
        VolatilityState.insufficient => 'Insufficient volatility history',
      },
    );
  }

  PriceStructure _analyzeStructure(List<double> values, {int period = 20}) {
    if (values.length < 5) {
      return const PriceStructure(
        support: null,
        resistance: null,
        recentHigh: null,
        recentLow: null,
        state: PriceStructureState.insufficient,
        explanation: 'Insufficient price-structure history',
      );
    }

    final sample = values.skip(math.max(0, values.length - period)).toList(growable: false);
    final support = sample.reduce(math.min);
    final resistance = sample.reduce(math.max);
    final width = resistance - support;
    final position = width == 0 ? 0.5 : (sample.last - support) / width;
    final state = position >= 0.66
        ? PriceStructureState.constructive
        : position <= 0.33
            ? PriceStructureState.fragile
            : PriceStructureState.balanced;
    return PriceStructure(
      support: support,
      resistance: resistance,
      recentHigh: resistance,
      recentLow: support,
      state: state,
      explanation: switch (state) {
        PriceStructureState.constructive => 'Price is in the upper portion of its recent range',
        PriceStructureState.fragile => 'Price is in the lower portion of its recent range',
        _ => 'Price is near the middle of its recent range',
      },
    );
  }

  double _standardDeviation(List<double> values) {
    final average = values.reduce((double a, double b) => a + b) / values.length;
    final variance = values
            .map((double value) => math.pow(value - average, 2).toDouble())
            .reduce((double a, double b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }
}
