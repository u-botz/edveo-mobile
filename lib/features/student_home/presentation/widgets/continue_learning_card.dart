import 'package:edveo/features/student_home/data/models/continue_learning_item_model.dart';
import 'package:flutter/material.dart';

class ContinueLearningCard extends StatelessWidget {
  final ContinueLearningItemModel item;

  const ContinueLearningCard({super.key, required this.item});

  // Deterministic color accent per course
  static const _courseColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
  ];

  Color get _accentColor => _courseColors[item.courseId % _courseColors.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail or color swatch
          _buildThumbnail(),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${item.progressPercent}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: _accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progressPercent / 100,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: _accentColor,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return SizedBox(
        height: 88,
        width: double.infinity,
        child: Image.network(
          item.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _colorSwatch(),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _greyPlaceholder(),
        ),
      );
    }
    return _colorSwatch();
  }

  Widget _colorSwatch() {
    return Container(
      height: 88,
      width: double.infinity,
      color: _accentColor.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: _accentColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _greyPlaceholder() {
    return Container(
      height: 88,
      width: double.infinity,
      color: const Color(0xFFF3F4F6),
    );
  }
}
