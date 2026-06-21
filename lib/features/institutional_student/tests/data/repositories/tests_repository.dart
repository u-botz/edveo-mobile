import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../features/auth/data/auth_repository.dart';
import '../../../../../core/api/api_client.dart';
import '../models/tests_model.dart';

class TestsRepository {
  final Dio _dio;

  TestsRepository(ApiClient client) : _dio = client.dio;

  Future<StudentTestsModel> getTests() async {
    final response = await _dio.get('/api/mobile/institutional-student/tests');
    return StudentTestsModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}

final testsRepositoryProvider = Provider<TestsRepository>((ref) {
  return TestsRepository(ref.read(apiClientProvider));
});

final testsProvider = FutureProvider<StudentTestsModel>((ref) async {
  return ref.read(testsRepositoryProvider).getTests();
});
