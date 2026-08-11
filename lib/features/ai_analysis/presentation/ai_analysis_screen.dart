import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../analysis/domain/analysis_models.dart';
import '../../analysis/domain/analysis_request.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key, this.initialAssetId});
  final String? initialAssetId;

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  late String _assetId = widget.initialAssetId ?? 'bitcoin';
  String _timeframe = '1D';

  @override
  Widget build(BuildContext context) {
    final request = AnalysisRequest(assetId: _assetId, timeframe: _timeframe);
    final analysis = ref.watch(aiAnalysisProvider(request));
    final assets = ref.watch(featuredAssetsProvider).valueOrNull?.data ?? const <MarketAsset>[];
    return Scaffold(
      appBar: AurumAppBar(
        title: 'AURUM AI Desk',
        actions: <Widget>[
          IconButton(
            tooltip: 'Analysis methodology',
            onPressed: () => _showMethodology(context),
            icon: const Icon(Icons.info_outline_rounded, color: AurumColors.goldSoft),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async {
            ref.invalidate(technicalAnalysisProvider(request));
            ref.invalidate(aiAnalysisProvider(request));
            await ref.read(aiAnalysisProvider(request).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Structured market intelligence', style: AurumTypography.h2),
              const SizedBox(height: AurumSpacing.xs),
              const Text('AURUM interprets supplied technical evidence, conflicts and risk factors. It does not predict outcomes or provide financial advice.', style: AurumTypography.body),
              const SizedBox(height: AurumSpacing.lg),
              _AssetChooser(assets: assets, selectedId: _assetId, onSelected: (String value) => setState(() => _assetId = value)),
              const SizedBox(height: AurumSpacing.sm),
              _TimeframeChooser(value: _timeframe, onSelected: (String value) => setState(() => _timeframe = value)),
              const SizedBox(height: AurumSpacing.xxl),
              analysis.when(
                data: (AiMarketAnalysis data) => _AnalysisBody(analysis: data),
                loading: () => const _AnalysisLoading(),
                error: (_, __) => AurumErrorState(title: 'Analysis is temporarily unavailable', message: 'Market data may still be available. Please try again shortly.', onRetry: () => ref.invalidate(aiAnalysisProvider(request))),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showMethodology(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('Analysis methodology', style: AurumTypography.h2),
          const SizedBox(height: AurumSpacing.md),
          const Text('Trend, momentum, volume, volatility and price structure contribute documented evidence. Analytical strength is not a probability of profit or accuracy.', style: AurumTypography.body),
          const SizedBox(height: AurumSpacing.md),
          const Text('A remote AI provider, when enabled later, receives this structured context through an AURUM backend. It must not invent data or offer trading instructions.', style: AurumTypography.body),
          const SizedBox(height: AurumSpacing.sm),
        ]),
      ),
    );
  }
}

class _AssetChooser extends StatelessWidget {
  const _AssetChooser({required this.assets, required this.selectedId, required this.onSelected});
  final List<MarketAsset> assets;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const LoadingSkeleton(height: 44);
    return Wrap(spacing: AurumSpacing.xs, runSpacing: AurumSpacing.xs, children: assets.map((MarketAsset asset) => AurumFilterChip(label: asset.symbol, selected: asset.id == selectedId, onSelected: (_) => onSelected(asset.id))).toList());
  }
}

class _TimeframeChooser extends StatelessWidget {
  const _TimeframeChooser({required this.value, required this.onSelected});
  final String value;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(spacing: AurumSpacing.xs, children: <String>['1H', '4H', '1D', '1W'].map((String item) => AurumFilterChip(label: item, selected: value == item, onSelected: (_) => onSelected(item))).toList());
}

class _AnalysisBody extends StatelessWidget {
  const _AnalysisBody({required this.analysis});
  final AiMarketAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final tone = analyticalBiasColor(analysis.bias);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      AurumCard(
        color: AurumColors.surface,
        borderColor: tone.withOpacity(0.45),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('CURRENT BIAS', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.1)),
              const SizedBox(height: AurumSpacing.xs),
              Text(biasLabel(analysis.bias), style: AurumTypography.h2),
            ])),
            Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AurumColors.ink, shape: BoxShape.circle, border: Border.all(color: AurumColors.gold.withOpacity(0.65))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text('${analysis.analyticalStrength}/100', style: AurumTypography.priceRow.copyWith(color: AurumColors.goldSoft)), const Text('strength', style: AurumTypography.caption)]),
            ),
          ]),
          const SizedBox(height: AurumSpacing.md),
          Text(analysis.summary, style: AurumTypography.bodyLarge.copyWith(color: AurumColors.textPrimary)),
          const SizedBox(height: AurumSpacing.sm),
          const Text('Analytical strength reflects documented technical evidence, not a probability of profit or certainty.', style: AurumTypography.caption),
        ]),
      ),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Technical evidence'),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.trending_up_rounded, title: 'Trend', value: analysis.trend),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.speed_rounded, title: 'Momentum', value: analysis.momentum),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.waterfall_chart_rounded, title: 'Volatility', value: analysis.volatility),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Supporting factors'),
      const SizedBox(height: AurumSpacing.sm),
      _FactorList(values: analysis.supportingFactors, icon: Icons.check_circle_outline_rounded, color: AurumColors.positive, empty: 'No supporting factor was strong enough to highlight.'),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Conflicting factors'),
      const SizedBox(height: AurumSpacing.sm),
      _FactorList(values: analysis.conflictingFactors, icon: Icons.compare_arrows_rounded, color: AurumColors.warning, empty: 'No material conflict was identified in the available data.'),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Potential scenarios', subtitle: 'Conditional context, not outcomes'),
      const SizedBox(height: AurumSpacing.sm),
      ...analysis.scenarios.map((AnalysisScenario scenario) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: _ScenarioCard(scenario: scenario))),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Risk & invalidation'),
      const SizedBox(height: AurumSpacing.sm),
      AurumCard(
        color: AurumColors.warning.withOpacity(0.07),
        borderColor: AurumColors.warning.withOpacity(0.4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          _FactorList(values: analysis.riskFactors, icon: Icons.warning_amber_rounded, color: AurumColors.warning, empty: 'General market risk remains.'),
          const Divider(),
          Text('What could change this analysis', style: AurumTypography.label.copyWith(color: AurumColors.textPrimary)),
          const SizedBox(height: AurumSpacing.xs),
          ...analysis.invalidationConditions.map((String value) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.xs), child: Text('• $value', style: AurumTypography.body))),
          const Divider(),
          Text('${analysis.source} • Last analyzed ${AurumFormatters.compactDate(analysis.generatedAt)} • Data ${AurumFormatters.compactDate(analysis.dataAsOf)} • ${analysis.timeframe}', style: AurumTypography.caption),
        ]),
      ),
    ]);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => AurumCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Icon(icon, color: AurumColors.gold, size: 20), const SizedBox(width: AurumSpacing.sm), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: AurumTypography.h3), const SizedBox(height: AurumSpacing.xxs), Text(value, style: AurumTypography.body)]))]));
}

