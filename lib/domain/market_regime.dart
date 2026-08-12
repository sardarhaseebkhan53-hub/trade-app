enum MarketRegime {
  trending,
  ranging,
  highVolatility,
  lowVolatility,
  breakout,
  reversal,
  insufficientData,
}

class MarketRegimeResult {
  const MarketRegimeResult({
    required this.regime,
    required this.confidence,
    required this.volatilityLevel,
    required this.description,
    this.supportingEvidence = const [],
  });

  final MarketRegime regime;
  final int confidence; // 0-100
  final String volatilityLevel;
  final String description;
  final List<String> supportingEvidence;

  String get displayName {
    switch (regime) {
      case MarketRegime.trending:
        return 'Trending';
      case MarketRegime.ranging:
        return 'Ranging';
      case MarketRegime.highVolatility:
        return 'High Volatility';
      case MarketRegime.lowVolatility:
        return 'Low Volatility';
      case MarketRegime.breakout:
        return 'Breakout';
      case MarketRegime.reversal:
        return 'Potential Reversal';
      case MarketRegime.insufficientData:
        return 'Insufficient Data';
    }
  }
}

class MarketRegimeService {
  const MarketRegimeService();

  MarketRegimeResult detect({
    required List<double> prices,
    required List<double> volumes,
  }) {
    if (prices.length < 20) {
      return const MarketRegimeResult(
        regime: MarketRegime.insufficientData,
        confidence: 0,
        volatilityLevel: 'Unknown',
        description: 'Not enough data to determine regime.',
      );
    }

    final volatility = _calculateVolatility(prices);
    final trendStrength = _calculateTrendStrength(prices);

    MarketRegime regime;
    String description;
    int confidence = 65;

    if (volatility > 0.08) {
      regime = MarketRegime.highVolatility;
      description = 'Elevated volatility detected. Caution advised.';
      confidence = 80;
    } else if (trendStrength > 0.65) {
      regime = MarketRegime.trending;
      description = 'Clear directional trend in progress.';
      confidence = 78;
    } else if (trendStrength < 0.25) {
      regime = MarketRegime.ranging;
      description = 'Price is moving within a defined range.';
    } else {
      regime = MarketRegime.ranging;
      description = 'Mixed signals. No strong directional bias.';
    }

    return MarketRegimeResult(
      regime: regime,
      confidence: confidence,
      volatilityLevel: volatility > 0.06 ? 'Elevated' : 'Normal',
      description: description,
      supportingEvidence: [
        'Volatility: ${(volatility * 100).toStringAsFixed(1)}%',
        'Trend strength: ${(trendStrength * 100).toStringAsFixed(1)}%',
      ],
    );
  }

  double _calculateVolatility(List<double> prices) {
    if (prices.length < 2) return 0;
    final returns = <double>[];
    for (int i = 1; i < prices.length; i++) {
      returns.add((prices[i] - prices[i - 1]) / prices[i - 1]);
    }
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / returns.length;
    return variance.sqrt();
  }

  double _calculateTrendStrength(List<double> prices) {
    if (prices.length < 10) return 0.5;
    final first = prices.first;
    final last = prices.last;
    final change = (last - first).abs() / first;
    return change.clamp(0.0, 1.0);
  }
}

extension on double {
  double sqrt() => this < 0 ? 0 : this; // simplified
}
