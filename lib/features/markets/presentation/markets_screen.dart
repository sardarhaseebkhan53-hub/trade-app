import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'Top';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(marketsProvider(_query));
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};
    return Scaffold(
      appBar: AurumAppBar(
        title: 'Markets',
        actions: <Widget>[
          IconButton(
            tooltip: 'Open watchlist',
            onPressed: () => context.push('/watchlist'),
            icon: const Icon(Icons.star_outline_rounded, color: AurumColors.goldSoft),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.sm),
            child: AurumSearchField(controller: _searchController, hintText: 'Search assets or tickers', onChanged: (String value) => setState(() => _query = value)),
          ),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.lg),
              children: <Widget>['Top', 'Gainers', 'Losers', 'Volume'].map((String filter) => Padding(
                padding: const EdgeInsets.only(right: AurumSpacing.xs),
                child: AurumFilterChip(label: filter, selected: _selectedFilter == filter, onSelected: (_) => setState(() => _selectedFilter = filter)),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.sm),
            child: Row(children: <Widget>[
              Text('DEMO MARKET DATA', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.2)),
              const Spacer(),
              Text('Price · 24h · Volume', style: AurumTypography.caption),
            ]),
          ),
          Expanded(
            child: assets.when(
              data: (List<MarketAsset> data) {
                final filtered = _filter(data);
                if (filtered.isEmpty) {
                  return AurumEmptyState(title: 'No assets found', message: 'Try a full name, ticker, or clear your search.', icon: Icons.search_off_rounded, actionLabel: 'Clear search', onAction: () { _searchController.clear(); setState(() => _query = ''); });
                }
                return RefreshIndicator(
                  color: AurumColors.gold,
                  onRefresh: () async => ref.invalidate(marketsProvider(_query)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.xs, AurumSpacing.lg, AurumSpacing.xxl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final asset = filtered[index];
                      return CryptoCard(asset: asset, showMarketStats: true, isWatched: watched.contains(asset.id), onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(asset.id), onTap: () => context.push('/asset/${asset.id}'));
                    },
                  ),
                );
              },
              loading: () => const LoadingList(count: 6),
              error: (_, __) => AurumErrorState(title: 'Unable to load market data', message: 'The demo market source did not respond. Try again.', onRetry: () => ref.invalidate(marketsProvider(_query))),
            ),
          ),
        ]),
      ),
    );
  }

  List<MarketAsset> _filter(List<MarketAsset> assets) => switch (_selectedFilter) {
    'Gainers' => assets.where((MarketAsset asset) => asset.change24h > 0).toList(),
    'Losers' => assets.where((MarketAsset asset) => asset.change24h < 0).toList(),
    'Volume' => [...assets]..sort((MarketAsset a, MarketAsset b) => b.volume.compareTo(a.volume)),
    _ => assets,
  };
}
