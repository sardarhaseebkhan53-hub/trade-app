import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/data_freshness_indicator.dart';
import '../../../shared/widgets/state_components.dart';

class AiAnalysisScreen extends ConsumerStatefulWidget {
  const AiAnalysisScreen({this.initialAssetId, super.key});
  final String? initialAssetId;

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen> {
  late String _assetId = widget.initialAssetId ?? 'bitcoin';
  String _timeframe = '1D';

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(featuredAssetsProvider).valueOrNull ?? [];
    final assets = featured.isNotEmpty ? featured : const [];

    return Scaffold(
      appBar: AurumAppBar(
        title: 'AURUM AI Desk',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AurumColors.goldSoft),
            onPressed: () => _showMethodology(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.sm, AurumSpacing.lg, AurumSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Structured market intelligence', style: AurumTypography.h2),
              const SizedBox(height: AurumSpacing.xs),
              Text(
                'Evidence-based interpretation of technical data. No predictions.',
                style: AurumTypography.body,
              ),
              const SizedBox(height: AurumSpacing.lg),

              if (assets.isNotEmpty)
                Wrap(
                  spacing: AurumSpacing.xs,
                  children: assets.map((a) => AurumFilterChip(
                    label: a.symbol,
                    selected: a.id == _assetId,
                    onSelected: (_) => setState(() => _assetId = a.id),
                  )).toList(),
                ),

              const SizedBox(height: AurumSpacing.sm),
              _TimeframeRow(value: _timeframe, onChanged: (v) => setState(() => _timeframe = v)),

              const SizedBox(height: AurumSpacing.xxl),

              // Simulated structured AI result (in real build this would come from backend + analysis)
              AurumCard(
                borderColor: AurumColors.gold.withOpacity(0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('CURRENT BIAS', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AurumColors.positive.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('BULLISH', style: AurumTypography.label.copyWith(color: AurumColors.positive)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AurumSpacing.sm),
                    Text('BTC shows constructive technical structure on the 1D timeframe.', style: AurumTypography.bodyLarge),
                    const SizedBox(height: AurumSpacing.md),
                    const _AiRow(label: 'Trend', value: 'Bullish'),
                    const _AiRow(label: 'Momentum', value: 'Positive'),
                    const _AiRow(label: 'Volatility', value: 'Normal'),
                    const SizedBox(height: AurumSpacing.md),
                    const Text('Supporting factors', style: AurumTypography.label),
                    const SizedBox(height: 4),
                    const Text('• Price holding above key moving averages\n• Rising volume on up moves\n• Constructive price structure', style: AurumTypography.body),
                    const SizedBox(height: AurumSpacing.sm),
                    const Text('Risk & invalidation', style: AurumTypography.label),
                    const Text('Break below recent swing low would invalidate the bullish view.', style: AurumTypography.caption),
                  ],
                ),
              ),

              const SizedBox(height: AurumSpacing.lg),
              const DataFreshnessIndicator(
                freshness: DataFreshness.live,
                lastUpdated: null,
              ),
              const SizedBox(height: AurumSpacing.xs),
              Text(
                'AI analysis uses latest available market data. Check freshness before decisions.',
                style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMethodology(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How AURUM AI works', style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.sm),
            const Text(
              'The AI receives structured technical analysis (trend, momentum, volume, volatility, price structure) from the engine. '
              'It returns validated explanations only — never price targets or trading advice.',
              style: AurumTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeframeRow extends StatelessWidget {
  const _TimeframeRow({required this.value, required this.onChanged, super.key});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AurumSpacing.xs,
      children: ['1H', '4H', '1D', '1W'].map((t) => AurumFilterChip(
        label: t,
        selected: value == t,
        onSelected: (_) => onChanged(t),
      )).toList(),
    );
  }
}

class _AiRow extends StatelessWidget {
  const _AiRow({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: AurumTypography.caption)),
        Text(value, style: AurumTypography.body),
      ],
    ),
  );
}
