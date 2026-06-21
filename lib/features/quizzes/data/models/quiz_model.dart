/// Shared quiz model used across standalone teacher quiz screens.
class QuizModel {
  final int id;
  final String title;
  final String status;
  final String statusLabel;
  final String quizType;
  final String typeLabel;
  final int totalQuestions;
  final int totalAttempts;
  final int timeMinutes;
  final String passMark;
  final String totalMark;
  final DateTime? createdAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.quizType,
    required this.typeLabel,
    required this.totalQuestions,
    required this.totalAttempts,
    required this.timeMinutes,
    required this.passMark,
    required this.totalMark,
    this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id:             json['id'] as int,
      title:          json['title'] as String,
      status:         json['status'] as String,
      statusLabel:    json['status_label'] as String,
      quizType:       json['quiz_type'] as String,
      typeLabel:      json['type_label'] as String,
      totalQuestions: json['total_questions'] as int,
      totalAttempts:  json['total_attempts'] as int,
      timeMinutes:    json['time_minutes'] as int,
      passMark:       json['pass_mark']?.toString() ?? '0',
      totalMark:      json['total_mark']?.toString() ?? '0',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
