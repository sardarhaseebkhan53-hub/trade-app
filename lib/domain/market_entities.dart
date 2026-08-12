import 'package:flutter/material.dart';

/// Core domain entities for AURUM (pure business models — no UI)

class Asset {
  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.volume,
    required this.marketCap,
    this.rank = 0,
    this.sparkline = const [],
    this.iconColor,
  });

  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double volume;
  final double marketCap;
  final int rank;
  final List<double> sparkline;
  final Color? iconColor;

  bool get isPositive => change24h >= 0;
}

class MarketOverview {
  const MarketOverview({
    required this.totalMarketCapUsd,
    required this.totalVolumeUsd,
    required this.marketCapChange24h,
    required this.btcDominance,
    required this.activeCryptocurrencies,
    required this.updatedAt,
  });

  final double totalMarketCapUsd;
  final double totalVolumeUsd;
  final double marketCapChange24h;
  final double btcDominance;
  final int activeCryptocurrencies;
  final DateTime updatedAt;
}

class ChartPoint {
  const ChartPoint({required this.timestamp, required this.price});

  final DateTime timestamp;
  final double price;
}

class TechnicalIndicatorValue {
  const TechnicalIndicatorValue({
    required this.name,
    required this.value,
    required this.interpretation,
    required this.strength,
  });

  final String name;
  final String value;
  final String interpretation;
  final int strength;
}
