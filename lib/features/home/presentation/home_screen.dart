import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../analysis/domain/analysis_models.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/market_data_models.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).valueOrNull;
    final overview = ref.watch(marketOverviewProvider);
    final featured = ref.watch(featuredAssetsProvider);
    final insight = ref.watch(homeAiAnalysisProvider);
    final signals = ref.watch(signalsProvider);
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async {
            ref.invalidate(marketOverviewProvider);
            ref.invalidate(featuredAssetsProvider);
            ref.invalidate(homeAiAnalysisProvider);
            ref.invalidate(signalsProvider);
            await ref.read(marketOverviewProvider.future);
            await ref.read(featuredAssetsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.md, AurumSpacing.lg, AurumSpacing.xxxl),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _Header(name: profile?.isGuest ?? true ? 'Guest analyst' : profile?.name ?? 'Analyst'),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Market pulse', subtitle: 'Global market context'),
                    const SizedBox(height: AurumSpacing.sm),
                    overview.when(
                      data: (MarketSnapshot<MarketOverview> data) => _MarketPulse(snapshot: data),
                      loading: () => const LoadingSkeleton(height: 176),
                      error: (_, __) => AurumErrorState(title: 'Unable to update market data', message: 'Check your connection and try again.', onRetry: () => ref.invalidate(marketOverviewProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    SectionHeader(title: 'Featured assets', subtitle: 'Top assets from the configured market provider', actionLabel: 'View markets', onAction: () => context.go('/markets')),
                    const SizedBox(height: AurumSpacing.sm),
                    featured.when(
                      data: (MarketSnapshot<List<MarketAsset>> snapshot) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ...snapshot.data.map((MarketAsset asset) => Padding(
                            padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                            child: CryptoCard(
                              asset: asset,
                              isWatched: watched.contains(asset.id),
                              onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(asset.id),
                              onTap: () => context.push('/asset/${asset.id}'),
                            ),
                          )),
                          Text(
                            '${snapshot.source} • ${snapshot.freshnessLabel} • ${AurumFormatters.compactDate(snapshot.asOf)}',
                            style: AurumTypography.caption.copyWith(
                              color: snapshot.isStale ? AurumColors.warning : AurumColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const _StackedSkeletons(count: 3),
                      error: (_, __) => AurumErrorState(title: 'Unable to update market data', message: 'Featured assets are temporarily unavailable.', onRetry: () => ref.invalidate(featuredAssetsProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'AURUM intelligence', subtitle: 'Structured interpretation of current technical analysis'),
                    const SizedBox(height: AurumSpacing.sm),
                    insight.when(
                      data: (AiMarketAnalysis data) => AIInsightCard(analysis: data, onTap: () => context.go('/ai-analysis')),
                      loading: () => const LoadingSkeleton(height: 170),
                      error: (_, __) => AurumErrorState(title: 'Analysis unavailable', message: 'Market data remains available. Please try again shortly.', onRetry: () => ref.invalidate(homeAiAnalysisProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    SectionHeader(title: 'Current signals', subtitle: 'Explainable multi-factor technical context', actionLabel: 'View all', onAction: () => context.go('/signals')),
                    const SizedBox(height: AurumSpacing.sm),
                    signals.when(
                      data: (List<SignalRecord> data) => Column(
                        children: data.take(2).map((SignalRecord signal) => Padding(
                          padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                          child: SignalCard(signal: signal, onTap: () => context.push('/asset/${signal.assetId}')),
                        )).toList(),
                      ),
                      loading: () => const _StackedSkeletons(count: 2, height: 150),
                      error: (_, __) => AurumErrorState(title: 'Signals are unavailable', message: 'Refresh to try generating the latest technical context.', onRetry: () => ref.invalidate(signalsProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Quick actions'),
                    const SizedBox(height: AurumSpacing.sm),
                    _QuickActions(),
                    const SizedBox(height: AurumSpacing.md),
                    const Text('Market prices use the configured provider. Analysis uses documented technical rules and uncertainty-aware interpretation • Not financial advice', style: AurumTypography.caption),
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
      children: <Widget>[
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const AurumBrand(compact: true),
            const SizedBox(height: AurumSpacing.xs),
            Text('Good to see you, $name', style: AurumTypography.h2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        IconButton(
          tooltip: 'Open notifications',
          onPressed: () => context.push('/notifications'),
          icon: Badge(
            smallSize: 8,
            backgroundColor: AurumColors.gold,
            child: const Icon(Icons.notifications_none_rounded, color: AurumColors.textPrimary),
          ),
        ),
        const SizedBox(width: AurumSpacing.xs),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: AurumColors.surfaceElevated, shape: BoxShape.circle),
          child: const Icon(Icons.person_outline_rounded, color: AurumColors.goldSoft, size: 19),
        ),
      ],
    );
  }
}

class _MarketPulse extends StatelessWidget {
  const _MarketPulse({required this.snapshot});
  final MarketSnapshot<MarketOverview> snapshot;

  @override
  Widget build(BuildContext context) {
    final overview = snapshot.data;
    final positive = overview.marketCapChange24h >= 0;
    final tone = positive ? AurumColors.positive : AurumColors.negative;
    return AurumCard(
      padding: const EdgeInsets.all(AurumSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tone, width: 2), color: tone.withOpacity(0.08)),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text('${overview.btcDominance.toStringAsFixed(1)}%', style: AurumTypography.priceRow.copyWith(color: AurumColors.textPrimary)),
              const Text('BTC dom.', style: AurumTypography.caption),
            ]),
          ),
          const SizedBox(width: AurumSpacing.lg),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Global market cap', style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.xs),
            Text(AurumFormatters.compactCurrency(overview.totalMarketCapUsd), style: AurumTypography.priceCard),
            const SizedBox(height: AurumSpacing.xxs),
            Text('${positive ? '+' : ''}${overview.marketCapChange24h.toStringAsFixed(2)}% over 24h', style: AurumTypography.body.copyWith(color: tone)),
          ])),
        ]),
        const SizedBox(height: AurumSpacing.lg),
        Row(children: <Widget>[
          Expanded(child: _PulseMetric(label: '24h volume', value: AurumFormatters.compactCurrency(overview.totalVolumeUsd))),
          Expanded(child: _PulseMetric(label: 'Tracked assets', value: overview.activeCryptocurrencies.toString())),
        ]),
        const SizedBox(height: AurumSpacing.sm),
        Text('${snapshot.source} • ${snapshot.freshnessLabel} • ${AurumFormatters.compactDate(snapshot.asOf)}', style: AurumTypography.caption.copyWith(color: snapshot.isStale ? AurumColors.warning : AurumColors.textTertiary)),
      ]),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: AurumTypography.caption), const SizedBox(height: AurumSpacing.xxs), Text(value, style: AurumTypography.priceRow)]);
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const actions = <({IconData icon, String label, String route})>[
      (icon: Icons.bar_chart_rounded, label: 'Markets', route: '/markets'),
      (icon: Icons.auto_awesome_outlined, label: 'AI analysis', route: '/ai-analysis'),
      (icon: Icons.insights_outlined, label: 'Signals', route: '/signals'),
      (icon: Icons.star_outline_rounded, label: 'Watchlist', route: '/watchlist'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.6,
      mainAxisSpacing: AurumSpacing.sm,
      crossAxisSpacing: AurumSpacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((action) => AurumCard(
        onTap: () => context.push(action.route),
        padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.sm),
        child: Row(children: <Widget>[
          Icon(action.icon, color: AurumColors.gold, size: 20),
          const SizedBox(width: AurumSpacing.xs),
          Expanded(child: Text(action.label, style: AurumTypography.label, overflow: TextOverflow.ellipsis)),
        ]),
      )).toList(),
    );
  }
}

class _StackedSkeletons extends StatelessWidget {
  const _StackedSkeletons({required this.count, this.height = 76});
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) => Column(
    children: List<Widget>.generate(count, (int index) => Padding(
      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
      child: LoadingSkeleton(height: height),
    )),
  );
}
