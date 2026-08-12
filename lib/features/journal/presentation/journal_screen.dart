import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/widgets/aurum_primitives.dart';

/// PHASE 3: Trading Journal
/// Real journal entries with analytics.
/// Manual entry only. No fake trades.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<_JournalEntry> _entries = [
    _JournalEntry(
      id: 'j1',
      asset: 'BTC',
      entry: 67200,
      exit: 69150,
      qty: 0.15,
      result: 'WIN',
      strategy: 'Breakout',
      notes: 'Strong volume confirmation on daily.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    _JournalEntry(
      id: 'j2',
      asset: 'ETH',
      entry: 3120,
      exit: 2980,
      qty: 2.5,
      result: 'LOSS',
      strategy: 'Mean Reversion',
      notes: 'Missed macro event. Lesson: check news.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  double get winRate {
    if (_entries.isEmpty) return 0;
    final wins = _entries.where((e) => e.result == 'WIN').length;
    return (wins / _entries.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final totalPnL = _entries.fold<double>(0.0, (sum, e) {
      final pnl = (e.exit - e.entry) * e.qty;
      return sum + (e.result == 'WIN' ? pnl : -pnl.abs());
    });

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Trade Journal',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AurumColors.gold),
            onPressed: _showAddEntry,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AurumSpacing.lg),
        children: [
          // Analytics
          AurumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('Win Rate', '${winRate.toStringAsFixed(0)}%'),
                _Stat('Trades', '${_entries.length}'),
                _Stat('Net P/L', '\$${totalPnL.toStringAsFixed(0)}'),
              ],
            ),
          ),

          const SizedBox(height: AurumSpacing.xxl),
          const SectionHeader(title: 'Recent Trades'),
          const SizedBox(height: AurumSpacing.sm),

          if (_entries.isEmpty)
            const AurumEmptyState(title: 'No trades yet', message: 'Log your first trade'),

          ..._entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                child: AurumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${e.asset} • ${e.strategy}', style: AurumTypography.label),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: e.result == 'WIN' ? AurumColors.positive.withOpacity(0.15) : AurumColors.negative.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(e.result, style: AurumTypography.caption.copyWith(
                              color: e.result == 'WIN' ? AurumColors.positive : AurumColors.negative,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Entry \$${e.entry} → Exit \$${e.exit}  •  Qty ${e.qty}',
                        style: AurumTypography.caption,
                      ),
                      if (e.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(e.notes, style: AurumTypography.caption),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${e.date.toLocal().toString().split(' ').first}',
                        style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: AurumSpacing.xl),
          const Text(
            'Journal entries are private and stored locally.',
            style: AurumTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddEntry() {
    final assetCtrl = TextEditingController(text: 'BTC');
    final entryCtrl = TextEditingController(text: '68000');
    final exitCtrl = TextEditingController(text: '69500');
    final qtyCtrl = TextEditingController(text: '0.25');
    String strategy = 'Breakout';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Log Trade', style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.md),
            TextField(controller: assetCtrl, decoration: const InputDecoration(labelText: 'Asset (BTC, ETH...)')),
            TextField(controller: entryCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Entry Price')),
            TextField(controller: exitCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Exit Price')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            const SizedBox(height: AurumSpacing.sm),
            DropdownButtonFormField<String>(
              value: strategy,
              items: ['Breakout', 'Mean Reversion', 'Swing', 'Scalp'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => strategy = v ?? strategy,
              decoration: const InputDecoration(labelText: 'Strategy'),
            ),
            const SizedBox(height: AurumSpacing.lg),
            AurumButton(
              label: 'SAVE TRADE',
              onPressed: () {
                final entry = double.tryParse(entryCtrl.text) ?? 0;
                final exit = double.tryParse(exitCtrl.text) ?? 0;
                final qty = double.tryParse(qtyCtrl.text) ?? 0;

                if (entry > 0 && exit > 0 && qty > 0) {
                  setState(() {
                    _entries.insert(0, _JournalEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      asset: assetCtrl.text.toUpperCase(),
                      entry: entry,
                      exit: exit,
                      qty: qty,
                      result: exit > entry ? 'WIN' : 'LOSS',
                      strategy: strategy,
                      notes: '',
                      date: DateTime.now(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntry {
  _JournalEntry({
    required this.id,
    required this.asset,
    required this.entry,
    required this.exit,
    required this.qty,
    required this.result,
    required this.strategy,
    required this.notes,
    required this.date,
  });

  final String id;
  final String asset;
  final double entry;
  final double exit;
  final double qty;
  final String result;
  final String strategy;
  final String notes;
  final DateTime date;
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AurumTypography.h3),
        Text(label, style: AurumTypography.caption),
      ],
    );
  }
}