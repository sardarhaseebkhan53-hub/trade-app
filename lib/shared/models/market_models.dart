import 'package:flutter/material.dart';

enum MarketDirection { bullish, neutral, bearish }

enum NotificationKind { signal, price, market, system }

class MarketAsset {
  const MarketAsset({
    required this.id,
    required this.rank,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.volume,
    required this.marketCap,
    required this.iconColor,
    required this.sparkline,
    this.description,
  });

  final String id;
  final int rank;
  final String name;
  final String symbol;
  final double price;
  final double change24h;
  final double volume;
  final double marketCap;
  final Color iconColor;
  final List<double> sparkline;
  final String? description;

  bool get isPositive => change24h >= 0;
}

class AssetStatistics {
  const AssetStatistics({
    required this.marketCap,
    required this.volume24h,
    required this.dayHigh,
    required this.dayLow,
    required this.circulatingSupply,
    required this.allTimeHigh,
  });

  final double? marketCap;
  final double? volume24h;
  final double? dayHigh;
  final double? dayLow;
  final String circulatingSupply;
  final double? allTimeHigh;
}

class TechnicalIndicator {
  const TechnicalIndicator({
    required this.label,
    required this.value,
    required this.interpretation,
    required this.direction,
  });

  final String label;
  final String value;
  final String interpretation;
  final MarketDirection direction;
}

class AnalysisScenario {
  const AnalysisScenario({
    required this.label,
    required this.condition,
    required this.context,
    required this.direction,
  });

  final String label;
  final String condition;
  final String context;
  final MarketDirection direction;
}

class AurumNotification {
  const AurumNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;
}

class AurumProfile {
  const AurumProfile({
    required this.name,
    required this.email,
    required this.isGuest,
    required this.currency,
    required this.reducedMotion,
  });

  final String name;
  final String email;
  final bool isGuest;
  final String currency;
  final bool reducedMotion;
}
