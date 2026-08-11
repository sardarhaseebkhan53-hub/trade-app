import '../../../shared/models/market_models.dart';

enum TrendState { strongBullish, bullish, neutral, bearish, strongBearish, insufficient }
enum MomentumState { positive, neutral, negative, insufficient }
enum VolumeState { confirming, neutral, weak, unavailable }
enum VolatilityState { low, normal, elevated, extreme, insufficient }
enum PriceStructureState { constructive, balanced, fragile, insufficient }
enum AnalyticalBias { strongBullish, bullish, neutral, bearish, strongBearish, insufficient }
enum SignalLifecycle { active, updated, invalidated, expired }
enum AnalyticalRisk { low, moderate, elevated, high, unknown }

class MovingAverageResult {
  const MovingAverageResult({
    required this.period,
    required this.type,
    required this.value,
  });

  final int period;
  final String type;
  final double? value;
}

class RsiResult {
  const RsiResult({required this.value, required this.history, required this.interpretation});
  final double? value;
  final List<double?> history;
  final String interpretation;
}

class MacdResult {
  const MacdResult({
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
    required this.crossover,
  });

  final double? macdLine;
  final double? signalLine;
  final double? histogram;
  final String crossover;
}

class VolumeAnalysis {
  const VolumeAnalysis({
    required this.current,
    required this.average,
    required this.ratio,
    required this.state,
    required this.explanation,
  });

  final double? current;
  final double? average;
  final double? ratio;
  final VolumeState state;
  final String explanation;
}

class VolatilityAnalysis {
  const VolatilityAnalysis({
    required this.rangePercent,
    required this.returnDeviation,
    required this.state,
    required this.explanation,
  });

  final double? rangePercent;
  final double? returnDeviation;
  final VolatilityState state;
  final String explanation;
}

class PriceStructure {
  const PriceStructure({
    required this.support,
    required this.resistance,
    required this.recentHigh,
    required this.recentLow,
    required this.state,
    required this.explanation,
  });

  final double? support;
  final double? resistance;
  final double? recentHigh;
  final double? recentLow;
  final PriceStructureState state;
  final String explanation;
}

class MarketAnalysis {
  const MarketAnalysis({
    required this.asset,
    required this.timeframe,
    required this.dataAsOf,
    required this.generatedAt,
    required this.analysisVersion,
    required this.isSufficient,
    required this.insufficiencyReason,
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
    required this.trend,
    required this.momentum,
    required this.bias,
    required this.analyticalStrength,
    required this.supportingFactors,
    required this.conflictingFactors,
    required this.riskFactors,
    required this.invalidationConditions,
    required this.factorScores,
  });

  final MarketAsset asset;
  final String timeframe;
  final DateTime dataAsOf;
  final DateTime generatedAt;
  final String analysisVersion;
  final bool isSufficient;
  final String? insufficiencyReason;
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
  final TrendState trend;
  final MomentumState momentum;
  final AnalyticalBias bias;

  /// An evidence-weighted diagnostic score, never a performance probability.
  final int analyticalStrength;
  final List<String> supportingFactors;
  final List<String> conflictingFactors;
  final List<String> riskFactors;
  final List<String> invalidationConditions;
  final Map<String, int> factorScores;

  List<TechnicalIndicator> toIndicatorChips() => <TechnicalIndicator>[
        TechnicalIndicator(
          label: 'RSI (14)',
          value: rsi.value?.toStringAsFixed(1) ?? '—',
          interpretation: rsi.interpretation,
          direction: _directionForBias(bias),
        ),
        TechnicalIndicator(
          label: 'MACD',
          value: macd.histogram == null ? '—' : macd.histogram!.toStringAsFixed(2),
          interpretation: macd.crossover,
          direction: _directionForMomentum(momentum),
        ),
        TechnicalIndicator(
          label: 'EMA 20',
          value: ema20.value?.toStringAsFixed(2) ?? '—',
          interpretation: trendLabel(trend),
          direction: _directionForTrend(trend),
        ),
        TechnicalIndicator(
          label: 'Volume',
          value: volume.ratio == null ? '—' : '${volume.ratio!.toStringAsFixed(2)}×',
          interpretation: volume.explanation,
          direction: _directionForVolume(volume.state),
        ),
      ];
}

