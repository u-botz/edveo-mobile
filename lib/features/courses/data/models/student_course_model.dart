/// A single enrolled course as returned by GET /api/mobile/student/courses.
///
/// Plain Dart model — no freezed (package not in pubspec).
class StudentCourseModel {
  final int courseId;
  final String title;
  final String? thumbnailUrl;
  final String? teacherName;
  final String? categorySlug;
  final String? categoryTitle;
  final String? categoryIcon;
  final int progressPercent;
  final int lessonsCompleted;
  final int lessonsTotal;
  final bool isCompleted;
  final String? availabilityBadge;
  final DateTime? lastViewedAt;
  final DateTime? enrolledAt;

  const StudentCourseModel({
    required this.courseId,
    required this.title,
    this.thumbnailUrl,
    this.teacherName,
    this.categorySlug,
    this.categoryTitle,
    this.categoryIcon,
    required this.progressPercent,
    required this.lessonsCompleted,
    required this.lessonsTotal,
    required this.isCompleted,
    this.availabilityBadge,
    this.lastViewedAt,
    this.enrolledAt,
  });

  factory StudentCourseModel.fromJson(Map<String, dynamic> json) {
    return StudentCourseModel(
      courseId:          json['course_id'] as int,
      title:             json['title'] as String,
      thumbnailUrl:      json['thumbnail_url'] as String?,
      teacherName:       json['teacher_name'] as String?,
      categorySlug:      json['category_slug'] as String?,
      categoryTitle:     json['category_title'] as String?,
      categoryIcon:      json['category_icon'] as String?,
      progressPercent:   json['progress_percent'] as int? ?? 0,
      lessonsCompleted:  json['lessons_completed'] as int? ?? 0,
      lessonsTotal:      json['lessons_total'] as int? ?? 0,
      isCompleted:       json['is_completed'] as bool? ?? false,
      availabilityBadge: json['availability_badge'] as String?,
      lastViewedAt:      json['last_viewed_at'] != null
          ? DateTime.tryParse(json['last_viewed_at'] as String)
          : null,
      enrolledAt:        json['enrolled_at'] != null
          ? DateTime.tryParse(json['enrolled_at'] as String)
          : null,
    );
  }
}
