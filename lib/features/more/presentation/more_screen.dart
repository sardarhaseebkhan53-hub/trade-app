import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String subtitle, String route})>[
      (icon: Icons.psychology_outlined, title: 'AI Analyst', subtitle: 'Explain the current ticket', route: '/ai-analysis'),
      (icon: Icons.filter_alt_outlined, title: 'Scanner', subtitle: 'Filter BUY / WAIT / SELL', route: '/scanner'),
      (icon: Icons.notifications_active_outlined, title: 'Alerts', subtitle: 'Breakouts, volume, signal changes', route: '/alerts'),
      (icon: Icons.insights_outlined, title: 'Signals', subtitle: 'Ticket history', route: '/signals'),
      (icon: Icons.menu_book_outlined, title: 'Journal', subtitle: 'Your notes, not fills', route: '/journal'),
      (icon: Icons.person_outline_rounded, title: 'Profile', subtitle: 'Account and preferences', route: '/profile'),
      (icon: Icons.lock_outline_rounded, title: 'Security', subtitle: 'Biometric, sessions, 2FA', route: '/security'),
      (icon: Icons.privacy_tip_outlined, title: 'Privacy', subtitle: 'Data and deletion', route: '/privacy'),
    ];

    return Scaffold(
      appBar: const AurumAppBar(title: 'More'),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AurumSpacing.md, AurumSpacing.sm, AurumSpacing.md, AurumSpacing.xxl),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Padding(
              padding: const EdgeInsets.only(top: AurumSpacing.md),
              child: Text(
                'AURUM is analysis only. BUY and SELL are analytical states, not orders.',
                style: AurumTypography.caption,
                textAlign: TextAlign.center,
              ),
            );
          }
          final item = items[index];
          return AurumCard(
            onTap: () => context.push(item.route),
            padding: const EdgeInsets.all(AurumSpacing.md),
            child: Row(
              children: [
                Icon(item.icon, color: AurumColors.goldSoft),
                const SizedBox(width: AurumSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AurumTypography.label.copyWith(color: AurumColors.textPrimary)),
                      Text(item.subtitle, style: AurumTypography.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AurumColors.textTertiary),
              ],
            ),
          );
        },
      ),
    );
  }
}
