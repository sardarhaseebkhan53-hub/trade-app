import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_radius.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../analysis/domain/analysis_models.dart';
import '../../analysis/domain/analysis_request.dart';
import '../../markets/data/chart_data_adapter.dart';
import '../../../shared/models/market_data_models.dart';
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
        title: asset.valueOrNull?.data.symbol ?? 'Asset',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: asset.when(
        loading: () => const LoadingList(count: 4),
        error: (_, __) => AurumErrorState(title: 'Asset unavailable', message: 'This demo asset is not currently available.', onRetry: () => ref.invalidate(assetProvider(widget.assetId))),
        data: (MarketSnapshot<MarketAsset> snapshot) => _Body(asset: snapshot.data, assetSnapshot: snapshot, watched: watched.contains(snapshot.data.id), timeframe: _timeframe, onTimeframeChanged: (String value) => setState(() => _timeframe = value), onWatchToggle: () => ref.read(watchlistProvider.notifier).toggle(snapshot.data.id)),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.asset, required this.assetSnapshot, required this.watched, required this.timeframe, required this.onTimeframeChanged, required this.onWatchToggle});
  final MarketAsset asset;
  final MarketSnapshot<MarketAsset> assetSnapshot;
  final bool watched;
  final String timeframe;
  final ValueChanged<String> onTimeframeChanged;
  final VoidCallback onWatchToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(chartProvider(ChartRequest(asset.id, timeframe)));
    final request = AnalysisRequest(assetId: asset.id, timeframe: timeframe);
    final technical = ref.watch(technicalAnalysisProvider(request));
    final multiTimeframe = ref.watch(multiTimeframeAnalysisProvider(asset.id));
    final statistics = ref.watch(statisticsProvider(asset.id));
    final analysis = ref.watch(aiAnalysisProvider(request));
    final signals = ref.watch(assetSignalRecordsProvider(request));
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          AssetHeader(asset: asset, isWatched: watched, onWatchToggle: onWatchToggle),
          const SizedBox(height: AurumSpacing.lg),
          Text(AurumFormatters.price(asset.price), style: AurumTypography.priceHero),
          const SizedBox(height: AurumSpacing.xs),
          Row(children: <Widget>[PriceChangeBadge(value: asset.change24h), const SizedBox(width: AurumSpacing.sm), Expanded(child: Text('24h movement • ${assetSnapshot.source} • ${assetSnapshot.freshnessLabel}', overflow: TextOverflow.ellipsis, style: AurumTypography.caption))]),
          const SizedBox(height: AurumSpacing.xl),
          _TimeframeSelector(value: timeframe, onChanged: onTimeframeChanged),
          const SizedBox(height: AurumSpacing.sm),
          chart.when(
            data: (MarketSnapshot<ChartSeries> snapshot) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[MarketChart(points: ChartDataAdapter.toLinePoints(snapshot.data), timeframe: timeframe), const SizedBox(height: AurumSpacing.xs), Text('${snapshot.source} • ${snapshot.sourceIntervalLabel ?? snapshot.data.sourceIntervalLabel} • ${snapshot.freshnessLabel}', style: AurumTypography.caption.copyWith(color: snapshot.isStale ? AurumColors.warning : AurumColors.textTertiary))]),
            loading: () => const LoadingSkeleton(height: 242),
            error: (_, __) => AurumErrorState(title: 'Chart unavailable', message: 'Try a different range or refresh.', onRetry: () => ref.invalidate(chartProvider(ChartRequest(asset.id, timeframe)))),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Technical context', subtitle: 'Calculated from the selected provider-derived chart series'),
          const SizedBox(height: AurumSpacing.sm),
          technical.when(
            data: (MarketAnalysis data) => data.isSufficient
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Wrap(spacing: AurumSpacing.xs, runSpacing: AurumSpacing.xs, children: data.toIndicatorChips().map((TechnicalIndicator indicator) => IndicatorChip(indicator: indicator)).toList()),
                    const SizedBox(height: AurumSpacing.sm),
                    _TechnicalSummary(analysis: data),
                  ])
                : _UnavailableCard(message: data.insufficiencyReason ?? 'Insufficient market data for reliable analysis.'),
            loading: () => const LoadingSkeleton(height: 42),
            error: (_, __) => const _UnavailableCard(message: 'Technical analysis is temporarily unavailable.'),
          ),
          const SizedBox(height: AurumSpacing.md),
          multiTimeframe.when(
            data: (Map<String, MarketAnalysis> values) => Wrap(spacing: AurumSpacing.xs, runSpacing: AurumSpacing.xs, children: values.entries.map((MapEntry<String, MarketAnalysis> entry) => _TimeframeBiasChip(timeframe: entry.key, bias: entry.value.bias)).toList()),
            loading: () => const LoadingSkeleton(height: 32),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'AURUM intelligence', subtitle: 'Structured interpretation of technical evidence'),
          const SizedBox(height: AurumSpacing.sm),
          analysis.when(
            data: (AiMarketAnalysis data) => _AiPreview(analysis: data, onTap: () => context.push('/ai-analysis?asset=${asset.id}')),
            loading: () => const LoadingSkeleton(height: 170),
            error: (_, __) => const _UnavailableCard(message: 'AI analysis is temporarily unavailable. Market data remains available.'),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Market statistics'),
          const SizedBox(height: AurumSpacing.sm),
          statistics.when(
            data: (MarketSnapshot<AssetStatistics> snapshot) => _StatisticsGrid(data: snapshot.data, freshness: '${snapshot.source} • ${snapshot.freshnessLabel}'),
            loading: () => const LoadingSkeleton(height: 160),
            error: (_, __) => const _UnavailableCard(message: 'Market statistics are temporarily unavailable.'),
          ),
          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Related signals'),
          const SizedBox(height: AurumSpacing.sm),
          signals.when(
            data: (List<SignalRecord> data) => data.isEmpty ? const _UnavailableCard(message: 'No analysis record is available for this asset yet.') : Column(children: data.map((SignalRecord signal) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: SignalCard(signal: signal))).toList()),
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

class _TechnicalSummary extends StatelessWidget {
  const _TechnicalSummary({required this.analysis});
  final MarketAnalysis analysis;

  @override
  Widget build(BuildContext context) => AurumCard(
    padding: const EdgeInsets.all(AurumSpacing.sm),
    child: Wrap(spacing: AurumSpacing.lg, runSpacing: AurumSpacing.xs, children: <Widget>[
      _TechnicalMetric(label: 'Trend', value: trendLabel(analysis.trend)),
      _TechnicalMetric(label: 'Volatility', value: analysis.volatility.state.name),
      _TechnicalMetric(label: 'Potential support', value: analysis.structure.support?.toStringAsFixed(2) ?? 'Unavailable'),
      _TechnicalMetric(label: 'Potential resistance', value: analysis.structure.resistance?.toStringAsFixed(2) ?? 'Unavailable'),
    ]),
  );
}

class _TechnicalMetric extends StatelessWidget {
  const _TechnicalMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[Text(label, style: AurumTypography.caption), const SizedBox(height: AurumSpacing.xxs), Text(value, style: AurumTypography.label)]);
}

