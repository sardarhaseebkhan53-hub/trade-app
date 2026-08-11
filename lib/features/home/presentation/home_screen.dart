import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_radius.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
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
    final sentiment = ref.watch(sentimentProvider);
    final featured = ref.watch(featuredAssetsProvider);
    final insight = ref.watch(marketInsightProvider);
    final signals = ref.watch(signalsProvider);
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async {
            ref.invalidate(sentimentProvider);
            ref.invalidate(featuredAssetsProvider);
            ref.invalidate(marketInsightProvider);
            ref.invalidate(signalsProvider);
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
                    const SectionHeader(title: 'Market pulse', subtitle: 'Demo data • Refresh for the latest mock snapshot'),
                    const SizedBox(height: AurumSpacing.sm),
                    sentiment.when(
                      data: (MarketSentiment data) => _MarketPulse(sentiment: data),
                      loading: () => const LoadingSkeleton(height: 176),
                      error: (_, __) => AurumErrorState(title: 'Unable to load market pulse', message: 'Try refreshing this demo workspace.', onRetry: () => ref.invalidate(sentimentProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    SectionHeader(title: 'Featured assets', actionLabel: 'View markets', onAction: () => context.go('/markets')),
                    const SizedBox(height: AurumSpacing.sm),
                    featured.when(
                      data: (List<MarketAsset> assets) => Column(
                        children: assets.map((MarketAsset asset) => Padding(
                          padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                          child: CryptoCard(
                            asset: asset,
                            isWatched: watched.contains(asset.id),
                            onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(asset.id),
                            onTap: () => context.push('/asset/${asset.id}'),
                          ),
                        )).toList(),
                      ),
                      loading: () => const _StackedSkeletons(count: 3),
                      error: (_, __) => AurumErrorState(title: 'Assets are unavailable', message: 'The demo market list could not be loaded.', onRetry: () => ref.invalidate(featuredAssetsProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'AI market insight', subtitle: 'Evidence-led analytical context'),
                    const SizedBox(height: AurumSpacing.sm),
                    insight.when(
                      data: (MarketInsight data) => AIInsightCard(insight: data, onTap: () => context.go('/ai-analysis')),
                      loading: () => const LoadingSkeleton(height: 170),
                      error: (_, __) => AurumErrorState(title: 'AI analysis unavailable', message: 'Market data remains available. Please try again shortly.', onRetry: () => ref.invalidate(marketInsightProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    SectionHeader(title: 'Current signals', actionLabel: 'View all', onAction: () => context.go('/signals')),
                    const SizedBox(height: AurumSpacing.sm),
                    signals.when(
                      data: (List<AnalysisSignal> data) => Column(
                        children: data.take(2).map((AnalysisSignal signal) => Padding(
                          padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                          child: SignalCard(signal: signal, onTap: () => context.push('/asset/${signal.assetId}')),
                        )).toList(),
                      ),
                      loading: () => const _StackedSkeletons(count: 2, height: 150),
                      error: (_, __) => AurumErrorState(title: 'Signals are unavailable', message: 'Refresh to try loading the latest demo signals.', onRetry: () => ref.invalidate(signalsProvider)),
                    ),
                    const SizedBox(height: AurumSpacing.xxl),
                    const SectionHeader(title: 'Quick actions'),
                    const SizedBox(height: AurumSpacing.sm),
                    _QuickActions(),
                    const SizedBox(height: AurumSpacing.md),
                    const Text('AURUM demo data is illustrative only • Not financial advice', style: AurumTypography.caption),
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
  const _MarketPulse({required this.sentiment});
  final MarketSentiment sentiment;

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      padding: const EdgeInsets.all(AurumSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(alignment: Alignment.center, children: <Widget>[
              SizedBox(width: 86, height: 86, child: CircularProgressIndicator(value: sentiment.score / 100, strokeWidth: 8, color: AurumColors.gold, backgroundColor: AurumColors.border)),
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text('${sentiment.score}', style: AurumTypography.priceCard),
                Text(sentiment.label, style: AurumTypography.caption),
              ]),
            ]),
          ),
          const SizedBox(width: AurumSpacing.lg),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Market sentiment', style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.xs),
            Text('${sentiment.change >= 0 ? '+' : ''}${sentiment.change.toStringAsFixed(0)} points from the prior reading', style: AurumTypography.body),
            const SizedBox(height: AurumSpacing.xs),
            Text('Source context • ${AurumFormatters.compactDate(sentiment.asOf)}', style: AurumTypography.caption),
          ])),
        ]),
        const SizedBox(height: AurumSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AurumSpacing.sm),
          decoration: BoxDecoration(color: AurumColors.surface, borderRadius: AurumRadius.control),
          child: const Text('Sentiment is one market context signal, not a forecast.', style: AurumTypography.caption),
        ),
      ]),
    );
  }
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
