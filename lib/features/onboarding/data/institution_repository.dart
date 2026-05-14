import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/data/auth_repository.dart';

class InstitutionResult {
  final String slug;
  final String name;
  final String city;
  final String? logoUrl;

  const InstitutionResult({
    required this.slug,
    required this.name,
    required this.city,
    this.logoUrl,
  });

  factory InstitutionResult.fromJson(Map<String, dynamic> json) {
    return InstitutionResult(
      slug:    json['slug'] as String,
      name:    json['name'] as String,
      city:    json['city'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class InstitutionRepository {
  final ApiClient _apiClient;

  InstitutionRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<InstitutionResult>> search(String query) async {
    final response = await _apiClient.dio.get(
      '/api/mobile/institutions/search',
      queryParameters: {'q': query},
    );

    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => InstitutionResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final institutionRepositoryProvider = Provider<InstitutionRepository>((ref) {
  return InstitutionRepository(apiClient: ref.read(apiClientProvider));
});
