import 'package:edveo/features/quizzes/data/models/available_quiz_model.dart';
import 'package:edveo/features/student/courses/presentation/utils/course_theme.dart';
import 'package:flutter/material.dart';

class AvailableQuizCard extends StatelessWidget {
  final AvailableQuizModel quiz;

  const AvailableQuizCard({super.key, required this.quiz});

  /// Derives a rail color using courseTitle as a loose slug hint.
  /// Most titles won't match the map — they gracefully fall back to grey.
  Color get _railColor =>
      CourseTheme.fromSlug(quiz.courseTitle?.toLowerCase()).primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left colour rail
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _railColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Course name (if present)
                      if (quiz.courseTitle != null &&
                          quiz.courseTitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quiz.courseTitle!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Duration footer
                      if (quiz.timeMinutes > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${quiz.timeMinutes} min',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
