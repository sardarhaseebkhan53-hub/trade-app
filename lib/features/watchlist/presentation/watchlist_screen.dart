import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../domain/broker_signal.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/broker_components.dart';
import '../../../shared/widgets/state_components.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(watchlistAssetsProvider);

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Watch',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: assets.when(
        data: (list) {
          if (list.isEmpty) {
            return AurumEmptyState(
              title: 'Watchlist is empty',
              message: 'Add symbols from Markets.',
              icon: Icons.star_outline_rounded,
              actionLabel: 'Markets',
              onAction: () => context.go('/markets'),
            );
          }
          return RefreshIndicator(
            color: AurumColors.gold,
            onRefresh: () async => ref.invalidate(watchlistAssetsProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final asset = list[index];
                return QuoteRow(
                  asset: asset,
                  side: brokerSideFromChange(asset.change24h),
                  onTap: () => context.push('/asset/${asset.id}'),
                );
              },
            ),
          );
        },
        loading: () => const LoadingList(count: 6),
        error: (_, __) => const AurumErrorState(title: 'Watchlist unavailable', message: 'Refresh to try again.'),
      ),
    );
  }
}
