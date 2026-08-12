import 'package:aurum/domain/broker_signal.dart';
import 'package:aurum/features/analysis/domain/analysis_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps analysis bias to broker sides', () {
    expect(brokerSideForBias(AnalyticalBias.strongBullish), BrokerSide.strongBuy);
    expect(brokerSideForBias(AnalyticalBias.bullish), BrokerSide.buy);
    expect(brokerSideForBias(AnalyticalBias.neutral), BrokerSide.wait);
    expect(brokerSideForBias(AnalyticalBias.bearish), BrokerSide.sell);
    expect(brokerSideForBias(AnalyticalBias.strongBearish), BrokerSide.strongSell);
  });

  test('maps score bands to BUY WAIT SELL', () {
    expect(brokerSideForScore(82), BrokerSide.strongBuy);
    expect(brokerSideForScore(70), BrokerSide.buy);
    expect(brokerSideForScore(50), BrokerSide.wait);
    expect(brokerSideForScore(30), BrokerSide.sell);
    expect(brokerSideForScore(10), BrokerSide.strongSell);
  });

  test('ticket labels never say place order', () {
    for (final side in BrokerSide.values) {
      expect(side.ticketLabel, isIn(['BUY', 'WAIT', 'SELL']));
    }
  });
}
