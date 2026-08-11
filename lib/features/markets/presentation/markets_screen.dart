import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/market_data_models.dart';
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
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
            child: AurumSearchField(controller: _searchController, hintText: 'Search assets or tickers', onChanged: _onSearchChanged),
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
              Text(_sourceLabel(assets.valueOrNull), style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.2)),
              const Spacer(),
              Text('Price · 24h · Volume', style: AurumTypography.caption),
            ]),
          ),
          Expanded(
            child: assets.when(
              data: (MarketSnapshot<List<MarketAsset>> snapshot) {
                final filtered = _filter(snapshot.data);
                if (filtered.isEmpty) {
                  return AurumEmptyState(title: 'No assets found', message: 'Try a full name, ticker, or clear your search.', icon: Icons.search_off_rounded, actionLabel: 'Clear search', onAction: () { _searchController.clear(); setState(() => _query = ''); });
                }
                return RefreshIndicator(
                  color: AurumColors.gold,
                  onRefresh: () async {
                    ref.invalidate(marketsProvider(_query));
                    await ref.read(marketsProvider(_query).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.xs, AurumSpacing.lg, AurumSpacing.xxl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final asset = filtered[index];
                      return Column(children: <Widget>[CryptoCard(asset: asset, showMarketStats: true, isWatched: watched.contains(asset.id), onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(asset.id), onTap: () => context.push('/asset/${asset.id}')), if (index == 0 && snapshot.isStale) const Padding(padding: EdgeInsets.only(top: AurumSpacing.xs), child: Text('Showing cached data while an update is unavailable.', style: AurumTypography.caption))]);
                    },
                  ),
                );
              },
              loading: () => const LoadingList(count: 6),
              error: (_, __) => AurumErrorState(title: 'Unable to update market data', message: 'Check your connection and try again.', onRetry: () => ref.invalidate(marketsProvider(_query))),
            ),
          ),
        ]),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _query = '');
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 360), () {
      if (mounted) setState(() => _query = value);
    });
  }

  String _sourceLabel(MarketSnapshot<List<MarketAsset>>? snapshot) {
    if (snapshot == null) return 'MARKET DATA';
    return '${snapshot.source.toUpperCase()} • ${snapshot.freshnessLabel.toUpperCase()}';
  }

  List<MarketAsset> _filter(List<MarketAsset> assets) => switch (_selectedFilter) {
    'Gainers' => assets.where((MarketAsset asset) => asset.change24h > 0).toList(),
    'Losers' => assets.where((MarketAsset asset) => asset.change24h < 0).toList(),
    'Volume' => [...assets]..sort((MarketAsset a, MarketAsset b) => b.volume.compareTo(a.volume)),
    _ => assets,
  };
}
