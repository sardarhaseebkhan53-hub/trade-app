import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import '../../core/utils/formatters.dart';
import '../../domain/broker_signal.dart';
import '../models/market_models.dart';

class LivePulse extends StatelessWidget {
  const LivePulse({super.key, this.label, this.stale = false});

  final String? label;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final color = stale ? AurumColors.warning : AurumColors.live;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          stale ? 'STALE' : 'LIVE',
          style: AurumTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(label!, style: AurumTypography.caption),
        ],
      ],
    );
  }
}

class SignalPill extends StatelessWidget {
  const SignalPill({required this.side, super.key, this.compact = false});

  final BrokerSide side;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (side) {
      BrokerSide.strongBuy || BrokerSide.buy => AurumColors.positive,
      BrokerSide.strongSell || BrokerSide.sell => AurumColors.negative,
      BrokerSide.wait => AurumColors.wait,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AurumRadius.pill,
      ),
      child: Text(
        compact ? side.ticketLabel : side.shortLabel,
        style: AurumTypography.label.copyWith(color: color, fontSize: compact ? 10 : 11),
      ),
    );
  }
}

class QuoteRow extends StatelessWidget {
  const QuoteRow({
    required this.asset,
    required this.side,
    super.key,
    this.onTap,
    this.score,
  });

  final MarketAsset asset;
  final BrokerSide side;
  final VoidCallback? onTap;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final up = asset.isPositive;
    final color = AurumColors.movement(up);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(asset.symbol, style: AurumTypography.label.copyWith(color: AurumColors.textPrimary)),
              ),
              Expanded(
                child: Text(
                  AurumFormatters.last(asset.price),
                  textAlign: TextAlign.right,
                  style: AurumTypography.priceRow,
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '${up ? '+' : ''}${asset.change24h.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: AurumTypography.percentage.copyWith(color: color),
                ),
              ),
              const SizedBox(width: 10),
              SignalPill(side: side, compact: true),
              if (score != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 22,
                  child: Text('$score', textAlign: TextAlign.right, style: AurumTypography.caption),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BrokerTicketBar extends StatelessWidget {
  const BrokerTicketBar({
    required this.side,
    required this.score,
    required this.onSelect,
    super.key,
  });

  final BrokerSide side;
  final int score;
  final ValueChanged<BrokerSide> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _TicketButton(
              label: 'BUY',
              selected: side.isBuy,
              color: AurumColors.positive,
              badge: side.isBuy ? '$score' : null,
              onTap: () => onSelect(BrokerSide.buy),
            ),
            const SizedBox(width: 8),
            _TicketButton(
              label: 'WAIT',
              selected: side == BrokerSide.wait,
              color: AurumColors.wait,
              onTap: () => onSelect(BrokerSide.wait),
            ),
            const SizedBox(width: 8),
            _TicketButton(
              label: 'SELL',
              selected: side.isSell,
              color: AurumColors.negative,
              badge: side.isSell ? '$score' : null,
              onTap: () => onSelect(BrokerSide.sell),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Analytical state · not an order',
          style: AurumTypography.caption.copyWith(color: AurumColors.textTertiary),
        ),
      ],
    );
  }
}

class _TicketButton extends StatelessWidget {
  const _TicketButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label analytical state',
        child: Material(
          color: selected ? color : AurumColors.surfaceElevated,
          borderRadius: AurumRadius.control,
          child: InkWell(
            onTap: onTap,
            borderRadius: AurumRadius.control,
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    label,
                    style: AurumTypography.label.copyWith(
                      color: selected ? AurumColors.ink : color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: Text(badge!, style: AurumTypography.caption.copyWith(color: selected ? AurumColors.ink : color)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
