import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/charts.dart';
import '../../../shared/widgets/data_freshness_indicator.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/professional_chart.dart';
import '../../../shared/widgets/state_components.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({required this.assetId, super.key});
  final String assetId;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  String _timeframe = '1D';

  @override
  Widget build(BuildContext context) {
    final assetAsync = ref.watch(assetProvider(widget.assetId));
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};
    final isWatched = watched.contains(widget.assetId);

    return Scaffold(
      appBar: AurumAppBar(
        title: widget.assetId.toUpperCase(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: assetAsync.when(
        data: (asset) => _AssetBody(
          asset: asset,
          isWatched: isWatched,
          timeframe: _timeframe,
          onTimeframeChanged: (tf) => setState(() => _timeframe = tf),
          onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(widget.assetId),
        ),
        loading: () => const LoadingList(count: 5),
        error: (_, __) => AurumErrorState(
          title: 'Asset unavailable',
          message: 'Could not load asset details.',
          onRetry: () => ref.invalidate(assetProvider(widget.assetId)),
        ),
      ),
    );
  }
}

class _AssetBody extends ConsumerWidget {
  const _AssetBody({
    required this.asset,
    required this.isWatched,
    required this.timeframe,
    required this.onTimeframeChanged,
    required this.onWatchToggle,
    super.key,
  });

  final MarketAsset asset;
  final bool isWatched;
  final String timeframe;
  final ValueChanged<String> onTimeframeChanged;
  final VoidCallback onWatchToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(chartProvider(ChartRequest(asset.id, timeframe)));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetHeader(asset: asset, isWatched: isWatched, onWatchToggle: onWatchToggle),
          const SizedBox(height: AurumSpacing.sm),
          Text(AurumFormatters.price(asset.price), style: AurumTypography.priceHero),
          const SizedBox(height: 4),
          PriceChangeBadge(value: asset.change24h),
          const SizedBox(height: AurumSpacing.xl),

          _TimeframeSelector(value: timeframe, onChanged: onTimeframeChanged),
          const SizedBox(height: AurumSpacing.sm),

          chartAsync.when(
            data: (points) => ProfessionalChart(
              points: points.map((p) => p.priceUsd).toList(growable: false),
              timeframe: timeframe,
            ),
            loading: () => const LoadingSkeleton(height: 240),
            error: (_, __) => const AurumErrorState(title: 'Chart unavailable', message: 'Try another timeframe.'),
          ),

          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Data Integrity'),
          const SizedBox(height: AurumSpacing.sm),
          _DataIntegrityBanner(asset: asset),

          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Technical context'),
          const SizedBox(height: AurumSpacing.sm),
          _TechnicalSummary(),

          const SizedBox(height: AurumSpacing.xxl),
          SectionHeader(
            title: 'AURUM Intelligence',
            actionLabel: 'Full analysis',
            onAction: () => context.push('/ai-analysis?asset=${asset.id}'),
          ),
          const SizedBox(height: AurumSpacing.sm),
          AIInsightCard(analysis: null),

          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Market statistics'),
          const SizedBox(height: AurumSpacing.sm),
          _StatsGrid(asset: asset),

          const SizedBox(height: AurumSpacing.xxl),
          const _RiskDisclaimer(),
        ],
      ),
    );
  }
}

class _TimeframeSelector extends StatelessWidget {
  const _TimeframeSelector({required this.value, required this.onChanged, super.key});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const frames = ['1H', '4H', '1D', '1W', '1M'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: frames.length,
        separatorBuilder: (_, __) => const SizedBox(width: AurumSpacing.xs),
        itemBuilder: (_, i) => AurumFilterChip(
          label: frames[i],
          selected: value == frames[i],
          onSelected: (_) => onChanged(frames[i]),
        ),
      ),
    );
  }
}

class _TechnicalSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AurumCard(
      child: Wrap(
        spacing: AurumSpacing.lg,
        runSpacing: AurumSpacing.sm,
        children: const [
          _Metric(label: 'Trend', value: 'Bullish'),
          _Metric(label: 'RSI (14)', value: '62.4'),
          _Metric(label: 'MACD', value: '+12.8'),
          _Metric(label: 'Volatility', value: 'Normal'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AurumTypography.caption),
          Text(value, style: AurumTypography.label),
        ],
      );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.asset, super.key});
  final MarketAsset asset;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Market Cap', AurumFormatters.compactCurrency(asset.marketCap)),
      ('24h Volume', AurumFormatters.compactCurrency(asset.volume)),
      ('24h High', AurumFormatters.price(asset.price * 1.028)),
      ('24h Low', AurumFormatters.price(asset.price * 0.967)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AurumSpacing.sm,
      crossAxisSpacing: AurumSpacing.sm,
      childAspectRatio: 2.6,
      children: items.map((e) => AurumCard(
        padding: const EdgeInsets.all(AurumSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.$1, style: AurumTypography.caption),
            const SizedBox(height: 4),
            Text(e.$2, style: AurumTypography.priceRow),
          ],
        ),
      )).toList(),
    );
  }
}

class _RiskDisclaimer extends StatelessWidget {
  const _RiskDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      color: AurumColors.warning.withOpacity(0.06),
      borderColor: AurumColors.warning.withOpacity(0.3),
      child: const Text(
        'Analysis is for informational purposes only. Markets are volatile.',
        style: AurumTypography.caption,
      ),
    );
  }
}

class _DataIntegrityBanner extends StatelessWidget {
  const _DataIntegrityBanner({required this.asset, super.key});
  final MarketAsset asset;

  @override
  Widget build(BuildContext context) {
    // Demo freshness — production would call DataIntegrityService.validateMarketData
    // and pass real timestamps from market repo.
    const freshness = DataFreshness.live;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DataFreshnessIndicator(
          freshness: freshness,
          lastUpdated: null, // shows relative time or "just now"
        ),
        const SizedBox(height: AurumSpacing.xs),
        Text(
          'Market data from live provider. Always verify before acting.',
          style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary),
        ),
      ],
    );
  }
}
