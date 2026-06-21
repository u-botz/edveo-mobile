import 'package:flutter/material.dart';

/// Coloured status pill for blog post cards.
///
/// Colours (BR-BL-002):
///   published → green   #22C55E
///   scheduled → blue    #3B82F6
///   draft     → grey    #9CA3AF
class BlogStatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const BlogStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  Color get _color => switch (status) {
        'published' => const Color(0xFF22C55E),
        'scheduled' => const Color(0xFF3B82F6),
        _           => const Color(0xFF9CA3AF),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
