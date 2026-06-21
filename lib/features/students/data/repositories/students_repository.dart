import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edveo/features/auth/data/auth_repository.dart'; // for apiClientProvider
import 'package:edveo/features/students/data/models/create_student_request.dart';
import 'package:edveo/features/students/data/models/student_model.dart';

class StudentsRepository {
  StudentsRepository(this._dio);

  final Dio _dio;

  Future<StudentsResponse> fetchStudents({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/mobile/standalone/students',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        return StudentsResponse(
          students: [],
          meta: StudentsMeta(
            currentPage: 1,
            lastPage: 1,
            perPage: perPage,
            total: 0,
          ),
        );
      }

      final students = (data['data'] as List<dynamic>)
          .map((s) => Student.fromJson(s as Map<String, dynamic>))
          .toList();

      final meta =
          StudentsMeta.fromJson(data['meta'] as Map<String, dynamic>);

      return StudentsResponse(students: students, meta: meta);
    } on DioException {
      return StudentsResponse(
        students: [],
        meta: StudentsMeta(
          currentPage: 1,
          lastPage: 1,
          perPage: perPage,
          total: 0,
        ),
      );
    }
  }

  Future<void> createStudent(CreateStudentRequest request) async {
    final response = await _dio.post(
      '/api/mobile/standalone/students',
      data: request.toJson(),
    );
    // Non-2xx throws DioException via the interceptor.
    // 422 (duplicate email) and 403 (no capability) surface as DioException
    // with response attached — create_student_provider reads the error body.
    if (response.statusCode != 201) {
      throw Exception('Unexpected status: ${response.statusCode}');
    }
  }
}

final studentsRepositoryProvider = Provider<StudentsRepository>((ref) {
  return StudentsRepository(ref.read(apiClientProvider).dio);
});
