import 'package:flutter/material.dart';

import '../../app/theme/aurum_colors.dart';
import '../../app/theme/aurum_radius.dart';
import '../../app/theme/aurum_spacing.dart';
import '../../app/theme/aurum_typography.dart';
import '../../core/utils/formatters.dart';
import '../../domain/market_entities.dart';
import 'aurum_primitives.dart';
import 'charts.dart';

class CryptoCard extends StatelessWidget {
  const CryptoCard({
    required this.asset,
    super.key,
    this.showMarketStats = false,
    this.isWatched = false,
    this.onWatchToggle,
    this.onTap,
  });

  final Asset asset;
  final bool showMarketStats;
  final bool isWatched;
  final VoidCallback? onWatchToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final positive = asset.isPositive;
    final color = AurumColors.movement(positive);

    return AurumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AurumSpacing.md),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AurumColors.surfaceElevated,
              borderRadius: AurumRadius.control,
            ),
            alignment: Alignment.center,
            child: Text(
              asset.symbol,
              style: AurumTypography.label.copyWith(color: AurumColors.goldSoft),
            ),
          ),
          const SizedBox(width: AurumSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(asset.symbol, style: AurumTypography.h3),
                    const SizedBox(width: AurumSpacing.xs),
                    Text(
                      asset.name,
                      style: AurumTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (showMarketStats) ...[
                  const SizedBox(height: 2),
                  Text(
                    'MCap ${AurumFormatters.compactCurrency(asset.marketCap)}',
                    style: AurumTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AurumFormatters.price(asset.price), style: AurumTypography.priceRow),
              const SizedBox(height: 2),
              Text(
                '${positive ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%',
                style: AurumTypography.percentage.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(width: AurumSpacing.sm),
          if (asset.sparkline.isNotEmpty)
            MiniChart(points: asset.sparkline, isPositive: positive),
          const SizedBox(width: AurumSpacing.sm),
          IconButton(
            icon: Icon(
              isWatched ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isWatched ? AurumColors.gold : AurumColors.textTertiary,
            ),
            onPressed: onWatchToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = AurumColors.movement(positive);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AurumRadius.pill,
      ),
      child: Text(
        '${positive ? '+' : ''}${value.toStringAsFixed(2)}%',
        style: AurumTypography.label.copyWith(color: color),
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

  final Asset asset;
  final bool isWatched;
  final VoidCallback onWatchToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(asset.name, style: AurumTypography.h2),
              Text(asset.symbol, style: AurumTypography.body.copyWith(color: AurumColors.goldSoft)),
            ],
          ),
        ),
        IconButton(
          onPressed: onWatchToggle,
          icon: Icon(
            isWatched ? Icons.star_rounded : Icons.star_border_rounded,
            color: isWatched ? AurumColors.gold : AurumColors.textPrimary,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class SignalCard extends StatelessWidget {
  const SignalCard({required this.signal, this.onTap, super.key});

  final dynamic signal; // Using dynamic for flexibility with current model
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Simplified for now — will be typed in later phases
    return AurumCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('BTC / USD', style: AurumTypography.h3),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AurumColors.positive.withOpacity(0.15),
                  borderRadius: AurumRadius.pill,
                ),
                child: Text('BULLISH', style: AurumTypography.label.copyWith(color: AurumColors.positive)),
              ),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Text(
            'Strong trend + volume confirmation. Momentum positive on 1D.',
            style: AurumTypography.body,
          ),
          const SizedBox(height: AurumSpacing.xs),
          Text(
            'Strength: 72/100  •  1D timeframe',
            style: AurumTypography.caption,
          ),
        ],
      ),
    );
  }
}

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({required this.analysis, this.onTap, super.key});

  final dynamic analysis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AurumCard(
      onTap: onTap,
      borderColor: AurumColors.gold.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, color: AurumColors.gold, size: 18),
              const SizedBox(width: AurumSpacing.xs),
              Text('AURUM Intelligence', style: AurumTypography.label.copyWith(color: AurumColors.goldSoft)),
              const Spacer(),
              Text('78/100', style: AurumTypography.caption.copyWith(color: AurumColors.gold)),
            ],
          ),
          const SizedBox(height: AurumSpacing.sm),
          Text(
            'Market shows constructive bias with supportive volume and trend structure on major assets.',
            style: AurumTypography.body,
          ),
          const SizedBox(height: AurumSpacing.xs),
          Text('Updated moments ago', style: AurumTypography.caption),
        ],
      ),
    );
  }
}
