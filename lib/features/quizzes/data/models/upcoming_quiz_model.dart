class UpcomingQuizModel {
  final int quizId;
  final String title;
  final String? courseTitle;
  final DateTime? scheduledAt;
  final int durationMinutes;
  final int questionsCount;

  const UpcomingQuizModel({
    required this.quizId,
    required this.title,
    this.courseTitle,
    this.scheduledAt,
    required this.durationMinutes,
    required this.questionsCount,
  });

  factory UpcomingQuizModel.fromJson(Map<String, dynamic> json) {
    return UpcomingQuizModel(
      quizId:          json['quiz_id'] as int,
      title:           json['title'] as String,
      courseTitle:     json['course_title'] as String?,
      scheduledAt:     json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      questionsCount:  json['questions_count'] as int? ?? 0,
    );
  }
}