class _FactorList extends StatelessWidget {
  const _FactorList({required this.values, required this.icon, required this.color, required this.empty});
  final List<String> values;
  final IconData icon;
  final Color color;
  final String empty;
  @override
  Widget build(BuildContext context) => AurumCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: (values.isEmpty ? <String>[empty] : values).map((String value) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Icon(icon, color: color, size: 18), const SizedBox(width: AurumSpacing.xs), Expanded(child: Text(value, style: AurumTypography.body))]))).toList()));
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario});
  final AnalysisScenario scenario;
  @override
  Widget build(BuildContext context) {
    final color = directionColor(scenario.direction);
    return AurumCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(scenario.label, style: AurumTypography.h3.copyWith(color: color)), const SizedBox(height: AurumSpacing.xs), Text(scenario.condition, style: AurumTypography.label), const SizedBox(height: AurumSpacing.xxs), Text(scenario.context, style: AurumTypography.body)]));
  }
}

class _AnalysisLoading extends StatelessWidget {
  const _AnalysisLoading();
  @override
  Widget build(BuildContext context) => const Column(children: <Widget>[LoadingSkeleton(height: 210), SizedBox(height: AurumSpacing.xxl), LoadingSkeleton(height: 96), SizedBox(height: AurumSpacing.sm), LoadingSkeleton(height: 96), SizedBox(height: AurumSpacing.sm), LoadingSkeleton(height: 96)]);
}
