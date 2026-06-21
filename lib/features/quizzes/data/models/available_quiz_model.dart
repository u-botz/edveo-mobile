/// A quiz the student can take right now.
///
/// Plain Dart model — no freezed (package not in pubspec).
class AvailableQuizModel {
  final int quizId;
  final String title;
  final int? courseId;
  final String? courseTitle;
  final double totalMark;
  final int timeMinutes;

  const AvailableQuizModel({
    required this.quizId,
    required this.title,
    this.courseId,
    this.courseTitle,
    required this.totalMark,
    required this.timeMinutes,
  });

  factory AvailableQuizModel.fromJson(Map<String, dynamic> json) {
    return AvailableQuizModel(
      quizId:      json['quiz_id'] as int,
      title:       json['title'] as String,
      courseId:    json['course_id'] as int?,
      courseTitle: json['course_title'] as String?,
      totalMark:   (json['total_mark'] as num).toDouble(),
      timeMinutes: json['time_minutes'] as int? ?? 0,
    );
  }
}
