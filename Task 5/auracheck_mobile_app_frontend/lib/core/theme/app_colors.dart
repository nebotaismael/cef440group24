import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Updated to Blue Palette from Figma
  static const Color primary = Color(0xFF0A78E1); // Was: 0xFF2E7D32 (Green) - Now Blue from Figma (Primary/700 or "Blue")
  static const Color primaryLight = Color(0xFF4196F9); // Was: 0xFF4CAF50 - Now L_Blue from Figma (Primary/600)
  static const Color primaryDark = Color(0xFF005CB1); // Was: 0xFF1B5E20 - Now D_Blue from Figma (Primary/900)

  // Secondary Colors - Updated to Green Palette from Figma (previously Primary, now acting as Secondary)
  static const Color secondary = Color(0xFF009352); // Was: 0xFF1976D2 (Blue) - Now M_Green from Figma Success
  static const Color secondaryLight = Color(0xFF3DC997); // Was: 0xFF2196F3 - Now Herbal from Figma Success
  static const Color secondaryDark = Color(0xFF156943); // Was: 0xFF0D47A1 - Now Forest from Figma Success

  // Semantic Colors - Updated based on Figma
  static const Color success = Color(0xFF009352); // Was: 0xFF4CAF50 - Now M_Green from Figma
  static const Color warning = Color(0xFFFFC140); // Was: 0xFFFF9800 - Now Yellow from Figma
  static const Color error = Color(0xFFEA4335); // Was: 0xFFF44336 - Now "Denger" Red from Figma
  static const Color info = Color(0xFF4196F9); // Was: 0xFF2196F3 - Now L_Blue from Figma (same as primaryLight)

  // Neutral Colors - Updated based on Figma "Gray/XXX" scale and "Neutral" palette
  static const Color white = Color(0xFFFFFFFF); // Unchanged, matches Figma "White"
  static const Color black = Color(0xFF212121); // Unchanged, matches Figma "Black" / "Gray/900"

  static const Color grey50 = Color(0xFFFAFAFA); // Unchanged, matches Figma "Gray/50"
  static const Color grey100 = Color(0xFFF5F5F5); // Unchanged, matches Figma "Gray/100"
  static const Color grey200 = Color(0xFFEEEEEE); // Unchanged, matches Figma "Gray/200"
  static const Color grey300 = Color(0xFFE0E0E0); // Unchanged, matches Figma "Gray/300" / "Silver"
  static const Color grey400 = Color(0xFFBDBDBD); // Unchanged, matches Figma "Gray/400" (Figma "L_Grey" is #B9B9B9, using established scale)
  static const Color grey500 = Color(0xFF9E9E9E); // Unchanged, matches Figma "Gray/500"
  static const Color grey600 = Color(0xFF757575); // Unchanged, matches Figma "Gray/600"
  static const Color grey700 = Color(0xFF616161); // Unchanged, matches Figma "Gray/700" (Figma "Grey" is #717171, using established scale)
  static const Color grey800 = Color(0xFF424242); // Unchanged, matches Figma "Gray/800" (Figma "D_Grey" is #4D4D4D, using established scale)
  static const Color grey900 = Color(0xFF212121); // Unchanged, matches Figma "Gray/900" / "Black"

  // Background Colors - Aligned with Neutral scale
  static const Color background = Color(0xFFFAFAFA); // Unchanged, matches grey50
  static const Color surface = Color(0xFFFFFFFF); // Unchanged, matches white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Unchanged, matches grey100

  // Text Colors - Aligned with Neutral scale
  static const Color textPrimary = Color(0xFF212121); // Unchanged, matches grey900/black
  static const Color textSecondary = Color(0xFF757575); // Unchanged, matches grey600
  static const Color textHint = Color(0xFF9E9E9E); // Unchanged, matches grey500
}
