/// Summary KPIs for the analytics screen.
/// All numeric fields are nullable — null means no data yet (zero-state).
/// Flutter renders "—" for null vs the actual number for 0.
class QuizSummaryAnalytics {
  final int totalAttempts;
  final int? completedAttempts;
  final double? passRatePerAttempt;
  final double? averageScore;
  final double? avgCompletionMinutes;

  const QuizSummaryAnalytics({
    required this.totalAttempts,
    this.completedAttempts,
    this.passRatePerAttempt,
    this.averageScore,
    this.avgCompletionMinutes,
  });

  factory QuizSummaryAnalytics.fromJson(Map<String, dynamic> json) {
    return QuizSummaryAnalytics(
      totalAttempts:       json['total_attempts'] as int? ?? 0,
      completedAttempts:   json['completed_attempts'] as int?,
      passRatePerAttempt:  (json['pass_rate_per_attempt'] as num?)?.toDouble(),
      averageScore:        (json['average_score'] as num?)?.toDouble(),
      avgCompletionMinutes: (json['avg_completion_minutes'] as num?)?.toDouble(),
    );
  }
}

/// A single question row in the question breakdown table.
class QuizQuestionBreakdown {
  final int questionNumber;
  final String questionTitle;
  final String questionType;
  final String typeLabel;
  final int attempts;
  final double correctPct;
  final double skipRate;
  final double avgMarks;

  const QuizQuestionBreakdown({
    required this.questionNumber,
    required this.questionTitle,
    required this.questionType,
    required this.typeLabel,
    required this.attempts,
    required this.correctPct,
    required this.skipRate,
    required this.avgMarks,
  });

  factory QuizQuestionBreakdown.fromJson(Map<String, dynamic> json) {
    return QuizQuestionBreakdown(
      questionNumber: json['question_number'] as int? ?? 0,
      questionTitle:  json['question_title'] as String? ?? '',
      questionType:   json['question_type'] as String? ?? '',
      typeLabel:      json['type_label'] as String? ?? '',
      attempts:       json['attempts'] as int? ?? 0,
      correctPct:     (json['correct_pct'] as num?)?.toDouble() ?? 0.0,
      skipRate:       (json['skip_rate'] as num?)?.toDouble() ?? 0.0,
      avgMarks:       (json['avg_marks'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// A student entry in top/low performers lists.
class QuizStudentPerformer {
  final String name;
  final double score;
  final int attempts;

  const QuizStudentPerformer({
    required this.name,
    required this.score,
    required this.attempts,
  });

  factory QuizStudentPerformer.fromJson(Map<String, dynamic> json) {
    return QuizStudentPerformer(
      name:     json['name'] as String? ?? '—',
      score:    (json['score'] as num?)?.toDouble() ?? 0.0,
      attempts: json['attempts'] as int? ?? 0,
    );
  }
}

/// A bucket for the score distribution bar chart.
class QuizScoreBucket {
  final String label;
  final int count;

  const QuizScoreBucket({required this.label, required this.count});

  factory QuizScoreBucket.fromJson(Map<String, dynamic> json) {
    return QuizScoreBucket(
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

/// Student insights section of the analytics screen.
class QuizStudentInsights {
  final List<QuizStudentPerformer> topPerformers;
  final List<QuizStudentPerformer> lowPerformers;
  final List<QuizScoreBucket> scoreDistribution;
  final int studentsWithMultipleAttempts;
  final int maxAttemptsBySingleStudent;

  const QuizStudentInsights({
    required this.topPerformers,
    required this.lowPerformers,
    required this.scoreDistribution,
    required this.studentsWithMultipleAttempts,
    required this.maxAttemptsBySingleStudent,
  });

  factory QuizStudentInsights.fromJson(Map<String, dynamic> json) {
    final repeatCounts =
        json['repeat_attempt_counts'] as Map<String, dynamic>? ?? {};

    return QuizStudentInsights(
      topPerformers: (json['top_performers'] as List<dynamic>? ?? [])
          .map((e) => QuizStudentPerformer.fromJson(e as Map<String, dynamic>))
          .toList(),
      lowPerformers: (json['low_performers'] as List<dynamic>? ?? [])
          .map((e) => QuizStudentPerformer.fromJson(e as Map<String, dynamic>))
          .toList(),
      scoreDistribution: (json['score_distribution'] as List<dynamic>? ?? [])
          .map((e) => QuizScoreBucket.fromJson(e as Map<String, dynamic>))
          .toList(),
      studentsWithMultipleAttempts:
          repeatCounts['students_with_multiple_attempts'] as int? ?? 0,
      maxAttemptsBySingleStudent:
          repeatCounts['max_attempts_by_single_student'] as int? ?? 0,
    );
  }
}

/// Minimal quiz info embedded in the analytics responses.
class QuizInfo {
  final int id;
  final String title;
  final String status;
  final String statusLabel;
  final String quizType;
  final String typeLabel;
  final int timeMinutes;
  final String passMark;
  final String totalMark;

  const QuizInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.quizType,
    required this.typeLabel,
    required this.timeMinutes,
    required this.passMark,
    required this.totalMark,
  });

  factory QuizInfo.fromJson(Map<String, dynamic> json) {
    return QuizInfo(
      id:          json['id'] as int,
      title:       json['title'] as String,
      status:      json['status'] as String,
      statusLabel: json['status_label'] as String,
      quizType:    json['quiz_type'] as String,
      typeLabel:   json['type_label'] as String,
      timeMinutes: json['time_minutes'] as int,
      passMark:    json['pass_mark']?.toString() ?? '0',
      totalMark:   json['total_mark']?.toString() ?? '0',
    );
  }
}

/// Full analytics payload for the analytics summary + student insights screen.
class QuizAnalyticsModel {
  final QuizInfo quiz;
  final QuizSummaryAnalytics summary;
  final QuizStudentInsights studentInsights;

  const QuizAnalyticsModel({
    required this.quiz,
    required this.summary,
    required this.studentInsights,
  });

  factory QuizAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return QuizAnalyticsModel(
      quiz:            QuizInfo.fromJson(json['quiz'] as Map<String, dynamic>),
      summary:         QuizSummaryAnalytics.fromJson(json['summary'] as Map<String, dynamic>),
      studentInsights: QuizStudentInsights.fromJson(json['student_insights'] as Map<String, dynamic>),
    );
  }
}

/// Paginated question breakdown payload.
class QuizQuestionsPage {
  final List<QuizQuestionBreakdown> questions;
  final List<QuizQuestionBreakdown> mostMissed;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const QuizQuestionsPage({
    required this.questions,
    required this.mostMissed,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory QuizQuestionsPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return QuizQuestionsPage(
      questions: (json['data'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostMissed: (json['most_missed'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage:    meta['last_page'] as int? ?? 1,
      total:       meta['total'] as int? ?? 0,
      perPage:     meta['per_page'] as int? ?? 20,
    );
  }
}
