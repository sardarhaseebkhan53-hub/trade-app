import 'package:flutter/material.dart';

enum MarketDirection { bullish, neutral, bearish }

enum SignalStatus { active, watching, updated, invalidated, completed, archived }

enum SignalStrength { developing, confirmed, strong }

enum RiskLevel { low, moderate, elevated }

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

class MarketSentiment {
  const MarketSentiment({
    required this.score,
    required this.label,
    required this.change,
    required this.asOf,
  });

  final int score;
  final String label;
  final double change;
  final DateTime asOf;
}

class MarketInsight {
  const MarketInsight({
    required this.title,
    required this.summary,
    required this.direction,
    required this.observation,
    required this.asOf,
  });

  final String title;
  final String summary;
  final MarketDirection direction;
  final String observation;
  final DateTime asOf;
}

class AnalysisSignal {
  const AnalysisSignal({
    required this.id,
    required this.assetId,
    required this.pair,
    required this.direction,
    required this.strength,
    required this.riskLevel,
    required this.status,
    required this.issuedAt,
    required this.priceSnapshot,
    required this.entryZone,
    required this.invalidation,
    required this.thesis,
    required this.indicators,
  });

  final String id;
  final String assetId;
  final String pair;
  final MarketDirection direction;
  final SignalStrength strength;
  final RiskLevel riskLevel;
  final SignalStatus status;
  final DateTime issuedAt;
  final double priceSnapshot;
  final String entryZone;
  final String invalidation;
  final String thesis;
  final List<String> indicators;
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

class AiAnalysis {
  const AiAnalysis({
    required this.assetId,
    required this.headline,
    required this.direction,
    required this.confidence,
    required this.summary,
    required this.technicalView,
    required this.momentum,
    required this.volatility,
    required this.observations,
    required this.scenarios,
    required this.risks,
    required this.asOf,
  });

  final String assetId;
  final String headline;
  final MarketDirection direction;
  final int confidence;
  final String summary;
  final String technicalView;
  final String momentum;
  final String volatility;
  final List<String> observations;
  final List<AnalysisScenario> scenarios;
  final List<String> risks;
  final DateTime asOf;
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
