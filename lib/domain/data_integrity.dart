import 'package:flutter/foundation.dart';

enum DataFreshness { live, delayed, stale, offline }

class DataIntegrityResult {
  const DataIntegrityResult({
    required this.isValid,
    required this.freshness,
    this.issues = const [],
    this.lastUpdated,
  });

  final bool isValid;
  final DataFreshness freshness;
  final List<String> issues;
  final DateTime? lastUpdated;

  bool get hasWarnings => issues.isNotEmpty;
}

class DataIntegrityService {
  const DataIntegrityService();

  DataIntegrityResult validateMarketData({
    required DateTime? lastUpdated,
    required double? price,
    required List<double> recentPrices,
    Duration maxAge = const Duration(minutes: 5),
  }) {
    final now = DateTime.now().toUtc();
    final issues = <String>[];

    if (price == null || price <= 0) {
      issues.add('Invalid or missing price');
    }

    if (lastUpdated == null) {
      issues.add('No timestamp available');
      return DataIntegrityResult(
        isValid: false,
        freshness: DataFreshness.offline,
        issues: issues,
      );
    }

    final age = now.difference(lastUpdated);

    DataFreshness freshness;
    if (age > const Duration(minutes: 15)) {
      freshness = DataFreshness.stale;
      issues.add('Data is stale (>15 min old)');
    } else if (age > const Duration(minutes: 2)) {
      freshness = DataFreshness.delayed;
    } else {
      freshness = DataFreshness.live;
    }

    if (recentPrices.length < 5) {
      issues.add('Insufficient recent price history for reliable analysis');
    }

    final isValid = issues.isEmpty || freshness != DataFreshness.stale;

    return DataIntegrityResult(
      isValid: isValid,
      freshness: freshness,
      issues: issues,
      lastUpdated: lastUpdated,
    );
  }
}
