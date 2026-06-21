import 'package:edveo/features/courses/data/models/student_course_model.dart';
import 'package:edveo/features/student/courses/presentation/utils/course_theme.dart';
import 'package:flutter/material.dart';

// Subject icon map: slug → Material Icons (Tabler not in pubspec)
const _slugIconMap = <String, IconData>{
  'physics':     Icons.bubble_chart_outlined,
  'chemistry':   Icons.science_outlined,
  'math':        Icons.functions_outlined,
  'maths':       Icons.functions_outlined,
  'mathematics': Icons.functions_outlined,
  'biology':     Icons.biotech_outlined,
  'bio':         Icons.biotech_outlined,
  'english':     Icons.menu_book_outlined,
  'history':     Icons.history_edu_outlined,
  'geography':   Icons.public_outlined,
  'computer':    Icons.computer_outlined,
  'it':          Icons.computer_outlined,
};

IconData _iconForSlug(String? slug) {
  if (slug == null) return Icons.menu_book_outlined;
  return _slugIconMap[slug.toLowerCase().trim()] ?? Icons.menu_book_outlined;
}

class CourseListCard extends StatelessWidget {
  final StudentCourseModel course;

  const CourseListCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = CourseTheme.fromSlug(course.categorySlug);
    final isUnavailable = course.availabilityBadge == 'unavailable';
    final teacherLabel = course.teacherName ?? 'Instructor';

    return GestureDetector(
      onTap: () {
        // M3 stub — M3-C will build the full detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course detail coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            _buildThumbnail(colors, isUnavailable),
            const SizedBox(width: 12),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.1,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Unavailability badge
                  if (isUnavailable) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Unavailable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Meta line
                  Text(
                    '$teacherLabel · ${course.lessonsCompleted} of ${course.lessonsTotal} chapters',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Progress row
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: course.progressPercent / 100,
                            backgroundColor: const Color(0xFFE5E7EB),
                            color: colors.primary,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${course.progressPercent}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(CourseColors colors, bool isUnavailable) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 48,
            height: 48,
            child: course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                ? Image.network(
                    course.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _colorSwatch(colors),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _colorSwatch(colors),
                  )
                : _colorSwatch(colors),
          ),
        ),
        if (isUnavailable)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              color: Colors.black.withValues(alpha: 0.4),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _colorSwatch(CourseColors colors) {
    return Container(
      width: 48,
      height: 48,
      color: colors.primary,
      child: Center(
        child: Icon(
          _iconForSlug(course.categorySlug),
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
