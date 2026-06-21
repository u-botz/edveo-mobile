import 'package:edveo/features/quizzes/data/models/past_quiz_result_model.dart';
import 'package:edveo/features/quizzes/data/models/upcoming_quiz_model.dart';

class StudentExamsModel {
  final double? avgScore;
  final int testsTaken;
  final int upcomingCount;
  final List<UpcomingQuizModel> upcomingQuizzes;
  final List<PastQuizResultModel> pastScores;

  const StudentExamsModel({
    required this.avgScore,
    required this.testsTaken,
    required this.upcomingCount,
    required this.upcomingQuizzes,
    required this.pastScores,
  });

  factory StudentExamsModel.fromJson(Map<String, dynamic> json) {
    final stats    = json['stats'] as Map<String, dynamic>? ?? {};
    final rawPast  = json['past_scores'] as List<dynamic>? ?? [];
    final rawUp    = json['upcoming_quizzes'] as List<dynamic>? ?? [];

    return StudentExamsModel(
      avgScore:        (stats['avg_score'] as num?)?.toDouble(),
      testsTaken:      stats['tests_taken'] as int? ?? 0,
      upcomingCount:   stats['upcoming_count'] as int? ?? rawUp.length,
      upcomingQuizzes: rawUp
          .map((e) => UpcomingQuizModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pastScores: rawPast
          .map((e) => PastQuizResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
