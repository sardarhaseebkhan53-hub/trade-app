import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(watchlistProvider);
    final markets = ref.watch(marketsProvider(''));
    return Scaffold(
      appBar: AurumAppBar(
        title: 'Watchlist',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: SafeArea(
        top: false,
        child: ids.when(
          loading: () => const LoadingList(count: 3),
          error: (_, __) => AurumErrorState(title: 'Watchlist unavailable', message: 'Try loading your saved assets again.', onRetry: () => ref.invalidate(watchlistProvider)),
          data: (Set<String> watchedIds) => markets.when(
            loading: () => const LoadingList(count: 3),
            error: (_, __) => AurumErrorState(title: 'Market data unavailable', message: 'Your saved assets will reappear when market data returns.', onRetry: () => ref.invalidate(marketsProvider(''))),
            data: (List<MarketAsset> assets) {
              final watched = assets.where((MarketAsset asset) => watchedIds.contains(asset.id)).toList();
              if (watched.isEmpty) {
                return AurumEmptyState(title: 'Your watchlist is empty', message: 'Add an asset from Markets to keep its context close.', icon: Icons.star_outline_rounded, actionLabel: 'Explore markets', onAction: () => context.go('/markets'));
              }
              return RefreshIndicator(
                color: AurumColors.gold,
                onRefresh: () async { ref.invalidate(watchlistProvider); ref.invalidate(marketsProvider('')); },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AurumSpacing.lg),
                  itemCount: watched.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final asset = watched[index];
                    return CryptoCard(asset: asset, showMarketStats: true, isWatched: true, onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(asset.id), onTap: () => context.push('/asset/${asset.id}'));
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
