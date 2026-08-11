import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'aurum_colors.dart';

abstract final class AurumTypography {
  static const display = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'sans',
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static const h1 = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'sans',
    fontSize: 28,
    height: 1.28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const h2 = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'sans',
    fontSize: 22,
    height: 1.28,
    fontWeight: FontWeight.w700,
  );
  static const h3 = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'sans',
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w700,
  );
  static const bodyLarge = TextStyle(
    color: AurumColors.textSecondary,
    fontFamily: 'sans',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    color: AurumColors.textSecondary,
    fontFamily: 'sans',
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w500,
  );
  static const label = TextStyle(
    color: AurumColors.textSecondary,
    fontFamily: 'sans',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    color: AurumColors.textTertiary,
    fontFamily: 'sans',
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
  static const priceHero = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'monospace',
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  static const priceCard = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'monospace',
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  static const priceRow = TextStyle(
    color: AurumColors.textPrimary,
    fontFamily: 'monospace',
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w600,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  static const percentage = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w700,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}
