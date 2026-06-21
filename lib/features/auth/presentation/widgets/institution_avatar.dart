import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared institution avatar widget.
/// Renders a network image if [logoUrl] is provided; falls back to coloured
/// initials block. Used by both LoginScreen and RoleRouterScreen.
class InstitutionAvatar extends StatelessWidget {
  final String institutionName;
  final Color accentColor;
  final String? logoUrl;
  final double size;
  final double borderRadius;
  final BoxShadow? shadow;

  const InstitutionAvatar({
    required this.institutionName,
    required this.accentColor,
    this.logoUrl,
    this.size = 56,
    this.borderRadius = 18,
    this.shadow,
    super.key,
  });

  /// Derive initials from institution name per spec:
  /// - "Sayanth P"          -> "SP"
  /// - "Newton IIT Academy" -> "NI"
  /// - "Brilliant"          -> "BR"
  /// - ""                   -> "?"
  static String initialsFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    // Single word — take first two characters
    final word = words[0];
    if (word.length >= 2) return word.substring(0, 2).toUpperCase();
    return word[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = initialsFor(institutionName);
    final fontSize = size * (32 / 96); // Scale initials font with avatar size

    final decoration = BoxDecoration(
      color: accentColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadow != null ? [shadow!] : null,
    );

    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: hasLogo
            ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(
                  initials: initials,
                  fontSize: fontSize,
                ),
              )
            : _Initials(initials: initials, fontSize: fontSize),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final double fontSize;

  const _Initials({required this.initials, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
          height: 1,
        ),
      ),
    );
  }
}
