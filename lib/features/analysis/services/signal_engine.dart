import '../domain/analysis_models.dart';

class SignalEngine {
  const SignalEngine();

  SignalRecord evaluate(MarketAnalysis analysis, {DateTime? now}) {
    final createdAt = (now ?? DateTime.now()).toUtc();
    final risk = _riskFor(analysis);
    return SignalRecord(
      id: '${analysis.asset.id}:${analysis.timeframe}:${createdAt.microsecondsSinceEpoch}',
      assetId: analysis.asset.id,
      pair: '${analysis.asset.symbol} / USD',
      timeframe: analysis.timeframe,
      bias: analysis.bias,
      analyticalStrength: analysis.analyticalStrength,
      status: analysis.isSufficient ? SignalLifecycle.active : SignalLifecycle.expired,
      risk: risk,
      priceSnapshot: analysis.lastPrice,
      reasons: analysis.supportingFactors,
      conflictingFactors: analysis.conflictingFactors,
      riskFactors: analysis.riskFactors,
      invalidationConditions: analysis.invalidationConditions,
      createdAt: createdAt,
      dataAsOf: analysis.dataAsOf,
      expiresAt: createdAt.add(_expiryFor(analysis.timeframe)),
      analysisVersion: analysis.analysisVersion,
    );
  }

  AnalyticalRisk _riskFor(MarketAnalysis analysis) {
    if (!analysis.isSufficient) return AnalyticalRisk.unknown;
    if (analysis.volatility.state == VolatilityState.extreme) return AnalyticalRisk.high;
    if (analysis.volatility.state == VolatilityState.elevated) return AnalyticalRisk.elevated;
    if (analysis.conflictingFactors.length >= 3) return AnalyticalRisk.elevated;
    if (analysis.analyticalStrength >= 60 && analysis.conflictingFactors.isEmpty) return AnalyticalRisk.low;
    return AnalyticalRisk.moderate;
  }

  Duration _expiryFor(String timeframe) => switch (timeframe) {
        '1H' => const Duration(minutes: 45),
        '4H' => const Duration(hours: 3),
        '1D' => const Duration(hours: 18),
        '1W' => const Duration(days: 4),
        _ => const Duration(hours: 18),
      };
}

/// Session-memory history. Phase 6 replaces this storage boundary with durable user data.
class SignalHistoryStore {
  final List<SignalRecord> _records = <SignalRecord>[];
  final Map<String, SignalRecord> _current = <String, SignalRecord>{};

  List<SignalRecord> record(SignalRecord next) {
    final prior = _current[next.key];
    if (prior != null && prior.dataAsOf == next.dataAsOf) {
      return List<SignalRecord>.unmodifiable(_records);
    }
    if (prior != null &&
        (prior.effectiveStatus == SignalLifecycle.active ||
            prior.effectiveStatus == SignalLifecycle.updated) &&
        prior.bias != next.bias) {
      _records.add(SignalRecord(
        id: '${prior.id}:invalidated',
        assetId: prior.assetId,
        pair: prior.pair,
        timeframe: prior.timeframe,
        bias: prior.bias,
        analyticalStrength: prior.analyticalStrength,
        status: SignalLifecycle.invalidated,
        risk: prior.risk,
        priceSnapshot: prior.priceSnapshot,
        reasons: prior.reasons,
        conflictingFactors: prior.conflictingFactors,
        riskFactors: prior.riskFactors,
        invalidationConditions: prior.invalidationConditions,
        createdAt: prior.createdAt,
        dataAsOf: next.dataAsOf,
        expiresAt: next.createdAt,
        analysisVersion: prior.analysisVersion,
      ));
    }
    final status = prior != null && prior.bias == next.bias
        ? SignalLifecycle.updated
        : next.status;
    final immutableNext = SignalRecord(
      id: next.id,
      assetId: next.assetId,
      pair: next.pair,
      timeframe: next.timeframe,
      bias: next.bias,
      analyticalStrength: next.analyticalStrength,
      status: status,
      risk: next.risk,
      priceSnapshot: next.priceSnapshot,
      reasons: next.reasons,
      conflictingFactors: next.conflictingFactors,
      riskFactors: next.riskFactors,
      invalidationConditions: next.invalidationConditions,
      createdAt: next.createdAt,
      dataAsOf: next.dataAsOf,
      expiresAt: next.expiresAt,
      analysisVersion: next.analysisVersion,
    );
    _records.add(immutableNext);
    _current[next.key] = immutableNext;
    return List<SignalRecord>.unmodifiable(_records);
  }

  List<SignalRecord> recordsFor(String assetId) => List<SignalRecord>.unmodifiable(
        _records.where((SignalRecord item) => item.assetId == assetId),
      );

  List<SignalRecord> get all => List<SignalRecord>.unmodifiable(_records);
}
