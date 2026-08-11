import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import '../../core/utils/formatters.dart';
import '../models/market_models.dart';
import 'aurum_primitives.dart';
import 'charts.dart';

class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge({required this.value, super.key, this.compact = false});
  final double value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = AurumColors.movement(positive);
    return Semantics(
      label: '${positive ? 'Up' : 'Down'} ${AurumFormatters.change(value)} over 24 hours',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: AurumRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color, size: compact ? 12 : 14),
            const SizedBox(width: 2),
            Text(AurumFormatters.change(value), style: AurumTypography.percentage.copyWith(color: color, fontSize: compact ? 10 : 12)),
          ],
        ),
      ),
    );
  }
}

class AssetMark extends StatelessWidget {
  const AssetMark({required this.asset, super.key, this.size = 38});
  final MarketAsset asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: asset.iconColor, shape: BoxShape.circle),
      child: Text(
        asset.symbol.substring(0, 1),
        style: TextStyle(
          color: asset.id == 'xrp' ? AurumColors.ink : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  const CryptoCard({
    required this.asset,
    required this.isWatched,
    required this.onWatchToggle,
    required this.onTap,
    super.key,
    this.showMarketStats = false,
  });

  final MarketAsset asset;
  final bool isWatched;
  final VoidCallback onWatchToggle;
  final VoidCallback onTap;
  final bool showMarketStats;

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AurumSpacing.sm),
      child: Row(
        children: <Widget>[
          AssetMark(asset: asset),
          const SizedBox(width: AurumSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(asset.name, overflow: TextOverflow.ellipsis, style: AurumTypography.label.copyWith(color: AurumColors.textPrimary)),
                    ),
                    const SizedBox(width: AurumSpacing.xs),
                    Text(asset.symbol, style: AurumTypography.caption),
                  ],
                ),
                const SizedBox(height: AurumSpacing.xxs),
                Text(
                  showMarketStats ? 'Vol. ${AurumFormatters.compactCurrency(asset.volume)}' : '#${asset.rank} market cap',
                  style: AurumTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AurumSpacing.xs),
          MiniChart(points: asset.sparkline, isPositive: asset.isPositive),
          const SizedBox(width: AurumSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(AurumFormatters.price(asset.price), style: AurumTypography.priceRow),
              const SizedBox(height: AurumSpacing.xxs),
              PriceChangeBadge(value: asset.change24h, compact: true),
            ],
          ),
          IconButton(
            tooltip: isWatched ? 'Remove ${asset.name} from watchlist' : 'Add ${asset.name} to watchlist',
            onPressed: onWatchToggle,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isWatched ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 20,
              color: isWatched ? AurumColors.gold : AurumColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({required this.insight, super.key, this.onTap});
  final MarketInsight insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = directionColor(insight.direction);
    return AurumCard(
      onTap: onTap,
      color: AurumColors.surface,
      borderColor: tone.withOpacity(0.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.auto_awesome_outlined, color: AurumColors.gold, size: 18),
              const SizedBox(width: AurumSpacing.xs),
              Text(insight.title.toUpperCase(), style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
              const Spacer(),
              _DirectionLabel(direction: insight.direction),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Text(insight.summary, style: AurumTypography.bodyLarge.copyWith(color: AurumColors.textPrimary)),
          const SizedBox(height: AurumSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(child: Text(insight.observation, style: AurumTypography.caption)),
              const Icon(Icons.chevron_right_rounded, color: AurumColors.goldSoft),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Text('Demo analysis • ${AurumFormatters.compactDate(insight.asOf)} • Not financial advice', style: AurumTypography.caption),
        ],
      ),
    );
  }
}

class SignalCard extends StatelessWidget {
  const SignalCard({required this.signal, super.key, this.onTap});
  final AnalysisSignal signal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final direction = directionColor(signal.direction);
    return AurumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(signal.pair, style: AurumTypography.h3)),
              _DirectionLabel(direction: signal.direction),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Text(signal.thesis, maxLines: 2, overflow: TextOverflow.ellipsis, style: AurumTypography.body),
          const SizedBox(height: AurumSpacing.sm),
          Wrap(
            spacing: AurumSpacing.xs,
            runSpacing: AurumSpacing.xs,
            children: <Widget>[
              _SignalMeta(label: signal.strength.name, color: direction),
              _SignalMeta(label: '${signal.riskLevel.name} risk', color: riskColor(signal.riskLevel)),
              _SignalMeta(label: signal.status.name, color: AurumColors.textSecondary),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(child: Text('Issued ${AurumFormatters.compactDate(signal.issuedAt)}', style: AurumTypography.caption)),
              Text('Demo signal', style: AurumTypography.caption.copyWith(color: AurumColors.goldSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

class IndicatorChip extends StatelessWidget {
  const IndicatorChip({required this.indicator, super.key});
  final TechnicalIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final color = directionColor(indicator.direction);
    return Tooltip(
      message: indicator.interpretation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AurumSpacing.sm, vertical: AurumSpacing.xs),
        decoration: BoxDecoration(
          color: AurumColors.surface,
          borderRadius: AurumRadius.pill,
          border: Border.all(color: AurumColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${indicator.label} ${indicator.value}', style: AurumTypography.label),
          ],
        ),
      ),
    );
  }
}

class AssetHeader extends StatelessWidget {
  const AssetHeader({
    required this.asset,
    required this.isWatched,
    required this.onWatchToggle,
    super.key,
  });

  final MarketAsset asset;
  final bool isWatched;
  final VoidCallback onWatchToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AssetMark(asset: asset, size: 46),
        const SizedBox(width: AurumSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(asset.name, style: AurumTypography.h2),
              Text(asset.symbol, style: AurumTypography.label),
            ],
          ),
        ),
        IconButton(
          tooltip: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
          onPressed: onWatchToggle,
          icon: Icon(isWatched ? Icons.star_rounded : Icons.star_outline_rounded, color: isWatched ? AurumColors.gold : AurumColors.textSecondary),
        ),
      ],
    );
  }
}

class _DirectionLabel extends StatelessWidget {
  const _DirectionLabel({required this.direction});
  final MarketDirection direction;

  @override
  Widget build(BuildContext context) {
    final color = directionColor(direction);
    final label = switch (direction) {
      MarketDirection.bullish => 'Bullish context',
      MarketDirection.neutral => 'Watch',
      MarketDirection.bearish => 'Bearish context',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: AurumRadius.pill),
      child: Text(label, style: AurumTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _SignalMeta extends StatelessWidget {
  const _SignalMeta({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 4),
        Text(label, style: AurumTypography.caption.copyWith(color: color)),
      ],
    );
  }
}

Color directionColor(MarketDirection direction) => switch (direction) {
      MarketDirection.bullish => AurumColors.positive,
      MarketDirection.neutral => AurumColors.warning,
      MarketDirection.bearish => AurumColors.negative,
    };

Color riskColor(RiskLevel level) => switch (level) {
      RiskLevel.low => AurumColors.positive,
      RiskLevel.moderate => AurumColors.warning,
      RiskLevel.elevated => AurumColors.negative,
    };
