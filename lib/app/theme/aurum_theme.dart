import 'package:flutter/material.dart';

import 'aurum_colors.dart';
import 'aurum_radius.dart';
import 'aurum_typography.dart';

abstract final class AurumTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AurumColors.gold,
      onPrimary: AurumColors.ink,
      secondary: AurumColors.goldSoft,
      onSecondary: AurumColors.ink,
      surface: AurumColors.surface,
      onSurface: AurumColors.textPrimary,
      error: AurumColors.negative,
      onError: AurumColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AurumColors.canvas,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displayLarge: AurumTypography.display,
        headlineLarge: AurumTypography.h1,
        headlineMedium: AurumTypography.h2,
        headlineSmall: AurumTypography.h3,
        bodyLarge: AurumTypography.bodyLarge,
        bodyMedium: AurumTypography.body,
        labelLarge: AurumTypography.label,
        bodySmall: AurumTypography.caption,
      ),
      dividerTheme: const DividerThemeData(
        color: AurumColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AurumColors.surface,
        hintStyle: AurumTypography.body.copyWith(color: AurumColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: AurumRadius.control,
          borderSide: BorderSide(color: AurumColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AurumRadius.control,
          borderSide: BorderSide(color: AurumColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AurumRadius.control,
          borderSide: BorderSide(color: AurumColors.gold, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AurumRadius.control,
          borderSide: BorderSide(color: AurumColors.negative),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AurumColors.surface,
        modalBackgroundColor: AurumColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AurumColors.surfaceElevated,
        contentTextStyle: AurumTypography.body,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
