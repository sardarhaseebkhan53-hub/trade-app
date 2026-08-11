import '../../../shared/models/market_models.dart';
import '../domain/analysis_models.dart';
import 'technical_analysis_service.dart';

class AnalysisWeights {
  const AnalysisWeights({
    this.trend = 35,
    this.momentum = 25,
    this.volume = 15,
    this.volatility = 10,
    this.structure = 15,
  });

  final int trend;
  final int momentum;
  final int volume;
  final int volatility;
  final int structure;

  int get total => trend + momentum + volume + volatility + structure;
}

/// Converts raw indicator output into an explainable, multi-factor assessment.
class MarketAnalysisEngine {
  const MarketAnalysisEngine({this.weights = const AnalysisWeights()});
  final AnalysisWeights weights;

  MarketAnalysis analyze({
    required MarketAsset asset,
    required String timeframe,
    required DateTime dataAsOf,
    required TechnicalSnapshot technical,
    DateTime? generatedAt,
  }) {
    final now = (generatedAt ?? DateTime.now()).toUtc();
    final sufficient = technical.dataPoints >= 35 && technical.lastPrice != null;
    if (!sufficient) {
      return MarketAnalysis(
        asset: asset,
        timeframe: timeframe,
        dataAsOf: dataAsOf,
        generatedAt: now,
        analysisVersion: 'ta-rules-v1',
        isSufficient: false,
        insufficiencyReason: 'Insufficient market data for reliable analysis.',
        lastPrice: technical.lastPrice,
        sma20: technical.sma20,
        sma50: technical.sma50,
        sma100: technical.sma100,
        sma200: technical.sma200,
        ema20: technical.ema20,
        ema50: technical.ema50,
        rsi: technical.rsi,
        macd: technical.macd,
        volume: technical.volume,
        volatility: technical.volatility,
        structure: technical.structure,
        trend: TrendState.insufficient,
        momentum: MomentumState.insufficient,
        bias: AnalyticalBias.insufficient,
        analyticalStrength: 0,
        supportingFactors: const <String>[],
        conflictingFactors: const <String>['AURUM needs more historical observations before presenting a reliable technical assessment.'],
        riskFactors: const <String>['New or incomplete market history can make technical context unreliable.'],
        invalidationConditions: const <String>['Wait for sufficient history before relying on this analysis.'],
        factorScores: const <String, int>{},
      );
    }

    final trendScore = _trendScore(technical);
    final momentumScore = _momentumScore(technical);
    final volumeScore = _volumeScore(technical.volume);
    final volatilityScore = _volatilityScore(technical.volatility);
    final structureScore = _structureScore(technical.structure);
    final trend = _trendState(trendScore);
    final momentum = _momentumState(momentumScore);
    final rawScore = 50 +
        ((trendScore * weights.trend) / 2) +
        ((momentumScore * weights.momentum) / 2) +
        ((volumeScore * weights.volume) / 2) +
        ((volatilityScore * weights.volatility) / 2) +
        ((structureScore * weights.structure) / 2);
    final strength = rawScore.round().clamp(0, 100).toInt();
    final bias = _biasFor(strength);
    final support = <String>[];
    final conflicts = <String>[];
    final risks = <String>[];
    final invalidation = <String>[];

    _collectTrendEvidence(technical, trendScore, support, conflicts, invalidation);
    _collectMomentumEvidence(technical, momentumScore, support, conflicts);
    _collectVolumeEvidence(technical.volume, volumeScore, support, conflicts);
    _collectStructureEvidence(technical.structure, structureScore, support, conflicts, invalidation);
    _collectVolatilityRisk(technical.volatility, risks);
    if (technical.rsi.value != null && technical.rsi.value! >= 70) {
      risks.add('RSI is elevated; momentum can reverse or consolidate without warning.');
    }
    if (technical.rsi.value != null && technical.rsi.value! <= 30) {
      risks.add('RSI is depressed; weakness can persist despite an oversold reading.');
    }
    if (conflicts.isEmpty && support.isEmpty) conflicts.add('Technical conditions are mixed and do not provide a clear multi-factor view.');
    if (risks.isEmpty) risks.add('Market conditions can change quickly and this analysis is not financial advice.');
    if (invalidation.isEmpty) invalidation.add('A material shift in trend, momentum, or the identified price range can change this analysis.');

    return MarketAnalysis(
      asset: asset,
      timeframe: timeframe,
      dataAsOf: dataAsOf,
      generatedAt: now,
      analysisVersion: 'ta-rules-v1',
      isSufficient: true,
      insufficiencyReason: null,
      lastPrice: technical.lastPrice,
      sma20: technical.sma20,
      sma50: technical.sma50,
      sma100: technical.sma100,
      sma200: technical.sma200,
      ema20: technical.ema20,
      ema50: technical.ema50,
      rsi: technical.rsi,
      macd: technical.macd,
      volume: technical.volume,
      volatility: technical.volatility,
      structure: technical.structure,
      trend: trend,
      momentum: momentum,
      bias: bias,
      analyticalStrength: strength,
      supportingFactors: List<String>.unmodifiable(support),
      conflictingFactors: List<String>.unmodifiable(conflicts),
      riskFactors: List<String>.unmodifiable(risks),
      invalidationConditions: List<String>.unmodifiable(invalidation),
      factorScores: <String, int>{
        'trend': trendScore,
        'momentum': momentumScore,
        'volume': volumeScore,
        'volatility': volatilityScore,
        'priceStructure': structureScore,
      },
    );
  }

