import 'package:aurum/domain/broker_signal.dart';
import 'package:aurum/shared/models/market_models.dart';
import 'package:aurum/shared/widgets/broker_components.dart';
import 'package:aurum/shared/widgets/financial_components.dart';
import 'package:aurum/shared/widgets/state_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _asset = MarketAsset(
  id: 'bitcoin',
  rank: 1,
  name: 'Bitcoin Cash SV Legacy Token',
  symbol: 'BTC',
  price: 67234.12,
  change24h: 3.45,
  volume: 2.1e10,
  marketCap: 1.3e12,
  iconColor: Color(0xFFF5C16C),
  sparkline: <double>[1, 2, 3, 2.5, 4],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LoadingList lays out inside a CustomScrollView sliver', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: LoadingList(count: 6)),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(LoadingSkeleton), findsNWidgets(6));
  });

  testWidgets('quote rows and crypto cards fit a 360px phone', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    FlutterError.onError = (FlutterErrorDetails details) {
      // Fail the test on overflow / layout assertions.
      throw details.exception;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: const [
              QuoteRow(asset: _asset, side: BrokerSide.buy),
              SizedBox(height: 8),
              CryptoCard(
                asset: _asset,
                showMarketStats: true,
                isWatched: true,
                onWatchToggle: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('BTC'), findsWidgets);
  });
}

void _noop() {}
