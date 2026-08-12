import 'package:flutter/material.dart';

/// Pocket-broker tokens. Gold is brand only. Green/red do the market work.
abstract final class AurumColors {
  static const ink = Color(0xFF050608);
  static const canvas = Color(0xFF0A0C10);
  static const surface = Color(0xFF11141A);
  static const surfaceElevated = Color(0xFF171B22);
  static const surfacePressed = Color(0xFF1E232C);
  static const card = Color(0xFF11141A);
  static const border = Color(0xFF262B34);
  static const borderStrong = Color(0xFF3A4150);
  static const gold = Color(0xFFC4A35A);
  static const goldSoft = Color(0xFFE4D2A0);
  static const inkOnMetal = Color(0xFF1A1408);
  static const textPrimary = Color(0xFFF3F4F6);
  static const textSecondary = Color(0xFF8B93A1);
  static const textTertiary = Color(0xFF5C6470);
  static const positive = Color(0xFF2DB87A);
  static const negative = Color(0xFFE45A5A);
  static const wait = Color(0xFF9AA3B2);
  static const warning = Color(0xFFD9A441);
  static const info = Color(0xFF7AA9FF);
  static const focus = Color(0xFF8DB4FF);
  static const live = Color(0xFF3DDC97);

  static Color movement(bool isPositive) => isPositive ? positive : negative;
}
