import '../../../core/errors/app_failure.dart';
import '../../../shared/models/market_data_models.dart';
import '../../../shared/models/market_models.dart';
import '../domain/analysis_models.dart';

abstract interface class AIAnalysisService {
  Future<AiMarketAnalysis> interpret(MarketAnalysis analysis);
}

/// A deterministic structured interpreter for offline/demo development.
/// It uses only the supplied technical object and never claims remote AI access.
class MockAIAnalysisService implements AIAnalysisService {
  @override
  Future<AiMarketAnalysis> interpret(MarketAnalysis analysis) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!analysis.isSufficient) {
      return AiMarketAnalysis(
        assetId: analysis.asset.id,
        timeframe: analysis.timeframe,
        summary: 'There is insufficient market data for reliable analysis. More historical observations are required before presenting a technical interpretation.',
        bias: AnalyticalBias.insufficient,
        analyticalStrength: 0,
        trend: trendLabel(TrendState.insufficient),
        momentum: 'Insufficient momentum data',
        volatility: analysis.volatility.explanation,
        supportingFactors: const <String>[],
        conflictingFactors: analysis.conflictingFactors,
        scenarios: const <AnalysisScenario>[],
        riskFactors: analysis.riskFactors,
        invalidationConditions: analysis.invalidationConditions,
        generatedAt: DateTime.now().toUtc(),
        dataAsOf: analysis.dataAsOf,
        analysisVersion: analysis.analysisVersion,
        source: 'Local structured interpretation',
      );
    }
    final summary = '${analysis.asset.symbol} shows a ${biasLabel(analysis.bias).toLowerCase()} on the ${analysis.timeframe} view. ${_first(analysis.supportingFactors, 'Technical conditions are mixed.')} ${_first(analysis.conflictingFactors, '')}'.trim();
    return AiMarketAnalysis(
      assetId: analysis.asset.id,
      timeframe: analysis.timeframe,
      summary: summary,
      bias: analysis.bias,
      analyticalStrength: analysis.analyticalStrength,
      trend: trendLabel(analysis.trend),
      momentum: switch (analysis.momentum) {
        MomentumState.positive => 'Positive momentum context',
        MomentumState.negative => 'Negative momentum context',
        MomentumState.neutral => 'Neutral momentum context',
        MomentumState.insufficient => 'Insufficient momentum data',
      },
      volatility: analysis.volatility.explanation,
      supportingFactors: analysis.supportingFactors,
      conflictingFactors: analysis.conflictingFactors,
      scenarios: _scenarios(analysis),
      riskFactors: analysis.riskFactors,
      invalidationConditions: analysis.invalidationConditions,
      generatedAt: DateTime.now().toUtc(),
      dataAsOf: analysis.dataAsOf,
      analysisVersion: analysis.analysisVersion,
      source: 'Local structured interpretation',
    );
  }

  List<AnalysisScenario> _scenarios(MarketAnalysis analysis) => <AnalysisScenario>[
        AnalysisScenario(
          label: 'Bullish scenario',
          condition: _first(analysis.supportingFactors, 'Constructive conditions remain in place.'),
          context: 'The technical bias could remain constructive while the supporting conditions persist.',
          direction: MarketDirection.bullish,
        ),
        AnalysisScenario(
          label: 'Neutral scenario',
          condition: 'Momentum and price structure remain mixed near the identified range.',
          context: 'The market may consolidate while technical conditions reset.',
          direction: MarketDirection.neutral,
        ),
        AnalysisScenario(
          label: 'Bearish scenario',
          condition: _first(analysis.invalidationConditions, 'Key technical conditions weaken.'),
          context: 'The current analytical view would need reassessment if invalidation conditions occur.',
          direction: MarketDirection.bearish,
        ),
      ];

  String _first(List<String> values, String fallback) => values.isEmpty ? fallback : values.first;
}

abstract interface class AurumAiBackendClient {
  Future<Map<String, Object?>> analyze(Map<String, Object?> request);
}

/// Production-shaped adapter. It talks only to an AURUM backend, never an AI provider.
class RemoteAIAnalysisService implements AIAnalysisService {
  RemoteAIAnalysisService({required AurumAiBackendClient backend, AiPromptBuilder? promptBuilder})
      : _backend = backend,
        _promptBuilder = promptBuilder ?? const AiPromptBuilder();

  final AurumAiBackendClient _backend;
  final AiPromptBuilder _promptBuilder;

  @override
  Future<AiMarketAnalysis> interpret(MarketAnalysis analysis) async {
    final response = await _backend.analyze(<String, Object?>{
      'schemaVersion': 'aurum-ai-analysis-v1',
      'prompt': _promptBuilder.build(analysis),
      'analysis': _promptBuilder.structuredContext(analysis),
    });
    return _parse(response, analysis);
  }

