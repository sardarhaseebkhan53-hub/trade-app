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

class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({super.key, this.initialAssetId});
  final String? initialAssetId;

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  late String _assetId = widget.initialAssetId ?? 'bitcoin';

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(aiAnalysisProvider(_assetId));
    final assets = ref.watch(featuredAssetsProvider).valueOrNull ?? const <MarketAsset>[];
    return Scaffold(
      appBar: AurumAppBar(
        title: 'AURUM AI Desk',
        actions: <Widget>[
          IconButton(tooltip: 'Analysis history', onPressed: () => _showHistory(context), icon: const Icon(Icons.history_rounded, color: AurumColors.goldSoft)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AurumColors.gold,
          onRefresh: () async => ref.invalidate(aiAnalysisProvider(_assetId)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Evidence-led market research', style: AurumTypography.h2),
              const SizedBox(height: AurumSpacing.xs),
              const Text('Choose a market context to review trend, momentum, possible scenarios and limitations.', style: AurumTypography.body),
              const SizedBox(height: AurumSpacing.lg),
              _AssetChooser(assets: assets, selectedId: _assetId, onSelected: (String value) => setState(() => _assetId = value)),
              const SizedBox(height: AurumSpacing.xxl),
              analysis.when(
                data: (AiAnalysis data) => _AnalysisBody(analysis: data),
                loading: () => const _AnalysisLoading(),
                error: (_, __) => AurumErrorState(title: 'AI analysis is temporarily unavailable', message: 'Market data remains available. Please try again shortly.', onRetry: () => ref.invalidate(aiAnalysisProvider(_assetId))),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('Recent demo analyses', style: AurumTypography.h2),
          const SizedBox(height: AurumSpacing.md),
          const ListTile(leading: Icon(Icons.auto_awesome_outlined, color: AurumColors.gold), title: Text('Bitcoin market context'), subtitle: Text('Updated moments ago • Demo result')),
          const ListTile(leading: Icon(Icons.auto_awesome_outlined, color: AurumColors.gold), title: Text('Ethereum technical view'), subtitle: Text('Yesterday • Demo result')),
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
    return Wrap(
      spacing: AurumSpacing.xs,
      runSpacing: AurumSpacing.xs,
      children: assets.map((MarketAsset asset) => AurumFilterChip(label: asset.symbol, selected: asset.id == selectedId, onSelected: (_) => onSelected(asset.id))).toList(),
    );
  }
}

class _AnalysisBody extends StatelessWidget {
  const _AnalysisBody({required this.analysis});
  final AiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final tone = directionColor(analysis.direction);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      AurumCard(
        color: AurumColors.surface,
        borderColor: tone.withOpacity(0.45),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('MARKET ASSESSMENT', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.1)),
              const SizedBox(height: AurumSpacing.xs),
              Text(analysis.headline, style: AurumTypography.h2),
            ])),
            Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AurumColors.ink, shape: BoxShape.circle, border: Border.all(color: AurumColors.gold.withOpacity(0.65))),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text('${analysis.confidence}%', style: AurumTypography.priceCard.copyWith(color: AurumColors.goldSoft)), Text('confidence', style: AurumTypography.caption)]),
            ),
          ]),
          const SizedBox(height: AurumSpacing.md),
          Text(analysis.summary, style: AurumTypography.bodyLarge.copyWith(color: AurumColors.textPrimary)),
          const SizedBox(height: AurumSpacing.sm),
          Text('Model confidence represents uncertainty in this structured demo analysis; it is not a prediction.', style: AurumTypography.caption),
        ]),
      ),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Technical view'),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.trending_up_rounded, title: 'Trend', value: analysis.technicalView),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.speed_rounded, title: 'Momentum', value: analysis.momentum),
      const SizedBox(height: AurumSpacing.sm),
      _MetricCard(icon: Icons.waterfall_chart_rounded, title: 'Volatility', value: analysis.volatility),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Key observations'),
      const SizedBox(height: AurumSpacing.sm),
      AurumCard(child: Column(children: analysis.observations.map((String value) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Icon(Icons.check_circle_outline_rounded, color: AurumColors.gold, size: 18), const SizedBox(width: AurumSpacing.xs), Expanded(child: Text(value, style: AurumTypography.body))]))).toList())),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Potential scenarios', subtitle: 'Conditional context, not outcomes'),
      const SizedBox(height: AurumSpacing.sm),
      ...analysis.scenarios.map((AnalysisScenario scenario) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: _ScenarioCard(scenario: scenario))),
      const SizedBox(height: AurumSpacing.xxl),
      const SectionHeader(title: 'Risk factors'),
      const SizedBox(height: AurumSpacing.sm),
      AurumCard(
        color: AurumColors.warning.withOpacity(0.07),
        borderColor: AurumColors.warning.withOpacity(0.4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          ...analysis.risks.map((String risk) => Padding(padding: const EdgeInsets.only(bottom: AurumSpacing.sm), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Icon(Icons.warning_amber_rounded, color: AurumColors.warning, size: 18), const SizedBox(width: AurumSpacing.xs), Expanded(child: Text(risk, style: AurumTypography.body))]))),
          const Divider(),
          Text('Last updated ${AurumFormatters.compactDate(analysis.asOf)} • Demo analysis • Not financial advice', style: AurumTypography.caption),
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
