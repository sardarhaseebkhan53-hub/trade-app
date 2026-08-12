import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        title: 'Price Alerts',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: AurumColors.goldSoft),
            onPressed: () => _showCreateAlert(context, ref),
          ),
        ],
      ),
      body: alerts.when(
        data: (list) {
          if (list.isEmpty) {
            return AurumEmptyState(
              title: 'No alerts yet',
              message: 'Create price alerts for key levels.',
              icon: Icons.add_alert_outlined,
              actionLabel: 'Create alert',
              onAction: () => _showCreateAlert(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AurumSpacing.lg),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
            itemBuilder: (_, i) => _AlertCard(alert: list[i], ref: ref),
          );
        },
        loading: () => const LoadingList(count: 4),
        error: (_, __) => AurumErrorState(
          title: 'Alerts unavailable',
          message: 'Please try again.',
          onRetry: () => ref.invalidate(alertsProvider),
        ),
      ),
    );
  }

  Future<void> _showCreateAlert(BuildContext context, WidgetRef ref) async {
    final assetCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    AlertCondition condition = AlertCondition.above;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: AurumSpacing.lg,
            right: AurumSpacing.lg,
            top: AurumSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AurumSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create price alert', style: AurumTypography.h3),
              const SizedBox(height: AurumSpacing.md),
              TextField(
                controller: assetCtrl,
                decoration: const InputDecoration(hintText: 'Asset ID (e.g. bitcoin)'),
              ),
              const SizedBox(height: AurumSpacing.sm),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Target price (USD)'),
              ),
              const SizedBox(height: AurumSpacing.sm),
              SegmentedButton<AlertCondition>(
                segments: const [
                  ButtonSegment(value: AlertCondition.above, label: Text('Above')),
                  ButtonSegment(value: AlertCondition.below, label: Text('Below')),
                ],
                selected: {condition},
                onSelectionChanged: (s) => setState(() => condition = s.first),
              ),
              const SizedBox(height: AurumSpacing.lg),
              AurumButton(
                label: 'Create alert',
                onPressed: () async {
                  final asset = assetCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim());
                  if (asset.isNotEmpty && price != null && price > 0) {
                    await ref.read(alertRepositoryProvider).createAlert(
                      assetId: asset.toLowerCase(),
                      condition: condition,
                      targetPrice: price,
                    );
                    ref.invalidate(alertsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.ref, super.key});
  final PriceAlert alert;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      child: Row(
        children: [
          Icon(
            alert.condition == AlertCondition.above ? Icons.arrow_upward : Icons.arrow_downward,
            color: AurumColors.gold,
          ),
          const SizedBox(width: AurumSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.assetId.toUpperCase(), style: AurumTypography.h3),
                Text(
                  '${alert.condition.name} ${AurumFormatters.price(alert.targetPrice)}',
                  style: AurumTypography.body,
                ),
              ],
            ),
          ),
          Text(alert.status.name, style: AurumTypography.caption),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AurumColors.negative),
            onPressed: () async {
              await ref.read(alertRepositoryProvider).deleteAlert(alert.id);
              ref.invalidate(alertsProvider);
            },
          ),
        ],
      ),
    );
  }
}
