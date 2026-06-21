enum ActivityEventType {
  courseEnrolled,
  paymentReceived,
  newStudentRegistered,
}

class HomeStatsModel {
  final int todayEarningsCents;
  final int monthEarningsCents;
  final int activeStudentsCount;

  const HomeStatsModel({
    required this.todayEarningsCents,
    required this.monthEarningsCents,
    required this.activeStudentsCount,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) => HomeStatsModel(
        todayEarningsCents: json['today_earnings_cents'] as int,
        monthEarningsCents: json['month_earnings_cents'] as int,
        activeStudentsCount: json['active_students_count'] as int,
      );
}

class ScheduleSessionModel {
  final int id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final int durationMinutes;
  final String provider;
  final String hostUrl;
  final int batchId;

  const ScheduleSessionModel({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.durationMinutes,
    required this.provider,
    required this.hostUrl,
    required this.batchId,
  });

  factory ScheduleSessionModel.fromJson(Map<String, dynamic> json) =>
      ScheduleSessionModel(
        id: json['id'] as int,
        title: json['title'] as String,
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        durationMinutes: json['duration_minutes'] as int,
        provider: json['provider'] as String,
        hostUrl: json['host_url'] as String,
        batchId: json['batch_id'] as int,
      );
}

class ActivityEventModel {
  final ActivityEventType type;
  final String studentName;
  final int? amountCents;
  final String? courseName;
  final DateTime occurredAt;

  const ActivityEventModel({
    required this.type,
    required this.studentName,
    this.amountCents,
    this.courseName,
    required this.occurredAt,
  });

  factory ActivityEventModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = switch (typeStr) {
      'course_enrolled' => ActivityEventType.courseEnrolled,
      'payment_received' => ActivityEventType.paymentReceived,
      _ => ActivityEventType.newStudentRegistered,
    };
    return ActivityEventModel(
      type: type,
      studentName: json['student_name'] as String,
      amountCents: json['amount_cents'] as int?,
      courseName: json['course_name'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );
  }
}

class RevenueChartEntry {
  final String date;
  final String label;
  final int amountCents;

  const RevenueChartEntry({
    required this.date,
    required this.label,
    required this.amountCents,
  });

  factory RevenueChartEntry.fromJson(Map<String, dynamic> json) =>
      RevenueChartEntry(
        date:        json['date'] as String,
        label:       json['label'] as String,
        amountCents: json['amount_cents'] as int,
      );
}

class EnrollmentChartEntry {
  final String date;
  final String label;
  final int count;

  const EnrollmentChartEntry({
    required this.date,
    required this.label,
    required this.count,
  });

  factory EnrollmentChartEntry.fromJson(Map<String, dynamic> json) =>
      EnrollmentChartEntry(
        date:  json['date'] as String,
        label: json['label'] as String,
        count: json['count'] as int,
      );
}

class HomeChartsModel {
  final List<RevenueChartEntry> revenue;
  final List<EnrollmentChartEntry> enrollments;

  const HomeChartsModel({
    required this.revenue,
    required this.enrollments,
  });

  factory HomeChartsModel.fromJson(Map<String, dynamic> json) => HomeChartsModel(
        revenue: (json['revenue'] as List<dynamic>)
            .map((e) => RevenueChartEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        enrollments: (json['enrollments'] as List<dynamic>)
            .map((e) => EnrollmentChartEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class HomeDataModel {
  final HomeStatsModel stats;
  final List<ScheduleSessionModel> schedule;
  final List<ActivityEventModel> activity;
  final HomeChartsModel charts;

  const HomeDataModel({
    required this.stats,
    required this.schedule,
    required this.activity,
    required this.charts,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
        stats: HomeStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
        schedule: (json['schedule'] as List<dynamic>)
            .map((e) => ScheduleSessionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        activity: (json['activity'] as List<dynamic>)
            .map((e) => ActivityEventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        charts: HomeChartsModel.fromJson(json['charts'] as Map<String, dynamic>),
      );
}
