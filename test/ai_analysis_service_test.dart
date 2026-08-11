import 'package:aurum/features/analysis/domain/analysis_models.dart';
import 'package:aurum/features/analysis/services/ai_analysis_service.dart';
import 'package:aurum/features/analysis/services/market_analysis_engine.dart';
import 'package:aurum/features/analysis/services/technical_analysis_service.dart';
import 'package:aurum/shared/models/market_data_models.dart';
import 'package:aurum/shared/models/market_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final analysis = _analysis();

  test('local structured interpreter preserves source analysis context', () async {
    final result = await MockAIAnalysisService().interpret(analysis);

    expect(result.assetId, analysis.asset.id);
    expect(result.timeframe, analysis.timeframe);
    expect(result.analyticalStrength, analysis.analyticalStrength);
    expect(result.source, 'Local structured interpretation');
  });

  test('remote parser accepts a complete structured response', () async {
    final service = RemoteAIAnalysisService(backend: _FakeBackend(valid: true));

    final result = await service.interpret(analysis);

    expect(result.summary, isNotEmpty);
    expect(result.bias, AnalyticalBias.bullish);
  });

  test('remote parser rejects incomplete output instead of rendering arbitrary text', () async {
    final service = RemoteAIAnalysisService(backend: _FakeBackend(valid: false));

    expect(service.interpret(analysis), throwsA(isA<Exception>()));
  });
}

MarketAnalysis _analysis() {
  const asset = MarketAsset(id: 'bitcoin', rank: 1, name: 'Bitcoin', symbol: 'BTC', price: 100, change24h: 1, volume: 1000, marketCap: 10000, iconColor: Colors.orange, sparkline: <double>[1, 2]);
  final series = ChartSeries(
    prices: List<HistoricalPrice>.generate(70, (int index) => HistoricalPrice(timestamp: DateTime.utc(2026).add(Duration(hours: index)), priceUsd: 100 + index.toDouble())),
    volumes: List<VolumeData>.generate(70, (int index) => VolumeData(timestamp: DateTime.utc(2026).add(Duration(hours: index)), volumeUsd: 1000 + index.toDouble())),
    requestedTimeframe: '1D',
    sourceIntervalLabel: 'test',
  );
  const engine = MarketAnalysisEngine();
  const technicalService = TechnicalAnalysisService();
  return engine.analyze(
    asset: asset,
    timeframe: '1D',
    dataAsOf: DateTime.utc(2026, 8, 11),
    technical: technicalService.evaluate(series),
  );
}

class _FakeBackend implements AurumAiBackendClient {
  const _FakeBackend({required this.valid});
  final bool valid;

  @override
  Future<Map<String, Object?>> analyze(Map<String, Object?> request) async => valid
      ? <String, Object?>{
          'summary': 'Technical conditions are constructive but remain uncertain.',
          'bias': 'bullish',
          'analyticalStrength': 68,
          'trend': 'Bullish trend',
          'momentum': 'Positive momentum context',
          'volatility': 'Normal range',
          'supportingFactors': <Object?>['Price is above its short-term average.'],
          'conflictingFactors': <Object?>['Resistance remains nearby.'],
          'scenarios': <Object?>[],
          'riskFactors': <Object?>['Volatility can change quickly.'],
          'invalidationConditions': <Object?>['Trend conditions weaken.'],
        }
      : <String, Object?>{'summary': 'Missing fields'};
}
