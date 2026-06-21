class NoticeModel {
  final int id;
  final int courseId;
  final String? color;
  final String title;
  final String? message;
  final DateTime? createdAt;

  const NoticeModel({
    required this.id,
    required this.courseId,
    this.color,
    required this.title,
    this.message,
    this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id:        json['id'] as int,
      courseId:  json['course_id'] as int,
      color:     json['color'] as String?,
      title:     json['title'] as String,
      message:   json['message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
