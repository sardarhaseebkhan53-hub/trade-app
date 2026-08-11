import 'package:aurum/shared/services/mock_repositories.dart';
import 'package:aurum/shared/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('markets provider resolves a typed loading-to-success snapshot', () async {
    final container = ProviderContainer(
      overrides: [
        marketRepositoryProvider.overrideWithValue(MockMarketRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(marketsProvider('')).isLoading, isTrue);

    final snapshot = await container.read(marketsProvider('').future);

    expect(snapshot.data, isNotEmpty);
    expect(snapshot.source, 'Demo mock data');
  });
}
