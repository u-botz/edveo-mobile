import 'package:dio/dio.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/student_home/data/models/student_home_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentHomeRepository {
  final Dio _dio;

  StudentHomeRepository(this._dio);

  Future<StudentHomeModel> getHomeData() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/student/home',
    );
    return StudentHomeModel.fromJson(response.data!);
  }
}

final studentHomeRepositoryProvider = Provider<StudentHomeRepository>((ref) {
  return StudentHomeRepository(ref.read(apiClientProvider).dio);
});
