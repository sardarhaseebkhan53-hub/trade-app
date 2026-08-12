import 'package:aurum/shared/services/mock_repositories.dart';
import 'package:aurum/shared/services/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('markets provider resolves from loading to a typed asset list', () async {
    final container = ProviderContainer(
      overrides: [
        marketRepositoryProvider.overrideWithValue(MockMarketRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(marketsProvider('')).isLoading, isTrue);

    final assets = await container.read(marketsProvider('').future);

    expect(assets, isNotEmpty);
    expect(assets.first.id, 'bitcoin');
  });
}
