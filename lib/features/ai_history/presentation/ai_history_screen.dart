import 'package:flutter/material.dart';

import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

class AiHistoryScreen extends StatelessWidget {
  const AiHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In real app this would be a Riverpod provider fetching from backend
    const fakeHistory = <({String asset, String query, String date})>[
      (asset: 'BTC', query: 'Why is BTC bullish?', date: '2h ago'),
      (asset: 'ETH', query: 'What are the risks for ETH?', date: 'Yesterday'),
    ];

    return Scaffold(
      appBar: const AurumAppBar(title: 'AI History'),
      body: ListView.separated(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        itemCount: fakeHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
        itemBuilder: (_, i) {
          final item = fakeHistory[i];
          return AurumCard(
            onTap: () {
              // Navigate to specific AI analysis
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.asset} • ${item.query}', style: AurumTypography.label),
                const SizedBox(height: 4),
                Text(item.date, style: AurumTypography.caption),
              ],
            ),
          );
        },
      ),
    );
  }
}
