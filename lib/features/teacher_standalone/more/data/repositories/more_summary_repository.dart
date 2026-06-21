import 'package:dio/dio.dart';
import 'package:edveo/core/api/api_client.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:edveo/features/teacher_standalone/more/data/models/more_summary_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreSummaryRepository {
  final Dio _dio;

  MoreSummaryRepository(ApiClient client) : _dio = client.dio;

  Future<MoreSummaryModel> fetchMoreSummary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/standalone-teacher/more-summary',
    );
    final body = response.data!;
    return MoreSummaryModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}

final moreSummaryRepositoryProvider = Provider<MoreSummaryRepository>((ref) {
  return MoreSummaryRepository(ref.read(apiClientProvider));
});
