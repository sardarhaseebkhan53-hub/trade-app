import 'package:flutter_test/flutter_test.dart';
import 'package:trade_app/features/analysis/services/technical_analysis_service.dart';

void main() {
  group('TechnicalAnalysisService', () {
    const service = TechnicalAnalysisService();

    test('returns insufficient data for short series', () {
      final result = service.analyze([100, 101, 102]);
      expect(result['trend'], 'INSUFFICIENT_DATA');
    });

    test('produces bullish trend on rising prices', () {
      final closes = List.generate(60, (i) => 100.0 + i * 0.8);
      final result = service.analyze(closes);
      expect(result['trend'], anyOf(['BULLISH', 'NEUTRAL']));
      expect(result['strength'], greaterThan(40));
    });

    test('calculates RSI within expected range', () {
      final closes = List.generate(30, (i) => 100 + (i.isEven ? 2 : -1).toDouble());
      final result = service.analyze(closes);
      expect(result['rsi'], isNotNull);
      if (result['rsi'] != null) {
        expect(result['rsi'] as double, greaterThanOrEqualTo(0));
        expect(result['rsi'] as double, lessThanOrEqualTo(100));
      }
    });
  });
}
