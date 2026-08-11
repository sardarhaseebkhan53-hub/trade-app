import 'package:aurum/features/analysis/services/technical_analysis_service.dart';
import 'package:aurum/shared/models/market_data_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TechnicalAnalysisService();

  test('SMA returns the correct latest average and handles insufficient data', () {
    expect(service.latestSma(<double>[1, 2, 3, 4, 5], 3), 4);
    expect(service.latestSma(<double>[1, 2], 3), isNull);
  });

  test('EMA tracks a rising sequence after the SMA seed', () {
    final latest = service.latestEma(<double>[1, 2, 3, 4, 5, 6], 3);

    expect(latest, isNotNull);
    expect(latest!, greaterThan(4));
    expect(latest, lessThanOrEqualTo(6));
  });

  test('RSI stays within range and is neutral for a flat market', () {
    final rsi = service.rsi(List<double>.filled(20, 100));

    expect(rsi.value, 50);
    expect(rsi.value, inInclusiveRange(0, 100));
  });

  test('MACD provides positive context for a consistently rising sequence', () {
    final macd = service.macd(List<double>.generate(60, (int index) => 100 + index.toDouble()));

    expect(macd.histogram, isNotNull);
    expect(macd.macdLine, isNotNull);
  });

  test('volume, volatility and structure tolerate insufficient data', () {
    final series = ChartSeries(
      prices: <HistoricalPrice>[HistoricalPrice(timestamp: DateTime.utc(2026), priceUsd: 100)],
      volumes: const <VolumeData>[],
      requestedTimeframe: '1D',
      sourceIntervalLabel: 'test',
    );

    final snapshot = service.evaluate(series);

    expect(snapshot.volume.current, isNull);
    expect(snapshot.volatility.rangePercent, isNull);
    expect(snapshot.structure.support, isNull);
  });
}
