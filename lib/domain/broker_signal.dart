import '../features/analysis/domain/analysis_models.dart';

enum BrokerSide { strongBuy, buy, wait, sell, strongSell }

extension BrokerSideX on BrokerSide {
  String get shortLabel => switch (this) {
        BrokerSide.strongBuy => 'STRONG BUY',
        BrokerSide.buy => 'BUY',
        BrokerSide.wait => 'WAIT',
        BrokerSide.sell => 'SELL',
        BrokerSide.strongSell => 'STRONG SELL',
      };

  String get ticketLabel => switch (this) {
        BrokerSide.strongBuy || BrokerSide.buy => 'BUY',
        BrokerSide.wait => 'WAIT',
        BrokerSide.sell || BrokerSide.strongSell => 'SELL',
      };

  bool get isBuy => this == BrokerSide.buy || this == BrokerSide.strongBuy;
  bool get isSell => this == BrokerSide.sell || this == BrokerSide.strongSell;
}

BrokerSide brokerSideForBias(AnalyticalBias bias) => switch (bias) {
      AnalyticalBias.strongBullish => BrokerSide.strongBuy,
      AnalyticalBias.bullish => BrokerSide.buy,
      AnalyticalBias.bearish => BrokerSide.sell,
      AnalyticalBias.strongBearish => BrokerSide.strongSell,
      AnalyticalBias.neutral || AnalyticalBias.insufficient => BrokerSide.wait,
    };

BrokerSide brokerSideForScore(int score) {
  if (score >= 80) return BrokerSide.strongBuy;
  if (score >= 65) return BrokerSide.buy;
  if (score <= 20) return BrokerSide.strongSell;
  if (score <= 35) return BrokerSide.sell;
  return BrokerSide.wait;
}

/// Tape-only bias when a full technical ticket is not yet computed.
/// Never presented as a guaranteed outcome.
BrokerSide brokerSideFromChange(double change24h) {
  if (change24h >= 3) return BrokerSide.strongBuy;
  if (change24h >= 1) return BrokerSide.buy;
  if (change24h <= -3) return BrokerSide.strongSell;
  if (change24h <= -1) return BrokerSide.sell;
  return BrokerSide.wait;
}
