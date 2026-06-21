import 'package:dio/dio.dart';
import 'package:edveo/features/courses/data/models/student_course_model.dart';

class StudentCoursesRepository {
  final Dio _dio;

  StudentCoursesRepository(this._dio);

  Future<List<StudentCourseModel>> getCourses({String filter = 'all'}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/student/courses',
      queryParameters: {'filter': filter},
    );

    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => StudentCourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
