import '../../../shared/models/market_data_models.dart';

/// Keeps provider-specific sampling and chart rendering concerns separate.
abstract final class ChartDataAdapter {
  static List<double> toLinePoints(ChartSeries series, {int maxPoints = 180}) {
    final source = series.closeValues;
    if (source.length <= maxPoints) return source;
    final stride = source.length / maxPoints;
    return List<double>.generate(
      maxPoints,
      (int index) => source[(index * stride).floor().clamp(0, source.length - 1).toInt()],
      growable: false,
    );
  }

  static List<OHLCData> limitCandles(List<OHLCData> candles, {int maxCandles = 180}) {
    if (candles.length <= maxCandles) return candles;
    final stride = candles.length / maxCandles;
    return List<OHLCData>.generate(
      maxCandles,
      (int index) => candles[(index * stride).floor().clamp(0, candles.length - 1)],
      growable: false,
    );
  }
}
