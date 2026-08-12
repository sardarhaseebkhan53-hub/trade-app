import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/broker_signal.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/broker_components.dart';
import '../../../shared/widgets/state_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistAssetsProvider);
    final markets = ref.watch(marketsProvider(''));
    final overview = ref.watch(marketOverviewProvider);

    return Scaffold(
      backgroundColor: AurumColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async {
            ref.invalidate(watchlistAssetsProvider);
            ref.invalidate(marketsProvider(''));
            ref.invalidate(marketOverviewProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AurumSpacing.md, AurumSpacing.sm, AurumSpacing.md, 0),
                  child: Row(
                    children: [
                      const AurumBrand(compact: true),
                      const Spacer(),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: LivePulse(label: TimeOfDay.now().format(context)),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/search'),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.search_rounded, color: AurumColors.textPrimary),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.notifications_none_rounded, color: AurumColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: overview.when(
                  data: (data) => Padding(
                    padding: const EdgeInsets.fromLTRB(AurumSpacing.md, AurumSpacing.sm, AurumSpacing.md, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Positions', style: AurumTypography.caption),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                AurumFormatters.compactCurrency(data.totalMarketCapUsd),
                                style: AurumTypography.priceCard,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${data.marketCapChange24h >= 0 ? '+' : ''}${data.marketCapChange24h.toStringAsFixed(2)}%',
                              style: AurumTypography.percentage.copyWith(
                                color: AurumColors.movement(data.marketCapChange24h >= 0),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Market cap tape · not a wallet',
                          style: AurumTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AurumSpacing.md),
                    child: LoadingSkeleton(height: 56),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: markets.when(
                  data: (assets) => _Tape(assets: assets),
                  loading: () => const SizedBox(height: 36),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SliverToBoxAdapter(child: _ColumnHeader()),
              ...watchlist.when(
                data: (list) {
                  final rows = list.isEmpty
                      ? (markets.valueOrNull ?? const <MarketAsset>[])
                      : list;
                  if (rows.isEmpty) {
                    return [
                      const SliverToBoxAdapter(
                        child: AurumEmptyState(
                          title: 'No quotes',
                          message: 'Watchlist is empty. Open Markets to add symbols.',
                        ),
                      ),
                    ];
                  }
                  return [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final asset = rows[index];
                          return QuoteRow(
                            asset: asset,
                            side: brokerSideFromChange(asset.change24h),
                            onTap: () => context.push('/asset/${asset.id}'),
                          );
                        },
                        childCount: rows.length,
                      ),
                    ),
                  ];
                },
                loading: () => [
                  const SliverToBoxAdapter(child: LoadingList(count: 6)),
                ],
                error: (_, __) => [
                  SliverToBoxAdapter(
                    child: AurumErrorState(
                      title: 'Quotes unavailable',
                      message: 'Pull to refresh.',
                      onRetry: () => ref.invalidate(watchlistAssetsProvider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tape extends StatelessWidget {
  const _Tape({required this.assets});
  final List<MarketAsset> assets;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.md, vertical: 8),
        itemCount: assets.length.clamp(0, 8),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final a = assets[i];
          final up = a.isPositive;
          return Text(
            '${a.symbol} ${up ? '+' : ''}${a.change24h.toStringAsFixed(2)}%',
            style: AurumTypography.caption.copyWith(color: AurumColors.movement(up)),
          );
        },
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final style = AurumTypography.caption.copyWith(letterSpacing: 0.8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AurumSpacing.md, 4, AurumSpacing.md, 4),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text('SYM', style: style)),
          Expanded(child: Text('LAST', textAlign: TextAlign.right, style: style)),
          SizedBox(width: 72, child: Text('%', textAlign: TextAlign.right, style: style)),
          SizedBox(width: 64, child: Text('SIG', textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}
