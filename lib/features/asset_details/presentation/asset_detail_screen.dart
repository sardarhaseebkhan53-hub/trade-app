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
import '../../../shared/widgets/charts.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({required this.assetId, super.key});
  final String assetId;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  static const _timeframes = <String>['1H', '4H', '1D', '1W', '1M', '1Y'];
  String _timeframe = '1D';

  @override
  Widget build(BuildContext context) {
    final asset = ref.watch(assetProvider(widget.assetId));
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};
    return Scaffold(
      appBar: AurumAppBar(
        title: asset.valueOrNull?.symbol ?? 'Asset',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: asset.when(
        loading: () => const LoadingList(count: 4),
        error: (_, __) => AurumErrorState(title: 'Asset unavailable', message: 'This demo asset is not currently available.', onRetry: () => ref.invalidate(assetProvider(widget.assetId))),
        data: (MarketAsset data) => _Body(asset: data, watched: watched.contains(data.id), timeframe: _timeframe, onTimeframeChanged: (String value) => setState(() => _timeframe = value), onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(data.id)),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.asset, required this.watched, required this.timeframe, required this.onTimeframeChanged, required this.onWatchToggle});
  final MarketAsset asset;
  final bool watched;
  final String timeframe;
  final ValueChanged<String> onTimeframeChanged;
  final VoidCallback onWatchToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(chartProvider(ChartRequest(asset.id, timeframe)));
    final indicators = ref.watch(indicatorsProvider(asset.id));
    final statistics = ref.watch(statisticsProvider(asset.id));
    final analysis = ref.watch(aiAnalysisProvider(asset.id));
    final signals = ref.watch(assetSignalsProvider(asset.id));
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          AssetHeader(asset: asset, isWatched: watched, onWatchToggle: onWatchToggle),
          const SizedBox(height: AurumSpacing.lg),
          Text(AurumFormatters.price(asset.price), style: AurumTypography.priceHero),
          const SizedBox(height: AurumSpacing.xs),
          Row(children: <Widget>[PriceChangeBadge(value: asset.change24h), const SizedBox(width: AurumSpacing.sm), const Text('24h movement • Demo data', style: AurumTypography.caption)]),
          const SizedBox(height: AurumSpacing.xl),
          _TimeframeSelector(value: timeframe, onChanged: onTimeframeChanged),
          const SizedBox(height: AurumSpacing.sm),
          chart.when(
            data: (List<double> points) => MarketChart(points: points, timeframe: timeframe),
            loading: () => const LoadingSkeleton(height: 242),
            error: (_, __) => AurumErrorState(title: 'Chart unavailable', message: 'Try a different range or refresh.', onRetry: () => ref.invalidate(chartProvider(ChartRequest(asset.id, timeframe)))),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Technical context', subtitle: 'Tap an indicator for its interpretation'),
          const SizedBox(height: AurumSpacing.sm),
          indicators.when(
            data: (List<TechnicalIndicator> data) => Wrap(spacing: AurumSpacing.xs, runSpacing: AurumSpacing.xs, children: data.map((TechnicalIndicator indicator) => IndicatorChip(indicator: indicator)).toList()),
            loading: () => const LoadingSkeleton(height: 42),
            error: (_, __) => const Text('Indicators are temporarily unavailable.', style: AurumTypography.body),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'AI analysis', subtitle: 'Structured market context, not a prediction'),
          const SizedBox(height: AurumSpacing.sm),
          analysis.when(
            data: (AiAnalysis data) => _AiPreview(analysis: data, onTap: () => context.push('/ai-analysis?asset=${asset.id}')),
            loading: () => const LoadingSkeleton(height: 170),
            error: (_, __) => const _UnavailableCard(message: 'AI analysis is temporarily unavailable. Market data remains available.'),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Market statistics'),
          const SizedBox(height: AurumSpacing.sm),
          statistics.when(
            data: (AssetStatistics data) => _StatisticsGrid(data: data),
            loading: () => const LoadingSkeleton(height: 160),
            error: (_, __) => const _UnavailableCard(message: 'Market statistics are temporarily unavailable.'),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Related signals'),
          const SizedBox(height: AurumSpacing.sm),
          signals.when(
            data: (List<AnalysisSignal> data) => data.isEmpty ? const _UnavailableCard(message: 'No current analytical signals for this asset.') : Column(children: data.map((AnalysisSignal signal) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: SignalCard(signal: signal))).toList()),
            loading: () => const LoadingSkeleton(height: 150),
            error: (_, __) => const _UnavailableCard(message: 'Signals are temporarily unavailable.'),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          _RiskCard(),
        ]),
      ),
    );
  }
}

class _TimeframeSelector extends StatelessWidget {
  const _TimeframeSelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <String>['1H', '4H', '1D', '1W', '1M', '1Y'].map((String item) => Padding(
        padding: const EdgeInsets.only(right: AurumSpacing.xs),
        child: AurumFilterChip(label: item, selected: value == item, onSelected: (_) => onChanged(item)),
      )).toList(),
    ),
  );
}

class _AiPreview extends StatelessWidget {
  const _AiPreview({required this.analysis, required this.onTap});
  final AiAnalysis analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AurumCard(
    onTap: onTap,
    borderColor: directionColor(analysis.direction).withOpacity(0.45),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Row(children: <Widget>[const Icon(Icons.auto_awesome_outlined, color: AurumColors.gold, size: 18), const SizedBox(width: AurumSpacing.xs), Expanded(child: Text(analysis.headline, style: AurumTypography.h3)), Text('${analysis.confidence}% model confidence', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft))]),
      const SizedBox(height: AurumSpacing.sm),
      Text(analysis.summary, style: AurumTypography.body),
      const SizedBox(height: AurumSpacing.sm),
      Text('Confidence reflects model uncertainty, not certainty. ${AurumFormatters.compactDate(analysis.asOf)}', style: AurumTypography.caption),
    ]),
  );
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.data});
  final AssetStatistics data;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('Market cap', AurumFormatters.compactCurrency(data.marketCap)),
      ('24h volume', AurumFormatters.compactCurrency(data.volume24h)),
      ('24h high', AurumFormatters.price(data.dayHigh)),
      ('24h low', AurumFormatters.price(data.dayLow)),
      ('Circulating', data.circulatingSupply),
      ('All-time high', AurumFormatters.price(data.allTimeHigh)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AurumSpacing.xs,
      crossAxisSpacing: AurumSpacing.xs,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: entries.map((entry) => AurumCard(padding: const EdgeInsets.all(AurumSpacing.sm), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text(entry.$1, style: AurumTypography.caption), const SizedBox(height: AurumSpacing.xxs), Text(entry.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: AurumTypography.priceRow)]))).toList(),
    );
  }
}

class _RiskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AurumCard(
    color: AurumColors.warning.withOpacity(0.07),
    borderColor: AurumColors.warning.withOpacity(0.42),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      const Icon(Icons.shield_outlined, color: AurumColors.warning, size: 20),
      const SizedBox(width: AurumSpacing.sm),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Risk information', style: AurumTypography.h3), SizedBox(height: AurumSpacing.xxs), Text('Market conditions can change quickly. Indicators and scenarios describe context only; they are not financial advice.', style: AurumTypography.body)])),
    ]),
  );
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => AurumCard(child: Text(message, style: AurumTypography.body));
}
