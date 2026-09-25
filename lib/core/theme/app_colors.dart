import 'package:flutter/material.dart';

/// Every color in the app is named here, once. Nothing outside this file
/// should ever write a raw Color(0x...) value — if a new color is needed
/// anywhere, it gets a name and a home here first.
class AppColors {
  static const primary = Color(0xFF5B6EE1);
  static const primaryDark = Color(0xFF4354B8);

  static const background = Color(0xFFF8F8FC);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF1F2330);
  static const textSecondary = Color(0xFF6B7280);

  static const border = Color(0xFFE6E8F0);

  static const success = Color(0xFF2E9B6F);
  static const error = Color(0xFFD9535B);
}