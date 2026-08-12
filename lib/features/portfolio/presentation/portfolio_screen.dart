import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/models/market_models.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

/// PHASE 3: Portfolio Tracker
/// Manual holdings — NOT a custodial wallet.
/// Real state + analytics.
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final List<_Holding> _holdings = [
    _Holding('bitcoin', 0.42, 45200),
    _Holding('ethereum', 3.8, 2850),
  ];

  double get _totalValue {
    double sum = 0;
    for (final h in _holdings) {
      final asset = _getAsset(h.assetId);
      if (asset != null) sum += h.quantity * asset.price;
    }
    return sum;
  }

  double get _totalCost {
    return _holdings.fold(0.0, (sum, h) => sum + (h.quantity * h.avgCost));
  }

  double get _unrealizedPl => _totalValue - _totalCost;

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(featuredAssetsProvider).valueOrNull ?? const <MarketAsset>[];

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Positions',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AurumColors.gold),
            onPressed: () => _showAddHolding(context, featured),
          ),
        ],
      ),
      body: featured.isEmpty
          ? const Center(child: LoadingSkeleton(height: 200))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AurumSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  AurumCard(
                    padding: const EdgeInsets.all(AurumSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Value', style: AurumTypography.caption),
                        Text(
                          '\$${_totalValue.toStringAsFixed(2)}',
                          style: AurumTypography.priceHero,
                        ),
                        const SizedBox(height: AurumSpacing.sm),
                        Row(
                          children: [
                            Text(
                              '${_unrealizedPl >= 0 ? '+' : ''}${_unrealizedPl.toStringAsFixed(2)} (${((_unrealizedPl / _totalCost) * 100).toStringAsFixed(1)}%)',
                              style: AurumTypography.label.copyWith(
                                color: _unrealizedPl >= 0 ? AurumColors.positive : AurumColors.negative,
                              ),
                            ),
                            const Spacer(),
                            const Text('Unrealized P/L', style: AurumTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AurumSpacing.xxl),

                  const SectionHeader(title: 'Holdings'),
                  const SizedBox(height: AurumSpacing.sm),

                  ..._holdings.map((h) {
                    final asset = _getAsset(h.assetId, featured);
                    if (asset == null) return const SizedBox.shrink();

                    final currentValue = h.quantity * asset.price;
                    final cost = h.quantity * h.avgCost;
                    final pl = currentValue - cost;
                    final plPct = cost > 0 ? (pl / cost) * 100 : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AurumSpacing.sm),
                      child: AurumCard(
                        onTap: () => context.push('/asset/${h.assetId}'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${asset.symbol}  •  ${h.quantity.toStringAsFixed(4)}', style: AurumTypography.label),
                                  Text('Avg: \$${h.avgCost.toStringAsFixed(0)}', style: AurumTypography.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${currentValue.toStringAsFixed(0)}', style: AurumTypography.label),
                                Text(
                                  '${pl >= 0 ? '+' : ''}${pl.toStringAsFixed(0)} (${plPct.toStringAsFixed(1)}%)',
                                  style: AurumTypography.caption.copyWith(
                                    color: pl >= 0 ? AurumColors.positive : AurumColors.negative,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AurumColors.textTertiary),
                              onPressed: () => setState(() => _holdings.remove(h)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: AurumSpacing.xxl),

                  const SectionHeader(title: 'Portfolio Risk'),
                  const SizedBox(height: AurumSpacing.sm),
                  AurumCard(
                    child: const Column(
                      children: [
                        _RiskRow('Concentration', 'Moderate (2 assets)'),
                        _RiskRow('Volatility (est.)', 'High'),
                        _RiskRow('Diversification', 'Low'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AurumSpacing.lg),
                  const Text(
                    'Portfolio tracking is manual. AURUM does not custody funds.',
                    style: AurumTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  MarketAsset? _getAsset(String id, [List<MarketAsset>? list]) {
    final assets = list ??
        (ref.read(featuredAssetsProvider).valueOrNull ?? const <MarketAsset>[]);
    for (final asset in assets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  void _showAddHolding(BuildContext context, List<MarketAsset> assets) {
    var selected = assets.isNotEmpty ? assets.first.id : 'bitcoin';
    final qtyCtrl = TextEditingController(text: '0.1');
    final costCtrl = TextEditingController(text: '50000');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AurumSpacing.lg,
          left: AurumSpacing.lg,
          right: AurumSpacing.lg,
          top: AurumSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Holding', style: AurumTypography.h3),
            const SizedBox(height: AurumSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: selected,
              items: assets
                  .map<DropdownMenuItem<String>>((MarketAsset asset) => DropdownMenuItem<String>(
                value: asset.id,
                child: Text('${asset.symbol} — ${asset.name}'),
              )).toList(),
              onChanged: (v) => selected = v ?? selected,
              decoration: const InputDecoration(labelText: 'Asset'),
            ),
            const SizedBox(height: AurumSpacing.sm),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Average Cost (USD)'),
            ),
            const SizedBox(height: AurumSpacing.lg),
            AurumButton(
              label: 'ADD TO PORTFOLIO',
              onPressed: () {
                final qty = double.tryParse(qtyCtrl.text) ?? 0;
                final cost = double.tryParse(costCtrl.text) ?? 0;
                if (qty > 0 && cost > 0) {
                  setState(() {
                    _holdings.add(_Holding(selected, qty, cost));
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

class _Holding {
  _Holding(this.assetId, this.quantity, this.avgCost);
  final String assetId;
  final double quantity;
  final double avgCost;
}

class _RiskRow extends StatelessWidget {
  const _RiskRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AurumTypography.caption),
          Text(value, style: AurumTypography.label),
        ],
      ),
    );
  }
}