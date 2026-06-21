class ContinueLearningItemModel {
  final int courseId;
  final String title;
  final String? thumbnailUrl;
  final int progressPercent;
  final int lessonsCompleted;
  final int lessonsTotal;

  const ContinueLearningItemModel({
    required this.courseId,
    required this.title,
    this.thumbnailUrl,
    required this.progressPercent,
    required this.lessonsCompleted,
    required this.lessonsTotal,
  });

  factory ContinueLearningItemModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningItemModel(
      courseId:         json['course_id'] as int,
      title:            json['title'] as String,
      thumbnailUrl:     json['thumbnail_url'] as String?,
      progressPercent:  json['progress_percent'] as int? ?? 0,
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      lessonsTotal:     json['lessons_total'] as int? ?? 0,
    );
  }
}
