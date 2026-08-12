import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../domain/data_integrity.dart';
import '../../../domain/market_regime.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/data_freshness_indicator.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).valueOrNull?.profile;
    final overview = ref.watch(marketOverviewProvider);
    final featured = ref.watch(featuredAssetsProvider);
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async {
            ref.invalidate(marketOverviewProvider);
            ref.invalidate(featuredAssetsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.md, AurumSpacing.lg, AurumSpacing.xxxl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Header(name: profile?.name ?? 'Analyst'),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Market Overview'),
                    const SizedBox(height: AurumSpacing.sm),
                    overview.when(
                      data: (data) => Column(
                        children: [
                          _MarketPulse(overview: data),
                          const SizedBox(height: AurumSpacing.md),
                          const _RegimeBadge(),
                        ],
                      ),
                      loading: () => const LoadingSkeleton(height: 170),
                      error: (_, __) => AurumErrorState(
                        title: 'Market data unavailable',
                        message: 'Pull to refresh.',
                        onRetry: () => ref.invalidate(marketOverviewProvider),
                      ),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    SectionHeader(
                      title: 'Featured Assets',
                      actionLabel: 'Markets',
                      onAction: () => context.go('/markets'),
                    ),
                    const SizedBox(height: AurumSpacing.sm),
                    featured.when(
                      data: (assets) => Column(
                        children: assets.take(3).map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                          child: CryptoCard(
                            asset: a,
                            isWatched: watched.contains(a.id),
                            onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(a.id),
                            onTap: () => context.push('/asset/${a.id}'),
                          ),
                        )).toList(),
                      ),
                      loading: () => const LoadingSkeleton(height: 220),
                      error: (_, __) => const AurumErrorState(title: 'Assets unavailable', message: 'Try again'),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Market Overview'),
                    const SizedBox(height: AurumSpacing.sm),
                    _MarketOverviewCard(),

                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'AURUM AI Insight'),
                    const SizedBox(height: AurumSpacing.sm),
                    AIInsightCard(
                      analysis: null,
                      onTap: () => context.go('/ai-analysis'),
                    ),
                    const SizedBox(height: AurumSpacing.md),
                    const _DataFreshnessIndicator(),
                    const SizedBox(height: AurumSpacing.xxl),

                    // Quick access to advanced Phase 3 features
                    const SectionHeader(title: 'Quick Tools'),
                    const SizedBox(height: AurumSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AurumCard(
                            onTap: () => context.push('/analysis'),
                            child: const Column(
                              children: [
                                Icon(Icons.analytics_outlined, color: AurumColors.gold, size: 28),
                                SizedBox(height: 6),
                                Text('Analysis', style: AurumTypography.label),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AurumSpacing.sm),
                        Expanded(
                          child: AurumCard(
                            onTap: () => context.push('/scanner'),
                            child: const Column(
                              children: [
                                Icon(Icons.search_rounded, color: AurumColors.gold, size: 28),
                                SizedBox(height: 6),
                                Text('Scanner', style: AurumTypography.label),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AurumSpacing.sm),
                        Expanded(
                          child: AurumCard(
                            onTap: () => context.push('/journal'),
                            child: const Column(
                              children: [
                                Icon(Icons.book_outlined, color: AurumColors.gold, size: 28),
                                SizedBox(height: 6),
                                Text('Journal', style: AurumTypography.label),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SectionHeader(
                      title: 'Signals',
                      actionLabel: 'View all',
                      onAction: () => context.go('/signals'),
                    ),
                    const SizedBox(height: AurumSpacing.sm),
                    const SignalCard(signal: null),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: AurumSpacing.sm),
                    _QuickActions(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AurumBrand(compact: true),
              const SizedBox(height: AurumSpacing.xs),
              Text('Good to see you, $name', style: AurumTypography.h2),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded, color: AurumColors.textPrimary),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: const CircleAvatar(
            radius: 17,
            backgroundColor: AurumColors.surfaceElevated,
            child: Icon(Icons.person_outline_rounded, color: AurumColors.goldSoft, size: 18),
          ),
        ),
      ],
    );
  }
}

class _MarketPulse extends StatelessWidget {
  const _MarketPulse({required this.overview});
  final dynamic overview; // MarketOverview

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      padding: const EdgeInsets.all(AurumSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Global market cap', style: AurumTypography.caption),
          Text(AurumFormatters.compactCurrency(overview.totalMarketCapUsd ?? 0), style: AurumTypography.priceCard),
          const SizedBox(height: AurumSpacing.sm),
          Text(
            '${(overview.marketCapChange24h ?? 0) >= 0 ? '+' : ''}${(overview.marketCapChange24h ?? 0).toStringAsFixed(1)}%  •  BTC dom ${(overview.btcDominance ?? 0).toStringAsFixed(1)}%',
            style: AurumTypography.body,
          ),
        ],
      ),
    );
  }
}

class _RegimeBadge extends StatelessWidget {
  const _RegimeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // In real implementation this would come from a provider
    const regime = MarketRegimeResult(
      regime: MarketRegime.trending,
      confidence: 74,
      volatilityLevel: 'Normal',
      description: 'Clear directional trend with moderate volatility.',
    );

    return AurumCard(
      borderColor: AurumColors.gold.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AurumColors.gold),
          const SizedBox(width: AurumSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Market Regime: ${regime.displayName}', style: AurumTypography.h3),
                Text(regime.description, style: AurumTypography.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AurumColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${regime.confidence}/100', style: AurumTypography.label.copyWith(color: AurumColors.gold)),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Markets', '/markets', Icons.bar_chart_rounded),
      ('AI Analyst', '/ai-analysis', Icons.auto_awesome_outlined),
      ('Signals', '/signals', Icons.insights_outlined),
      ('Search', '/search', Icons.search_rounded),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AurumSpacing.sm,
      crossAxisSpacing: AurumSpacing.sm,
      childAspectRatio: 3.1,
      children: actions.map((a) {
        return AurumCard(
          onTap: () => context.push(a.$2),
          padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.md),
          child: Row(
            children: [
              Icon(a.$3, color: AurumColors.gold, size: 20),
              const SizedBox(width: AurumSpacing.sm),
              Text(a.$1, style: AurumTypography.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DataFreshnessIndicator extends StatelessWidget {
  const _DataFreshnessIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo: in real app this would be driven by DataIntegrityService + market repo
    return const DataFreshnessIndicator(
      freshness: DataFreshness.live,
      lastUpdated: null, // will show "No timestamp available" or use current
    );
  }
}

class _MarketOverviewCard extends ConsumerWidget {
  const _MarketOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(marketOverviewProvider);

    return overview.when(
      data: (data) => AurumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Market Overview', style: AurumTypography.label),
                const Spacer(),
                const DataFreshnessIndicator(freshness: DataFreshness.live, lastUpdated: null),
              ],
            ),
            const SizedBox(height: AurumSpacing.sm),
            Text(
              AurumFormatters.compactCurrency(data.totalMarketCapUsd ?? 0),
              style: AurumTypography.priceCard,
            ),
            Text(
              '24h Vol: ${AurumFormatters.compactCurrency(data.totalVolumeUsd ?? 0)}  •  BTC dom ${(data.btcDominance ?? 0).toStringAsFixed(1)}%',
              style: AurumTypography.caption,
            ),
          ],
        ),
      ),
      loading: () => const LoadingSkeleton(height: 110),
      error: (_, __) => const AurumErrorState(title: 'Overview unavailable'),
    );
  }
}
