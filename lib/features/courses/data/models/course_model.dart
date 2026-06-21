enum CourseStatus { published, draft, archived }

class CourseModel {
  final int id;
  final String title;
  final String slug;
  final CourseStatus status;
  final String? thumbnailUrl;
  final int priceAmount; // In rupees, NOT paise — display directly
  final int studentCount;
  final int lessonCount;
  final int avgCompletionPercent;

  const CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.status,
    this.thumbnailUrl,
    required this.priceAmount,
    required this.studentCount,
    required this.lessonCount,
    required this.avgCompletionPercent,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id:                   json['id'] as int,
        title:                json['title'] as String,
        slug:                 json['slug'] as String,
        status:               _parseStatus(json['status'] as String),
        thumbnailUrl:         json['thumbnail_url'] as String?,
        priceAmount:          json['price_amount'] as int,
        studentCount:         json['student_count'] as int,
        lessonCount:          json['lesson_count'] as int,
        avgCompletionPercent: json['avg_completion_percent'] as int,
      );

  static CourseStatus _parseStatus(String value) => switch (value) {
        'published' => CourseStatus.published,
        'draft'     => CourseStatus.draft,
        'archived'  => CourseStatus.archived,
        _           => CourseStatus.draft,
      };
}

class CoursesScreenModel {
  final int totalCourses;
  final int totalStudents;
  final List<CourseModel> courses;

  const CoursesScreenModel({
    required this.totalCourses,
    required this.totalStudents,
    required this.courses,
  });

  factory CoursesScreenModel.fromJson(Map<String, dynamic> json) {
    final data   = json['data'] as Map<String, dynamic>;
    final header = data['header'] as Map<String, dynamic>;
    return CoursesScreenModel(
      totalCourses:  header['total_courses'] as int,
      totalStudents: header['total_students'] as int,
      courses: (data['courses'] as List<dynamic>)
          .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