  AiMarketAnalysis _parse(Map<String, Object?> json, MarketAnalysis fallback) {
    final summary = JsonRead.string(json['summary']);
    final strength = JsonRead.integer(json['analyticalStrength']);
    final rawBias = JsonRead.string(json['bias']);
    if (summary == null || strength == null || rawBias == null) {
      throw const ServiceFailure('AI returned an incomplete structured analysis.');
    }
    final bias = _bias(rawBias);
    if (bias == null || strength < 0 || strength > 100) {
      throw const ServiceFailure('AI returned an invalid structured analysis.');
    }
    return AiMarketAnalysis(
      assetId: fallback.asset.id,
      timeframe: fallback.timeframe,
      summary: summary,
      bias: bias,
      analyticalStrength: strength,
      trend: JsonRead.string(json['trend']) ?? trendLabel(fallback.trend),
      momentum: JsonRead.string(json['momentum']) ?? 'Unspecified momentum context',
      volatility: JsonRead.string(json['volatility']) ?? fallback.volatility.explanation,
      supportingFactors: _strings(json['supportingFactors']),
      conflictingFactors: _strings(json['conflictingFactors']),
      scenarios: _scenarios(json['scenarios']),
      riskFactors: _strings(json['riskFactors']),
      invalidationConditions: _strings(json['invalidationConditions']),
      generatedAt: DateTime.now().toUtc(),
      dataAsOf: fallback.dataAsOf,
      analysisVersion: fallback.analysisVersion,
      source: 'AURUM backend interpretation',
    );
  }

  AnalyticalBias? _bias(String value) => switch (value) {
        'strongBullish' => AnalyticalBias.strongBullish,
        'bullish' => AnalyticalBias.bullish,
        'neutral' => AnalyticalBias.neutral,
        'bearish' => AnalyticalBias.bearish,
        'strongBearish' => AnalyticalBias.strongBearish,
        'insufficient' => AnalyticalBias.insufficient,
        _ => null,
      };

  List<String> _strings(Object? value) => JsonRead.list(value)
      .map(JsonRead.string)
      .whereType<String>()
      .toList(growable: false);

  List<AnalysisScenario> _scenarios(Object? value) => JsonRead.list(value).map(JsonRead.map).map((Map<String, Object?> item) {
        final direction = switch (JsonRead.string(item['direction'])) {
          'bullish' => MarketDirection.bullish,
          'bearish' => MarketDirection.bearish,
          _ => MarketDirection.neutral,
        };
        return AnalysisScenario(
          label: JsonRead.string(item['label']) ?? 'Scenario',
          condition: JsonRead.string(item['condition']) ?? 'Conditions are mixed.',
          context: JsonRead.string(item['context']) ?? 'Review this alongside the technical evidence.',
          direction: direction,
        );
      }).toList(growable: false);
}

class AiPromptBuilder {
  const AiPromptBuilder();

  String build(MarketAnalysis analysis) => '''
You are AURUM's market-analysis interpreter. Use only the supplied structured analysis.
Do not invent prices, indicators, news, data sources, or events. Do not give trading instructions.
Do not claim certainty, a guaranteed return, a guaranteed signal, risk-free trading, or accuracy.
Clearly distinguish observation from interpretation, mention uncertainty, conflicts, risk factors, and invalidation conditions.
Return only structured JSON with: summary, bias, analyticalStrength, trend, momentum, volatility, supportingFactors, conflictingFactors, scenarios, riskFactors, invalidationConditions.
Analytical strength is evidence strength from 0 to 100, not a probability of profit.
Asset: ${analysis.asset.symbol}; timeframe: ${analysis.timeframe}; data timestamp: ${analysis.dataAsOf.toIso8601String()}.
''';

  Map<String, Object?> structuredContext(MarketAnalysis analysis) => <String, Object?>{
        'asset': analysis.asset.id,
        'symbol': analysis.asset.symbol,
        'timeframe': analysis.timeframe,
        'dataAsOf': analysis.dataAsOf.toIso8601String(),
        'analysisVersion': analysis.analysisVersion,
        'bias': analysis.bias.name,
        'analyticalStrength': analysis.analyticalStrength,
        'trend': analysis.trend.name,
        'momentum': analysis.momentum.name,
        'rsi': analysis.rsi.value,
        'macdHistogram': analysis.macd.histogram,
        'volumeState': analysis.volume.state.name,
        'volatilityState': analysis.volatility.state.name,
        'support': analysis.structure.support,
        'resistance': analysis.structure.resistance,
        'supportingFactors': analysis.supportingFactors,
        'conflictingFactors': analysis.conflictingFactors,
        'riskFactors': analysis.riskFactors,
        'invalidationConditions': analysis.invalidationConditions,
      };
}

class AiAnalysisCache {
  final Map<String, _CachedAiAnalysis> _cache = <String, _CachedAiAnalysis>{};
  final Map<String, Future<AiMarketAnalysis>> _inFlight = <String, Future<AiMarketAnalysis>>{};

  Future<AiMarketAnalysis> getOrCreate(
    MarketAnalysis analysis,
    AIAnalysisService service,
  ) {
    final key = '${analysis.asset.id}:${analysis.timeframe}:${analysis.dataAsOf.microsecondsSinceEpoch}:${analysis.analysisVersion}';
    final cached = _cache[key];
    final now = DateTime.now().toUtc();
    if (cached != null && now.difference(cached.savedAt) <= const Duration(minutes: 10)) {
      return Future<AiMarketAnalysis>.value(cached.value);
    }
    final running = _inFlight[key];
    if (running != null) return running;
    final future = service.interpret(analysis).then((AiMarketAnalysis value) {
      _cache[key] = _CachedAiAnalysis(value, DateTime.now().toUtc());
      return value;
    });
    _inFlight[key] = future;
    return future.whenComplete(() => _inFlight.remove(key));
  }
}

class _CachedAiAnalysis {
  const _CachedAiAnalysis(this.value, this.savedAt);
  final AiMarketAnalysis value;
  final DateTime savedAt;
}
