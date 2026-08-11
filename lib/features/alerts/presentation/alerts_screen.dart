import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/user_data_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/state_components.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    return Scaffold(
      appBar: AurumAppBar(
        title: 'Price alerts',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Create price alert',
            onPressed: () => _showCreateAlert(context, ref),
            icon: const Icon(Icons.add_alert_outlined, color: AurumColors.goldSoft),
          ),
        ],
      ),
      body: alerts.when(
        loading: () => const LoadingList(count: 3),
        error: (_, __) => AurumErrorState(title: 'Alerts unavailable', message: 'Sign in and check your connection to manage price alerts.', onRetry: () => ref.invalidate(alertsProvider)),
        data: (List<PriceAlert> values) {
          if (values.isEmpty) {
            return AurumEmptyState(title: 'No price alerts yet', message: 'Create an above or below alert for a saved market level.', icon: Icons.add_alert_outlined, actionLabel: 'Create alert', onAction: () => _showCreateAlert(context, ref));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AurumSpacing.lg),
            itemCount: values.length,
            separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
            itemBuilder: (BuildContext context, int index) => _AlertCard(alert: values[index]),
          );
        },
      ),
    );
  }

  Future<void> _showCreateAlert(BuildContext context, WidgetRef ref) async {
    final assetController = TextEditingController();
    final priceController = TextEditingController();
    var condition = AlertCondition.above;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(AurumSpacing.lg, AurumSpacing.lg, AurumSpacing.lg, MediaQuery.viewInsetsOf(context).bottom + AurumSpacing.lg),
        child: StatefulBuilder(builder: (BuildContext context, StateSetter setSheetState) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('Create price alert', style: AurumTypography.h2),
          const SizedBox(height: AurumSpacing.md),
          TextField(controller: assetController, textCapitalization: TextCapitalization.none, decoration: const InputDecoration(hintText: 'Asset ID, for example bitcoin')),
          const SizedBox(height: AurumSpacing.sm),
          TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: 'Target price in USD')),
          const SizedBox(height: AurumSpacing.sm),
          SegmentedButton<AlertCondition>(segments: const <ButtonSegment<AlertCondition>>[
            ButtonSegment<AlertCondition>(value: AlertCondition.above, label: Text('Above')),
            ButtonSegment<AlertCondition>(value: AlertCondition.below, label: Text('Below')),
          ], selected: <AlertCondition>{condition}, onSelectionChanged: (Set<AlertCondition> value) => setSheetState(() => condition = value.first)),
          const SizedBox(height: AurumSpacing.lg),
          AurumButton(label: 'Save alert', onPressed: () async {
            final assetId = assetController.text.trim().toLowerCase();
            final target = double.tryParse(priceController.text.trim());
            if (assetId.isEmpty || target == null || target <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid asset ID and positive target price.')));
              return;
            }
            await ref.read(alertRepositoryProvider).createAlert(assetId: assetId, condition: condition, targetPrice: target);
            ref.invalidate(alertsProvider);
            if (context.mounted) context.pop();
          }),
        ])),
      ),
    );
    assetController.dispose();
    priceController.dispose();
  }
}

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});
  final PriceAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AurumCard(
    child: Row(children: <Widget>[
      Container(width: 38, height: 38, alignment: Alignment.center, decoration: const BoxDecoration(color: AurumColors.surfaceElevated, shape: BoxShape.circle), child: Icon(alert.condition == AlertCondition.above ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: AurumColors.gold)),
      const SizedBox(width: AurumSpacing.sm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(alert.assetId.toUpperCase(), style: AurumTypography.h3), const SizedBox(height: AurumSpacing.xxs), Text('${alert.condition.name} ${AurumFormatters.price(alert.targetPrice)} • ${alert.status.name}', style: AurumTypography.body)])),
      IconButton(tooltip: 'Delete alert', onPressed: () async { await ref.read(alertRepositoryProvider).deleteAlert(alert.id); ref.invalidate(alertsProvider); }, icon: const Icon(Icons.delete_outline_rounded, color: AurumColors.negative)),
    ]),
  );
}