class SignalRecord {
  const SignalRecord({
    required this.id,
    required this.assetId,
    required this.pair,
    required this.timeframe,
    required this.bias,
    required this.analyticalStrength,
    required this.status,
    required this.risk,
    required this.priceSnapshot,
    required this.reasons,
    required this.conflictingFactors,
    required this.riskFactors,
    required this.invalidationConditions,
    required this.createdAt,
    required this.dataAsOf,
    required this.expiresAt,
    required this.analysisVersion,
  });

  final String id;
  final String assetId;
  final String pair;
  final String timeframe;
  final AnalyticalBias bias;
  final int analyticalStrength;
  final SignalLifecycle status;
  final AnalyticalRisk risk;
  final double? priceSnapshot;
  final List<String> reasons;
  final List<String> conflictingFactors;
  final List<String> riskFactors;
  final List<String> invalidationConditions;
  final DateTime createdAt;
  final DateTime dataAsOf;
  final DateTime expiresAt;
  final String analysisVersion;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
  SignalLifecycle get effectiveStatus =>
      (status == SignalLifecycle.active || status == SignalLifecycle.updated) && isExpired
          ? SignalLifecycle.expired
          : status;
  String get key => '$assetId:$timeframe';
}

class AiMarketAnalysis {
  const AiMarketAnalysis({
    required this.assetId,
    required this.timeframe,
    required this.summary,
    required this.bias,
    required this.analyticalStrength,
    required this.trend,
    required this.momentum,
    required this.volatility,
    required this.supportingFactors,
    required this.conflictingFactors,
    required this.scenarios,
    required this.riskFactors,
    required this.invalidationConditions,
    required this.generatedAt,
    required this.dataAsOf,
    required this.analysisVersion,
    required this.source,
  });

  final String assetId;
  final String timeframe;
  final String summary;
  final AnalyticalBias bias;
  final int analyticalStrength;
  final String trend;
  final String momentum;
  final String volatility;
  final List<String> supportingFactors;
  final List<String> conflictingFactors;
  final List<AnalysisScenario> scenarios;
  final List<String> riskFactors;
  final List<String> invalidationConditions;
  final DateTime generatedAt;
  final DateTime dataAsOf;
  final String analysisVersion;
  final String source;
}

String trendLabel(TrendState trend) => switch (trend) {
      TrendState.strongBullish => 'Strong bullish trend',
      TrendState.bullish => 'Bullish trend',
      TrendState.neutral => 'Neutral trend',
      TrendState.bearish => 'Bearish trend',
      TrendState.strongBearish => 'Strong bearish trend',
      TrendState.insufficient => 'Insufficient trend data',
    };

String biasLabel(AnalyticalBias bias) => switch (bias) {
      AnalyticalBias.strongBullish => 'Strong bullish bias',
      AnalyticalBias.bullish => 'Bullish bias',
      AnalyticalBias.neutral => 'Neutral bias',
      AnalyticalBias.bearish => 'Bearish bias',
      AnalyticalBias.strongBearish => 'Strong bearish bias',
      AnalyticalBias.insufficient => 'Insufficient data',
    };

MarketDirection _directionForBias(AnalyticalBias bias) => switch (bias) {
      AnalyticalBias.strongBullish => MarketDirection.bullish,
      AnalyticalBias.bullish => MarketDirection.bullish,
      AnalyticalBias.strongBearish => MarketDirection.bearish,
      AnalyticalBias.bearish => MarketDirection.bearish,
      _ => MarketDirection.neutral,
    };

MarketDirection _directionForTrend(TrendState trend) => switch (trend) {
      TrendState.strongBullish || TrendState.bullish => MarketDirection.bullish,
      TrendState.strongBearish || TrendState.bearish => MarketDirection.bearish,
      _ => MarketDirection.neutral,
    };

MarketDirection _directionForMomentum(MomentumState momentum) => switch (momentum) {
      MomentumState.positive => MarketDirection.bullish,
      MomentumState.negative => MarketDirection.bearish,
      _ => MarketDirection.neutral,
    };

MarketDirection _directionForVolume(VolumeState state) => switch (state) {
      VolumeState.confirming => MarketDirection.bullish,
      VolumeState.weak => MarketDirection.bearish,
      _ => MarketDirection.neutral,
    };
