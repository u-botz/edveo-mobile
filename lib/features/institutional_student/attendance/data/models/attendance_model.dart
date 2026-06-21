class StudentAttendanceModel {
  final AttendanceSummaryModel summary;
  final List<AttendanceSessionModel> sessions;

  const StudentAttendanceModel({
    required this.summary,
    required this.sessions,
  });

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceModel(
      summary: AttendanceSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => AttendanceSessionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttendanceSummaryModel {
  final String periodLabel;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final int attended;
  final int total;
  final double percentage;
  final int threshold;
  final String status; // safe | warning | critical

  const AttendanceSummaryModel({
    required this.periodLabel,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.attended,
    required this.total,
    required this.percentage,
    required this.threshold,
    required this.status,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      periodLabel: json['period_label'] as String,
      present:     json['present'] as int,
      absent:      json['absent'] as int,
      late:        json['late'] as int,
      excused:     json['excused'] as int,
      attended:    json['attended'] as int,
      total:       json['total'] as int,
      percentage:  (json['percentage'] as num).toDouble(),
      threshold:   json['threshold'] as int,
      status:      json['status'] as String,
    );
  }

  bool get isSafe     => status == 'safe';
  bool get isWarning  => status == 'warning';
  bool get isCritical => status == 'critical';
}

class AttendanceSessionModel {
  final int sessionId;
  final String sessionTitle;
  final String sessionDate;
  final String dayLabel;
  final String startTime;
  final String endTime;
  final String? status; // present | absent | late | excused | null = not marked

  const AttendanceSessionModel({
    required this.sessionId,
    required this.sessionTitle,
    required this.sessionDate,
    required this.dayLabel,
    required this.startTime,
    required this.endTime,
    this.status,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      sessionId:    json['session_id'] as int,
      sessionTitle: json['session_title'] as String,
      sessionDate:  json['session_date'] as String,
      dayLabel:     json['day_label'] as String,
      startTime:    json['start_time'] as String,
      endTime:      json['end_time'] as String,
      status:       json['status'] as String?,
    );
  }
}
