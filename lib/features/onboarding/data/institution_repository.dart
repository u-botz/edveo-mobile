import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import 'models/institution.dart';

class InstitutionRepository {
  InstitutionRepository(this._dio);

  final Dio _dio;

  Future<List<Institution>> search(String query) async {
    try {
      final response = await _dio.get(
        '/api/mobile/institutions/search',
        queryParameters: {'q': query},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) return [];

      final results = data['data'] as List<dynamic>? ?? [];
      return results
          .map((json) => Institution.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }
}

final institutionRepositoryProvider = Provider<InstitutionRepository>((ref) {
  return InstitutionRepository(ref.read(apiClientProvider).dio);
});