  int _trendScore(TechnicalSnapshot technical) {
    final price = technical.lastPrice;
    final fast = technical.ema20.value;
    final slow = technical.ema50.value;
    if (price == null || fast == null) return 0;
    var score = price >= fast ? 1 : -1;
    if (slow != null) {
      score += fast >= slow ? 1 : -1;
      score += price >= slow ? 1 : -1;
    }
    return score.clamp(-2, 2).toInt();
  }

  int _momentumScore(TechnicalSnapshot technical) {
    var score = 0;
    final rsi = technical.rsi.value;
    if (rsi != null) {
      if (rsi >= 52 && rsi < 70) score++;
      if (rsi <= 48 && rsi > 30) score--;
      if (rsi >= 75) score--;
      if (rsi <= 25) score++;
    }
    final histogram = technical.macd.histogram;
    if (histogram != null) score += histogram >= 0 ? 1 : -1;
    return score.clamp(-2, 2).toInt();
  }

  int _volumeScore(VolumeAnalysis volume) => switch (volume.state) {
        VolumeState.confirming => 1,
        VolumeState.weak => -1,
        _ => 0,
      };

  int _volatilityScore(VolatilityAnalysis volatility) => switch (volatility.state) {
        VolatilityState.low => 1,
        VolatilityState.normal => 0,
        VolatilityState.elevated => -1,
        VolatilityState.extreme => -2,
        VolatilityState.insufficient => 0,
      };

  int _structureScore(PriceStructure structure) => switch (structure.state) {
        PriceStructureState.constructive => 1,
        PriceStructureState.fragile => -1,
        _ => 0,
      };

  TrendState _trendState(int score) {
    if (score >= 2) return TrendState.strongBullish;
    if (score == 1) return TrendState.bullish;
    if (score == 0) return TrendState.neutral;
    if (score == -1) return TrendState.bearish;
    return TrendState.strongBearish;
  }

  MomentumState _momentumState(int score) {
    if (score > 0) return MomentumState.positive;
    if (score < 0) return MomentumState.negative;
    return MomentumState.neutral;
  }

  AnalyticalBias _biasFor(int score) {
    if (score >= 75) return AnalyticalBias.strongBullish;
    if (score >= 60) return AnalyticalBias.bullish;
    if (score <= 25) return AnalyticalBias.strongBearish;
    if (score <= 40) return AnalyticalBias.bearish;
    return AnalyticalBias.neutral;
  }

  void _collectTrendEvidence(TechnicalSnapshot technical, int score, List<String> support, List<String> conflicts, List<String> invalidation) {
    if (score > 0) {
      support.add('Price is holding above its short-term moving-average context.');
      if (technical.ema50.value != null) support.add('The short-term EMA is above the longer EMA reference.');
      invalidation.add('A sustained move below the short-term moving-average context would weaken the current trend view.');
    } else if (score < 0) {
      conflicts.add('Price is below one or more moving-average references.');
      invalidation.add('A sustained recovery above the moving-average context would weaken the bearish view.');
    } else {
      conflicts.add('Moving averages do not show a decisive directional trend.');
    }
  }

  void _collectMomentumEvidence(TechnicalSnapshot technical, int score, List<String> support, List<String> conflicts) {
    if (score > 0) {
      support.add('RSI and MACD provide constructive momentum context.');
    } else if (score < 0) {
      conflicts.add('RSI and MACD indicate weakening or negative momentum context.');
    } else {
      conflicts.add('Momentum indicators are mixed or neutral.');
    }
  }

  void _collectVolumeEvidence(VolumeAnalysis volume, int score, List<String> support, List<String> conflicts) {
    if (score > 0) {
      support.add('Volume is above its recent average, helping confirm participation.');
    } else if (score < 0) {
      conflicts.add('Volume is below its recent average, limiting confirmation.');
    }
  }

  void _collectStructureEvidence(PriceStructure structure, int score, List<String> support, List<String> conflicts, List<String> invalidation) {
    if (score > 0) {
      support.add('Price is in the upper portion of its recent identified range.');
      if (structure.support != null) invalidation.add('A break below the identified support zone near ${structure.support!.toStringAsFixed(2)} would change the range context.');
    } else if (score < 0) {
      conflicts.add('Price is in the lower portion of its recent identified range.');
      if (structure.resistance != null) invalidation.add('A move above the identified resistance zone near ${structure.resistance!.toStringAsFixed(2)} would change the range context.');
    } else {
      conflicts.add('Price remains within the middle of its identified range.');
    }
  }

  void _collectVolatilityRisk(VolatilityAnalysis volatility, List<String> risks) {
    if (volatility.state == VolatilityState.elevated || volatility.state == VolatilityState.extreme) {
      risks.add('${volatility.explanation}; position sizing and time horizon require extra care.');
    }
  }
}
