import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../analysis/domain/analysis_models.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class SignalsScreen extends ConsumerStatefulWidget {
  const SignalsScreen({super.key});

  @override
  ConsumerState<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends ConsumerState<SignalsScreen> {
  var _history = false;

  @override
  Widget build(BuildContext context) {
    final signals = ref.watch(signalsProvider);
    return Scaffold(
      appBar: AurumAppBar(title: 'Signals', actions: <Widget>[IconButton(tooltip: 'Filter signals', onPressed: () => _showFilters(context), icon: const Icon(Icons.tune_rounded, color: AurumColors.goldSoft))]),
      body: SafeArea(
        top: false,
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AurumSpacing.lg),
            child: SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text('Active')),
                ButtonSegment<bool>(value: true, label: Text('History')),
              ],
              selected: <bool>{_history},
              onSelectionChanged: (Set<bool> value) => setState(() => _history = value.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) => states.contains(WidgetState.selected) ? AurumColors.ink : AurumColors.textSecondary),
                backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) => states.contains(WidgetState.selected) ? AurumColors.gold : AurumColors.surface),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.lg),
            child: Row(children: <Widget>[Text(_history ? 'HISTORICAL RECORDS' : 'CURRENT ANALYTICAL CONTEXT', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft, letterSpacing: 1.1)), const Spacer(), const Text('Rule-based', style: AurumTypography.caption)]),
          ),
          const SizedBox(height: AurumSpacing.sm),
          Expanded(child: signals.when(
            data: (List<SignalRecord> data) {
              final shown = _history
                  ? data.where((SignalRecord item) => item.effectiveStatus == SignalLifecycle.invalidated || item.effectiveStatus == SignalLifecycle.expired).toList()
                  : data.where((SignalRecord item) => item.effectiveStatus == SignalLifecycle.active || item.effectiveStatus == SignalLifecycle.updated).toList();
              if (shown.isEmpty) return const AurumEmptyState(title: 'No active signals right now', message: 'New multi-factor analysis records will appear when sufficient market data is available.', icon: Icons.insights_outlined);
              return RefreshIndicator(color: AurumColors.gold, onRefresh: () async { ref.invalidate(signalsProvider); await ref.read(signalsProvider.future); }, child: ListView.separated(padding: const EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.xs, AurumSpacing.lg, AurumSpacing.xxl), itemCount: shown.length, separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm), itemBuilder: (BuildContext context, int index) => SignalCard(signal: shown[index], onTap: () => context.push('/asset/${shown[index].assetId}'))));
            },
            loading: () => const LoadingList(count: 3),
            error: (_, __) => AurumErrorState(title: 'Signals are unavailable', message: 'Refresh to regenerate the latest technical context.', onRetry: () => ref.invalidate(signalsProvider)),
          )),
        ]),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(context: context, builder: (BuildContext context) => Padding(padding: const EdgeInsets.all(AurumSpacing.lg), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Signal filters', style: AurumTypography.h2), const SizedBox(height: AurumSpacing.lg), Wrap(spacing: AurumSpacing.xs, runSpacing: AurumSpacing.xs, children: <Widget>[AurumFilterChip(label: 'All assets', selected: true, onSelected: (_) {}), AurumFilterChip(label: 'Bullish', selected: false, onSelected: (_) {}), AurumFilterChip(label: 'Moderate risk', selected: false, onSelected: (_) {})]), const SizedBox(height: AurumSpacing.lg), const Text('Filtering controls are presentation-only while signal preferences move to Phase 6.', style: AurumTypography.caption)])));
  }
}
