import 'package:flutter/material.dart';

/// Premium Color Palette for Secure Ledger App
/// Designed with modern aesthetics and accessibility in mind
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1E3A5F); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF3D5A80); // Light Navy
  static const Color primaryDark = Color(0xFF0D1B2A); // Dark Navy

  // Accent Colors
  static const Color accent = Color(0xFF00B4D8); // Vibrant Cyan
  static const Color accentLight = Color(0xFF90E0EF); // Light Cyan
  static const Color accentDark = Color(0xFF0077B6); // Dark Cyan

  // Functional Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successLight = Color(0xFFD1FAE5); // Light Green
  static const Color error = Color(0xFFEF4444); // Coral Red
  static const Color errorLight = Color(0xFFFEE2E2); // Light Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7); // Light Amber
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFDBEAFE); // Light Blue

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Cool Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light Gray
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF34D399)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFF87171)],
  );

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBackground = Color(0xFF334155);

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
