import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// This file has exactly one job: build the single ThemeData object that
/// MaterialApp puts at the top of the whole widget tree. It doesn't define
/// any colors or text styles itself — it only assembles the pieces from
/// AppColors and AppTypography into the shape Flutter's theme mechanism
/// actually expects.
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: AppColors.background,

      cardTheme: CardThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      textTheme: AppTypography.textTheme,
    );
  }
}