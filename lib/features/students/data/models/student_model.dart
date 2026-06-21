class StudentCourse {
  final int id;
  final String title;
  final String slug;

  const StudentCourse({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory StudentCourse.fromJson(Map<String, dynamic> json) => StudentCourse(
        id: json['id'] as int,
        title: json['title'] as String,
        slug: json['slug'] as String,
      );
}

class Student {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final List<StudentCourse> enrolledCourses;
  final int totalEnrollments;
  final DateTime? earliestEnrolledAt;

  const Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.enrolledCourses,
    required this.totalEnrollments,
    this.earliestEnrolledAt,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatar_url'] as String?,
        enrolledCourses: (json['enrolled_courses'] as List<dynamic>)
            .map((c) => StudentCourse.fromJson(c as Map<String, dynamic>))
            .toList(),
        totalEnrollments: json['total_enrollments'] as int,
        earliestEnrolledAt: json['earliest_enrolled_at'] != null
            ? DateTime.parse(json['earliest_enrolled_at'] as String)
            : null,
      );
}

class StudentsMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const StudentsMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory StudentsMeta.fromJson(Map<String, dynamic> json) => StudentsMeta(
        currentPage: json['current_page'] as int,
        lastPage: json['last_page'] as int,
        perPage: json['per_page'] as int,
        total: json['total'] as int,
      );

  bool get hasNextPage => currentPage < lastPage;
}

class StudentsResponse {
  final List<Student> students;
  final StudentsMeta meta;

  const StudentsResponse({
    required this.students,
    required this.meta,
  });

  factory StudentsResponse.fromJson(Map<String, dynamic> json) => StudentsResponse(
        students: (json['students'] as List<dynamic>)
            .map((s) => Student.fromJson(s as Map<String, dynamic>))
            .toList(),
        meta: StudentsMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}
