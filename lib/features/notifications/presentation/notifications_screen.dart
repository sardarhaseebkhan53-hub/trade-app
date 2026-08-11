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
import '../../../shared/widgets/state_components.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AurumAppBar(title: 'Notifications', leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded))),
      body: SafeArea(
        top: false,
        child: notifications.when(
          loading: () => const LoadingList(count: 5),
          error: (_, __) => AurumErrorState(title: 'Notifications unavailable', message: 'Try refreshing your inbox.', onRetry: () => ref.invalidate(notificationsProvider)),
          data: (List<AurumNotification> items) {
            if (items.isEmpty) return const AurumEmptyState(title: 'You’re all caught up', message: 'New signal, price and system updates will appear here.', icon: Icons.notifications_none_rounded);
            return ListView.separated(
              padding: const EdgeInsets.all(AurumSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
              itemBuilder: (BuildContext context, int index) => _NotificationCard(item: items[index], onRead: () async { await ref.read(notificationRepositoryProvider).markRead(items[index].id); ref.invalidate(notificationsProvider); }),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onRead});
  final AurumNotification item;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.kind) {
      NotificationKind.signal => Icons.insights_outlined,
      NotificationKind.price => Icons.show_chart_rounded,
      NotificationKind.market => Icons.public_outlined,
      NotificationKind.system => Icons.info_outline_rounded,
    };
    return Semantics(
      label: item.isRead ? item.title : 'Unread notification: ${item.title}',
      child: Material(
        color: item.isRead ? AurumColors.card : AurumColors.surfaceElevated,
        borderRadius: AurumRadius.card,
        child: InkWell(
          onTap: item.isRead ? null : onRead,
          borderRadius: AurumRadius.card,
          child: Container(
            padding: const EdgeInsets.all(AurumSpacing.md),
            decoration: BoxDecoration(border: Border.all(color: item.isRead ? AurumColors.border : AurumColors.gold.withOpacity(0.38)), borderRadius: AurumRadius.card),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AurumColors.ink, borderRadius: AurumRadius.control), child: Icon(icon, color: AurumColors.gold, size: 19)),
              const SizedBox(width: AurumSpacing.sm),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Row(children: <Widget>[Expanded(child: Text(item.title, style: AurumTypography.label.copyWith(color: AurumColors.textPrimary))), if (!item.isRead) const Icon(Icons.circle, size: 8, color: AurumColors.gold)]), const SizedBox(height: AurumSpacing.xxs), Text(item.body, style: AurumTypography.body), const SizedBox(height: AurumSpacing.xs), Text(AurumFormatters.compactDate(item.createdAt), style: AurumTypography.caption)])),
            ]),
          ),
        ),
      ),
    );
  }
}
