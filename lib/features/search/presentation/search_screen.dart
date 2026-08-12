import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/financial_components.dart';
import '../../../shared/widgets/state_components.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(marketsProvider(_query));

    return Scaffold(
      appBar: AurumAppBar(
        title: 'Search',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AurumSpacing.lg),
            child: AurumSearchField(
              controller: _controller,
              hintText: 'Search assets, signals, or AI insights',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: results.when(
              data: (assets) {
                if (assets.isEmpty) {
                  return const AurumEmptyState(
                    title: 'No results',
                    message: 'Try searching for BTC, ETH, or a signal term.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AurumSpacing.lg),
                  itemCount: assets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AurumSpacing.sm),
                  itemBuilder: (_, i) {
                    final a = assets[i];
                    return CryptoCard(
                      asset: a,
                      onTap: () => context.push('/asset/${a.id}'),
                    );
                  },
                );
              },
              loading: () => const LoadingList(count: 6),
              error: (_, __) => const AurumErrorState(title: 'Search failed', message: 'Try again'),
            ),
          ),
        ],
      ),
    );
  }
}
