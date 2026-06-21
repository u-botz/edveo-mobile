import 'package:dio/dio.dart';
import 'package:edveo/features/quizzes/data/models/student_exams_model.dart';

class StudentExamsRepository {
  final Dio _dio;

  StudentExamsRepository(this._dio);

  Future<StudentExamsModel> getExams() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/student/exams',
    );
    return StudentExamsModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
