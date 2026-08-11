import 'package:aurum/features/analysis/services/market_analysis_engine.dart';
import 'package:aurum/features/analysis/services/technical_analysis_service.dart';
import 'package:aurum/shared/models/market_data_models.dart';
import 'package:aurum/shared/models/market_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const technicalService = TechnicalAnalysisService();
  const engine = MarketAnalysisEngine();
  const asset = MarketAsset(
    id: 'bitcoin',
    rank: 1,
    name: 'Bitcoin',
    symbol: 'BTC',
    price: 100,
    change24h: 1,
    volume: 1000,
    marketCap: 10000,
    iconColor: Colors.orange,
    sparkline: <double>[1, 2],
  );

  test('rising multi-factor data creates a non-bearish evidence assessment', () {
    final series = _series(List<double>.generate(80, (int index) => 100 + (index * 1.5)));
    final analysis = engine.analyze(
      asset: asset,
      timeframe: '1D',
      dataAsOf: DateTime.utc(2026, 8, 11),
      technical: technicalService.evaluate(series),
      generatedAt: DateTime.utc(2026, 8, 11, 12),
    );

    expect(analysis.isSufficient, isTrue);
    expect(analysis.analyticalStrength, inInclusiveRange(0, 100));
    expect(analysis.bias.name, anyOf('strongBullish', 'bullish', 'neutral'));
    expect(analysis.factorScores.keys, containsAll(<String>['trend', 'momentum', 'volume', 'volatility', 'priceStructure']));
  });

  test('insufficient price history does not generate a reliability claim', () {
    final analysis = engine.analyze(
      asset: asset,
      timeframe: '1H',
      dataAsOf: DateTime.utc(2026, 8, 11),
      technical: technicalService.evaluate(_series(<double>[100, 101, 102])),
    );

    expect(analysis.isSufficient, isFalse);
    expect(analysis.analyticalStrength, 0);
    expect(analysis.insufficiencyReason, 'Insufficient market data for reliable analysis.');
  });
}

ChartSeries _series(List<double> values) => ChartSeries(
      prices: List<HistoricalPrice>.generate(
        values.length,
        (int index) => HistoricalPrice(timestamp: DateTime.utc(2026, 8, 1).add(Duration(hours: index)), priceUsd: values[index]),
      ),
      volumes: List<VolumeData>.generate(
        values.length,
        (int index) => VolumeData(timestamp: DateTime.utc(2026, 8, 1).add(Duration(hours: index)), volumeUsd: 1000 + index.toDouble()),
      ),
      requestedTimeframe: '1D',
      sourceIntervalLabel: 'test',
    );
