import 'package:flutter/material.dart';

class QuizStatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const QuizStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static (Color, Color) _colors(String status) {
    return switch (status) {
      'active'   => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      'draft'    => (const Color(0xFFF3F4F6), const Color(0xFF374151)),
      'inactive' => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      'closed'   => (const Color(0xFFE5E7EB), const Color(0xFF6B7280)),
      _          => (const Color(0xFFF3F4F6), const Color(0xFF374151)),
    };
  }
}
