import 'package:flutter/material.dart';

/// Two-colour pair for a course category — resolved entirely client-side.
class CourseColors {
  const CourseColors(this.primary, this.dark);

  final Color primary;
  final Color dark;
}

/// Maps a category slug to a [CourseColors] pair used on course thumbnails
/// and progress bars.
///
/// Add new slug entries here as tenants request them — no backend change needed.
class CourseTheme {
  CourseTheme._();

  static const _default = CourseColors(Color(0xFF6B7280), Color(0xFF4B5563));

  static const _map = <String, CourseColors>{
    'physics':     CourseColors(Color(0xFF2563EB), Color(0xFF1D4ED8)),
    'chemistry':   CourseColors(Color(0xFF7C3AED), Color(0xFF6D28D9)),
    'math':        CourseColors(Color(0xFFF97316), Color(0xFFEA580C)),
    'maths':       CourseColors(Color(0xFFF97316), Color(0xFFEA580C)),
    'mathematics': CourseColors(Color(0xFFF97316), Color(0xFFEA580C)),
    'biology':     CourseColors(Color(0xFF0891B2), Color(0xFF0E7490)),
    'bio':         CourseColors(Color(0xFF0891B2), Color(0xFF0E7490)),
    'english':     CourseColors(Color(0xFF059669), Color(0xFF047857)),
    'history':     CourseColors(Color(0xFFD97706), Color(0xFFB45309)),
    'geography':   CourseColors(Color(0xFF0D9488), Color(0xFF0F766E)),
    'computer':    CourseColors(Color(0xFF4F46E5), Color(0xFF4338CA)),
    'it':          CourseColors(Color(0xFF4F46E5), Color(0xFF4338CA)),
  };

  static CourseColors fromSlug(String? slug) {
    if (slug == null) return _default;
    return _map[slug.toLowerCase().trim()] ?? _default;
  }
}
