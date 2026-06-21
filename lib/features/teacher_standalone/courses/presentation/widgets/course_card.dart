import 'package:flutter/material.dart';
import 'package:edveo/features/courses/data/models/course_model.dart';
import '../../../../../core/utils/rupee_formatter.dart';
import 'course_thumbnail.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onManage;
  final VoidCallback onAnalytics;
  final VoidCallback onContinueEditing;

  const CourseCard({
    super.key,
    required this.course,
    required this.onManage,
    required this.onAnalytics,
    required this.onContinueEditing,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived = course.status == CourseStatus.archived;
    final isDraft    = course.status == CourseStatus.draft;

    return Opacity(
      opacity: isArchived ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: thumbnail + info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseThumbnail(
                  thumbnailUrl: course.thumbnailUrl,
                  courseTitle:  course.title,
                  courseId:     course.id,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      _StatusBadge(status: course.status),
                      const SizedBox(height: 8),
                      Text(
                        '${course.studentCount} students · ${course.lessonCount} lessons · ${formatRupees(course.priceAmount)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress bar — published only
            if (course.status == CourseStatus.published) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Avg completion',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                    '${course.avgCompletionPercent}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: course.avgCompletionPercent / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF1A56DB)),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Action buttons
            if (isDraft)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onContinueEditing,
                  child: const Text('Continue editing'),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isArchived ? null : onManage,
                      child: const Text('Manage'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isArchived ? null : onAnalytics,
                      child: const Text('Analytics'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CourseStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      CourseStatus.published => ('Published', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      CourseStatus.draft     => ('Draft',     const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
      CourseStatus.archived  => ('Archived',  const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
