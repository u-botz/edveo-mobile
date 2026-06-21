/// A completed quiz attempt (passed or failed) for the student history list.
///
/// Plain Dart model — no freezed (package not in pubspec).
class PastQuizResultModel {
  final int resultId;
  final int quizId;
  final String title;
  final int? courseId;
  final String? courseTitle;
  final double marksObtained;
  final double marksTotal;
  final int percent;
  final bool passed;
  final String? gradeLetter;
  final DateTime? submittedAt;

  const PastQuizResultModel({
    required this.resultId,
    required this.quizId,
    required this.title,
    this.courseId,
    this.courseTitle,
    required this.marksObtained,
    required this.marksTotal,
    required this.percent,
    required this.passed,
    this.gradeLetter,
    this.submittedAt,
  });

  factory PastQuizResultModel.fromJson(Map<String, dynamic> json) {
    return PastQuizResultModel(
      resultId:      json['result_id'] as int,
      quizId:        json['quiz_id'] as int,
      title:         json['title'] as String,
      courseId:      json['course_id'] as int?,
      courseTitle:   json['course_title'] as String?,
      marksObtained: (json['marks_obtained'] as num).toDouble(),
      marksTotal:    (json['marks_total'] as num).toDouble(),
      percent:       json['percent'] as int? ?? 0,
      passed:        json['passed'] as bool? ?? false,
      gradeLetter:   json['grade_letter'] as String?,
      submittedAt:   json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
    );
  }
}
