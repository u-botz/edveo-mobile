class StudentHomeLiveSessionModel {
  final int id;
  final String title;
  final int? courseId;
  final DateTime scheduledAt;
  final int? durationMinutes;
  final String? joinLink;
  final String status;
  final String? instructorName;

  const StudentHomeLiveSessionModel({
    required this.id,
    required this.title,
    this.courseId,
    required this.scheduledAt,
    this.durationMinutes,
    this.joinLink,
    required this.status,
    this.instructorName,
  });

  factory StudentHomeLiveSessionModel.fromJson(Map<String, dynamic> json) {
    return StudentHomeLiveSessionModel(
      id:              json['id'] as int,
      title:           json['title'] as String,
      courseId:        json['course_id'] as int?,
      scheduledAt:     DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int?,
      joinLink:        json['join_link'] as String?,
      status:          json['status'] as String,
      instructorName:  json['instructor_name'] as String?,
    );
  }
}
