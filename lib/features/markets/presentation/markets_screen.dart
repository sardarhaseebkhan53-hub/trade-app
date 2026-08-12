import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../domain/broker_signal.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/broker_components.dart';
import '../../../shared/widgets/state_components.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'Top';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(marketsProvider(_query));

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Markets',
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline_rounded, color: AurumColors.goldSoft),
            onPressed: () => context.push('/watchlist'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.sm),
            child: AurumSearchField(
              controller: _searchController,
              hintText: 'Search assets',
              onChanged: _onSearch,
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.lg),
              children: ['Top', 'Gainers', 'Losers', 'Volume'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: AurumSpacing.xs),
                  child: AurumFilterChip(
                    label: f,
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: assetsAsync.when(
              data: (assets) {
                var filtered = assets;
                if (_filter == 'Gainers') {
                  filtered = filtered.where((a) => a.change24h > 0).toList();
                } else if (_filter == 'Losers') {
                  filtered = filtered.where((a) => a.change24h < 0).toList();
                } else if (_filter == 'Volume') {
                  filtered = [...filtered]..sort((a, b) => b.volume.compareTo(a.volume));
                }

                if (filtered.isEmpty) {
                  return const AurumEmptyState(
                    title: 'No assets found',
                    message: 'Try a different search term.',
                  );
                }

                return RefreshIndicator(
                  color: AurumColors.gold,
                  onRefresh: () async => ref.invalidate(marketsProvider(_query)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return CryptoCard(
                        asset: a,
                        showMarketStats: true,
                        isWatched: watched.contains(a.id),
                        onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(a.id),
                        onTap: () => context.push('/asset/${a.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingList(count: 8),
              error: (_, __) => AurumErrorState(
                title: 'Unable to load markets',
                message: 'Check your connection.',
                onRetry: () => ref.invalidate(marketsProvider(_query)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
