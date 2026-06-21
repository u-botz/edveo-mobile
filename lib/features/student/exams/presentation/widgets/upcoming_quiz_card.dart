import 'package:edveo/features/quizzes/data/models/upcoming_quiz_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingQuizCard extends StatelessWidget {
  final UpcomingQuizModel quiz;

  const UpcomingQuizCard({super.key, required this.quiz});

  // Deterministic left-border color per quiz id
  static const _borderColors = [
    Color(0xFF2563EB), // blue
    Color(0xFF7C3AED), // purple
    Color(0xFF0891B2), // cyan
    Color(0xFF059669), // green
    Color(0xFFD97706), // amber
  ];

  Color get _accent => _borderColors[quiz.quizId % _borderColors.length];

  String _formatScheduled(DateTime? dt) {
    if (dt == null) return 'TBA';
    final local = dt.toLocal();
    return '${DateFormat('EEE, d MMM').format(local)} · ${DateFormat('h:mm a').format(local)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(width: 4, color: _accent),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + SCHEDULED badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: const Text(
                            'SCHEDULED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEA580C),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Date/time row
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatScheduled(quiz.scheduledAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Questions · Duration
                    Text(
                      [
                        if (quiz.questionsCount > 0)
                          '${quiz.questionsCount} questions',
                        if (quiz.durationMinutes > 0)
                          '${quiz.durationMinutes} min',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
