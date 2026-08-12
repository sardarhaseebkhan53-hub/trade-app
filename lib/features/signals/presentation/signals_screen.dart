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

class SignalsScreen extends ConsumerWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AurumAppBar(title: 'Signals'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AurumSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explainable multi-factor signals', style: AurumTypography.body),
              const SizedBox(height: AurumSpacing.lg),
              Expanded(
                child: ListView(
                  children: const [
                    SignalCard(signal: null),
                    SizedBox(height: AurumSpacing.sm),
                    SignalCard(signal: null),
                    SizedBox(height: AurumSpacing.sm),
                    SignalCard(signal: null),
                  ],
                ),
              ),
              const SizedBox(height: AurumSpacing.sm),
              Text(
                'Signals are generated from technical rules. Not financial advice.',
                style: AurumTypography.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
