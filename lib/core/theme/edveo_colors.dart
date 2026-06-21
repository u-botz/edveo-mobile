import 'package:flutter/material.dart';

abstract final class EdveoColors {
  static const Color brandPrimary = Color(0xFF2563EB);
  static const Color brandPrimarySoft = Color(0x1F2563EB); // 12% opacity
  static const Color brandPrimaryHover = Color(0xFF1D4ED8);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFF9CA3AF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textFaint = Color(0xFF9CA3AF);

  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentGreenSoft = Color(0x1416A34A);
  static const Color accentGreenRing = Color(0x6616A34A);
  static const Color surfaceSubtle = Color(0xFFF9FAFB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textLink = Color(0xFF16A34A);

  static const List<Color> tenantTints = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
  ];

  static Color tintForSlug(String slug) {
    int hash = slug.codeUnits.fold(0, (a, b) => a + b);
    return tenantTints[hash % 6];
  }
}
