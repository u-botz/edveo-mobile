class StudentTestsModel {
  final TestsStatsModel stats;
  final List<UpcomingTestModel> upcoming;
  final List<TestResultModel> recentResults;

  const StudentTestsModel({
    required this.stats,
    required this.upcoming,
    required this.recentResults,
  });

  factory StudentTestsModel.fromJson(Map<String, dynamic> json) {
    return StudentTestsModel(
      stats: TestsStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      upcoming: (json['upcoming'] as List<dynamic>)
          .map((e) => UpcomingTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentResults: (json['recent_results'] as List<dynamic>)
          .map((e) => TestResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TestsStatsModel {
  final int testsTaken;
  final double? avgScore;

  const TestsStatsModel({required this.testsTaken, this.avgScore});

  factory TestsStatsModel.fromJson(Map<String, dynamic> json) {
    return TestsStatsModel(
      testsTaken: json['tests_taken'] as int,
      avgScore: (json['avg_score'] as num?)?.toDouble(),
    );
  }
}

class UpcomingTestModel {
  final int quizId;
  final String title;
  final int? courseId;
  final String? courseTitle;
  final double totalMark;
  final int timeMinutes;
  final DateTime accessStartsAt;
  final DateTime? accessEndsAt;

  const UpcomingTestModel({
    required this.quizId,
    required this.title,
    this.courseId,
    this.courseTitle,
    required this.totalMark,
    required this.timeMinutes,
    required this.accessStartsAt,
    this.accessEndsAt,
  });

  factory UpcomingTestModel.fromJson(Map<String, dynamic> json) {
    return UpcomingTestModel(
      quizId: json['quiz_id'] as int,
      title: json['title'] as String,
      courseId: json['course_id'] as int?,
      courseTitle: json['course_title'] as String?,
      totalMark: (json['total_mark'] as num).toDouble(),
      timeMinutes: json['time_minutes'] as int,
      accessStartsAt: DateTime.parse(json['access_starts_at'] as String),
      accessEndsAt: json['access_ends_at'] != null
          ? DateTime.parse(json['access_ends_at'] as String)
          : null,
    );
  }

  String get daysUntilLabel {
    final diff = accessStartsAt.difference(DateTime.now());
    if (diff.inDays > 1) return 'Opens in ${diff.inDays} days';
    if (diff.inDays == 1) return 'Opens tomorrow';
    if (diff.inHours > 1) return 'Opens in ${diff.inHours}h';
    return 'Opens soon';
  }
}

class TestResultModel {
  final int resultId;
  final int quizId;
  final String title;
  final String? courseTitle;
  final double marksObtained;
  final double marksTotal;
  final int percent;
  final bool passed;
  final String? gradeLetter;
  final DateTime? submittedAt;

  const TestResultModel({
    required this.resultId,
    required this.quizId,
    required this.title,
    this.courseTitle,
    required this.marksObtained,
    required this.marksTotal,
    required this.percent,
    required this.passed,
    this.gradeLetter,
    this.submittedAt,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      resultId: json['result_id'] as int,
      quizId: json['quiz_id'] as int,
      title: json['title'] as String,
      courseTitle: json['course_title'] as String?,
      marksObtained: (json['marks_obtained'] as num).toDouble(),
      marksTotal: (json['marks_total'] as num).toDouble(),
      percent: json['percent'] as int,
      passed: json['passed'] as bool,
      gradeLetter: json['grade_letter'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
    );
  }
}
