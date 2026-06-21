import 'package:edveo/features/quizzes/data/models/quiz_model.dart';
import 'package:edveo/features/teacher_standalone/more/quizzes/presentation/widgets/quiz_status_badge.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;

  const QuizCard({super.key, required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                QuizStatusBadge(status: quiz.status, label: quiz.statusLabel),
              ],
            ),
            const SizedBox(height: 8),

            // Metadata chips row
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _MetaChip(
                  icon: Icons.category_rounded,
                  label: quiz.typeLabel,
                ),
                _MetaChip(
                  icon: Icons.help_outline_rounded,
                  label: '${quiz.totalQuestions} Qs',
                ),
                _MetaChip(
                  icon: Icons.timer_outlined,
                  label: '${quiz.timeMinutes} min',
                ),
                _MetaChip(
                  icon: Icons.people_outline_rounded,
                  label: '${quiz.totalAttempts} attempts',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Pass mark / total mark footer
            Row(
              children: [
                Text(
                  'Pass: ${quiz.passMark} / ${quiz.totalMark}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFC7CDD6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
