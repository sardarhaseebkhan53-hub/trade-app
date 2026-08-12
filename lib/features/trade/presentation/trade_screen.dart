import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/aurum_colors.dart';
import '../../../app/theme/aurum_spacing.dart';
import '../../../app/theme/aurum_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/broker_signal.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/widgets/aurum_primitives.dart';
import '../../../shared/widgets/broker_components.dart';
import '../../../shared/widgets/candle_chart.dart';
import '../../../shared/widgets/state_components.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({this.assetId = 'bitcoin', super.key});

  final String assetId;

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  String _timeframe = '1H';

  static const _frames = ['1m', '5m', '15m', '30m', '1H', '4H', '1D', '1W'];

  @override
  Widget build(BuildContext context) {
    final request = ChartRequest(widget.assetId, _timeframe);
    final assetAsync = ref.watch(assetProvider(widget.assetId));
    final ohlcAsync = ref.watch(ohlcProvider(request));
    final ticketAsync = ref.watch(marketTicketProvider(request));
    final watched = ref.watch(watchlistProvider).valueOrNull ?? <String>{};

    return Scaffold(
      backgroundColor: AurumColors.ink,
      body: SafeArea(
        child: assetAsync.when(
          data: (asset) {
            final ticket = ticketAsync.valueOrNull;
            final side = ticket == null
                ? brokerSideFromChange(asset.change24h)
                : ticket.isSufficient
                    ? brokerSideForScore(ticket.analyticalStrength)
                    : BrokerSide.wait;
            final score = ticket?.analyticalStrength ?? 0;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      if (context.canPop())
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${asset.symbol} / USDT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AurumTypography.label.copyWith(color: AurumColors.textPrimary),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AurumFormatters.last(asset.price),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AurumTypography.priceCard,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${asset.isPositive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%',
                                  style: AurumTypography.percentage.copyWith(color: AurumColors.movement(asset.isPositive)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const LivePulse(),
                      IconButton(
                        onPressed: () => ref.read(watchlistProvider.notifier).toggle(asset.id),
                        icon: Icon(
                          watched.contains(asset.id) ? Icons.star_rounded : Icons.star_border_rounded,
                          color: watched.contains(asset.id) ? AurumColors.gold : AurumColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.sm),
                    itemCount: _frames.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final frame = _frames[i];
                      return AurumFilterChip(
                        label: frame,
                        selected: _timeframe == frame,
                        onSelected: (_) => setState(() => _timeframe = frame),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ohlcAsync.when(
                    data: (candles) => CandleChart(
                      candles: candles,
                      timeframe: _timeframe,
                      support: ticket?.structure.support,
                      resistance: ticket?.structure.resistance,
                    ),
                    loading: () => const LoadingSkeleton(height: 280),
                    error: (_, __) => const AurumErrorState(title: 'Chart unavailable', message: 'Try another timeframe.'),
                  ),
                ),
                if (ticket != null && ticket.structure.support != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.md, vertical: 6),
                    child: Text(
                      'S1 ${AurumFormatters.last(ticket.structure.support!)}   R1 ${ticket.structure.resistance == null ? '—' : AurumFormatters.last(ticket.structure.resistance!)}',
                      style: AurumTypography.caption.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AurumSpacing.md, 4, AurumSpacing.md, AurumSpacing.md),
                  child: BrokerTicketBar(
                    side: side,
                    score: score,
                    onSelect: (_) => context.push('/ai-analysis?asset=${asset.id}'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AurumColors.gold)),
          error: (_, __) => AurumErrorState(
            title: 'Ticket unavailable',
            message: 'Could not load this symbol.',
            onRetry: () => ref.invalidate(assetProvider(widget.assetId)),
          ),
        ),
      ),
    );
  }
}
