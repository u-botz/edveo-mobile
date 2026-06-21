import 'package:edveo/features/quizzes/data/models/past_quiz_result_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastScoreRow extends StatelessWidget {
  final PastQuizResultModel result;

  const PastScoreRow({super.key, required this.result});

  /// BR-EX-006 / §4: badge colour by grade letter.
  /// D-EX-004: computed server-side — Flutter renders only.
  Color _badgeColor(String? grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF00875A); // green
      case 'B+':
      case 'B':
        return const Color(0xFF4F46E5); // indigo
      case 'C':
        return const Color(0xFFD97706); // amber
      case 'F':
        return const Color(0xFFDC2626); // red
      default:
        return Colors.grey; // null → '—' (BR-EX-007)
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('d MMM').format(dt.toLocal()); // BR-EX-008
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor(result.gradeLetter);

    return GestureDetector(
      // D-EX-009: attempt flow deferred — stub snackbar
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz attempt coming soon'),
          duration: Duration(seconds: 2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Grade letter badge (BR-EX-005 / BR-EX-006)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  result.gradeLetter ?? '—', // BR-EX-007: null → '—'
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + submitted date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.submittedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(result.submittedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing: marks_obtained / marks_total (D-EX-008)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: result.marksObtained.toStringAsFixed(
                      result.marksObtained % 1 == 0 ? 0 : 1,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextSpan(
                    text:
                        '/${result.marksTotal.toStringAsFixed(result.marksTotal % 1 == 0 ? 0 : 1)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
