import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(watchlistProvider);
    final assets = ref.watch(watchlistAssetsProvider);

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Watchlist',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined, color: AurumColors.goldSoft),
            onPressed: () => context.push('/ai-analysis'),
            tooltip: 'AI Watchlist Briefing',
          ),
        ],
      ),
      body: ids.when(
        data: (watchedIds) {
          if (watchedIds.isEmpty) {
            return AurumEmptyState(
              title: 'Your watchlist is empty',
              message: 'Add assets from the Markets screen.',
              icon: Icons.star_outline_rounded,
              actionLabel: 'Browse markets',
              onAction: () => context.go('/markets'),
            );
          }
          return assets.when(
            data: (list) {
              // Watchlist Intelligence summary (Phase 3 requirement)
              final gainers = list.where((a) => a.change24h > 0).length;
              final avgChange = list.isEmpty ? 0 : list.map((a) => a.change24h).reduce((a, b) => a + b) / list.length;

              return RefreshIndicator(
                color: AurumColors.gold,
                onRefresh: () async => ref.invalidate(watchlistAssetsProvider),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AurumSpacing.lg),
                        child: AurumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WATCHLIST INTELLIGENCE', style: AurumTypography.caption),
                              const SizedBox(height: AurumSpacing.sm),
                              Text('${list.length} assets  •  ${gainers} gainers  •  Avg ${(avgChange).toStringAsFixed(1)}%', style: AurumTypography.bodyLarge),
                              const SizedBox(height: AurumSpacing.xs),
                              const Text('AI Briefing available from AI tab', style: AurumTypography.caption),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final a = list[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                              child: CryptoCard(
                                asset: a,
                                showMarketStats: true,
                                isWatched: true,
                                onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(a.id),
                                onTap: () => context.push('/asset/${a.id}'),
                              ),
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LoadingList(count: 4),
            error: (_, __) => AurumErrorState(title: 'Watchlist unavailable', message: 'Refresh to try again.'),
          );
        },
        loading: () => const LoadingList(count: 3),
        error: (_, __) => AurumErrorState(title: 'Watchlist error', message: 'Try again later.'),
      ),
    );
  }
}