class _AiPreview extends StatelessWidget {
  const _AiPreview({required this.analysis, required this.onTap});
  final AiMarketAnalysis analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AurumCard(
    onTap: onTap,
    borderColor: analyticalBiasColor(analysis.bias).withOpacity(0.45),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Row(children: <Widget>[const Icon(Icons.auto_awesome_outlined, color: AurumColors.gold, size: 18), const SizedBox(width: AurumSpacing.xs), Expanded(child: Text(biasLabel(analysis.bias), style: AurumTypography.h3)), Text('${analysis.analyticalStrength}/100', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft))]),
      const SizedBox(height: AurumSpacing.sm),
      Text(analysis.summary, style: AurumTypography.body),
      const SizedBox(height: AurumSpacing.sm),
      Text('${analysis.source} • ${AurumFormatters.compactDate(analysis.generatedAt)} • Strength is evidence, not certainty.', style: AurumTypography.caption),
    ]),
  );
}

class _TimeframeBiasChip extends StatelessWidget {
  const _TimeframeBiasChip({required this.timeframe, required this.bias});
  final String timeframe;
  final AnalyticalBias bias;
  @override
  Widget build(BuildContext context) {
    final color = analyticalBiasColor(bias);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.sm, vertical: AurumSpacing.xs),
      decoration: BoxDecoration(color: AurumColors.surface, borderRadius: AurumRadius.pill, border: Border.all(color: AurumColors.border)),
      child: Text('$timeframe: ${biasLabel(bias)}', style: AurumTypography.caption.copyWith(color: color)),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.data, required this.freshness});
  final AssetStatistics data;
  final String freshness;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('Market cap', _formatCompact(data.marketCap)),
      ('24h volume', _formatCompact(data.volume24h)),
      ('24h high', _formatPrice(data.dayHigh)),
      ('24h low', _formatPrice(data.dayLow)),
      ('Circulating', data.circulatingSupply),
      ('All-time high', _formatPrice(data.allTimeHigh)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AurumSpacing.xs,
      crossAxisSpacing: AurumSpacing.xs,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: entries.map((entry) => AurumCard(padding: const EdgeInsets.all(AurumSpacing.sm), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text(entry.$1, style: AurumTypography.caption), const SizedBox(height: AurumSpacing.xxs), Text(entry.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: AurumTypography.priceRow)]))).toList(),
    ),
      const SizedBox(height: AurumSpacing.xs),
      Text(freshness, style: AurumTypography.caption),
    ]);
  }

  String _formatCompact(double? value) =>
      value == null ? 'Unavailable' : AurumFormatters.compactCurrency(value);

  String _formatPrice(double? value) =>
      value == null ? 'Unavailable' : AurumFormatters.price(value);
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
