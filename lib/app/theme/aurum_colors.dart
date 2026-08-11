import 'package:flutter/material.dart';

/// Semantic color tokens for the AURUM Obsidian system.
abstract final class AurumColors {
  static const ink = Color(0xFF090B0F);
  static const canvas = Color(0xFF0F1218);
  static const surface = Color(0xFF151922);
  static const surfaceElevated = Color(0xFF1B202A);
  static const surfacePressed = Color(0xFF252B36);
  static const card = Color(0xFF171B24);
  static const border = Color(0xFF2A303B);
  static const borderStrong = Color(0xFF3B4350);
  static const gold = Color(0xFFD8B45A);
  static const goldSoft = Color(0xFFF2D27A);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFFB2BAC7);
  static const textTertiary = Color(0xFF7D8797);
  static const positive = Color(0xFF35C98A);
  static const negative = Color(0xFFF07178);
  static const warning = Color(0xFFF1B75B);
  static const info = Color(0xFF7AA9FF);
  static const focus = Color(0xFF8DB4FF);

  static Color movement(bool isPositive) => isPositive ? positive : negative;
}
