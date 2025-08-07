// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// A class to hold all the color constants for the application.
/// This promotes consistency and makes theme changes easy.
class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  // ----- PRIMARY & ACCENT COLORS ----- //
  /// The main brand color for the app. Used for major UI elements like app bars and standard buttons.
  /// A calming and professional teal.
  static const Color primary = Color(0xFF26A69A); // Teal 400

  /// An accent color for critical call-to-action buttons like "Analyze" or "Save".
  /// A warm, hopeful, and engaging deep orange.
  static const Color accent = Color(0xFFFF7043); // Deep Orange 400

  // ----- NEUTRAL & BACKGROUND COLORS ----- //
  /// The main background color for most screens. A very light, clean off-white.
  static const Color background = Color(0xFFF8F9FA);

  /// A slightly darker neutral color for UI elements like card backgrounds or dividers.
  static const Color surface = Colors.white;

  // ----- TEXT COLORS ----- //
  /// The color for primary text like headlines and titles. A strong, dark grey for readability.
  static const Color textPrimary = Color(0xFF333333);

  /// The color for secondary text like subtitles, descriptions, and captions. A softer grey.
  static const Color textSecondary = Color(0xFF757575);

  // ----- SEMANTIC COLORS ----- //
  /// The color for indicating an error or a destructive action (e.g., "Delete").
  static const Color error = Color(0xFFE53935); // Red 600

  /// The color for indicating success or confirmation.
  static const Color success = Color(0xFF43A047); // Green 600

  // ----- OTHER COMMON COLORS ----- //
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color border = Color(0xFFE0E0E0);
}
