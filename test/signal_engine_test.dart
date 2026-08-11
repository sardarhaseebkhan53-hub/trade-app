import 'package:aurum/features/analysis/domain/analysis_models.dart';
import 'package:aurum/features/analysis/services/signal_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history preserves an invalidated record when bias changes', () {
    final store = SignalHistoryStore();
    final first = _signal(id: 'one', bias: AnalyticalBias.bullish, dataAsOf: DateTime.utc(2026, 8, 11));
    final second = _signal(id: 'two', bias: AnalyticalBias.bearish, dataAsOf: DateTime.utc(2026, 8, 12));

    store.record(first);
    final records = store.record(second);

    expect(records.map((SignalRecord item) => item.status), contains(SignalLifecycle.invalidated));
    expect(records.last.bias, AnalyticalBias.bearish);
  });

  test('same data timestamp does not duplicate a historical record', () {
    final store = SignalHistoryStore();
    final signal = _signal(id: 'one', bias: AnalyticalBias.neutral, dataAsOf: DateTime.utc(2026, 8, 11));

    store.record(signal);
    final records = store.record(signal);

    expect(records, hasLength(1));
  });

  test('active records expose an expired status after their expiry time', () {
    final expired = _signal(
      id: 'expired',
      bias: AnalyticalBias.neutral,
      dataAsOf: DateTime.utc(2020),
      expiresAt: DateTime.utc(2020, 1, 2),
    );

    expect(expired.effectiveStatus, SignalLifecycle.expired);
  });
}

SignalRecord _signal({
  required String id,
  required AnalyticalBias bias,
  required DateTime dataAsOf,
  DateTime? expiresAt,
}) => SignalRecord(
      id: id,
      assetId: 'bitcoin',
      pair: 'BTC / USD',
      timeframe: '1D',
      bias: bias,
      analyticalStrength: 60,
      status: SignalLifecycle.active,
      risk: AnalyticalRisk.moderate,
      priceSnapshot: 100,
      reasons: const <String>['Test reason'],
      conflictingFactors: const <String>[],
      riskFactors: const <String>['Test risk'],
      invalidationConditions: const <String>['Test invalidation'],
      createdAt: DateTime.utc(2026, 8, 11),
      dataAsOf: dataAsOf,
      expiresAt: expiresAt ?? DateTime.utc(2026, 8, 20),
      analysisVersion: 'test-v1',
    );
