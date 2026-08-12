import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/state_components.dart';

/// PHASE 3: Basic Market Scanner (real data)
/// Filters using live mock data. Expandable.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String _filter = 'All';
  double _minChange = -100;
  double _maxChange = 100;

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(featuredAssetsProvider);

    return Scaffold(
      appBar: const AurumAppBar(title: 'Scanner'),
      body: assetsAsync.when(
        data: (assets) {
          var filtered = assets;

          if (_filter == 'Gainers') {
            filtered = filtered.where((a) => a.change24h > 0).toList();
          } else if (_filter == 'Losers') {
            filtered = filtered.where((a) => a.change24h < 0).toList();
          } else if (_filter == 'High Vol') {
            filtered = filtered.where((a) => a.volume > 1e9).toList();
          }

          // Simple change filter
          filtered = filtered.where((a) => a.change24h >= _minChange && a.change24h <= _maxChange).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AurumSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: ['All', 'Gainers', 'Losers', 'High Vol'].map((f) {
                          return AurumFilterChip(
                            label: f,
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? const AurumEmptyState(title: 'No matches', message: 'Adjust filters')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.lg),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          return CryptoCard(
                            asset: a,
                            onTap: () => context.push('/asset/${a.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const AurumErrorState(title: 'Scanner unavailable'),
      ),
    );
  }
}