import 'package:flutter/material.dart';

class CourseThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final String courseTitle;
  final int courseId;
  final double size;

  const CourseThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.courseTitle,
    required this.courseId,
    this.size = 72,
  });

  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF6366F1),
  ];

  Color get _color => _colors[courseId % _colors.length];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
          ? Image.network(
              thumbnailUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    final initial = courseTitle.isNotEmpty ? courseTitle[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      color: _color,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
