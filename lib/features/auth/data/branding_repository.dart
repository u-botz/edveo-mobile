import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/tenant_branding.dart';
import 'auth_repository.dart'; // for apiClientProvider

class BrandingRepository {
  final ApiClient _apiClient;

  BrandingRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<TenantBranding> fetchBranding(String tenantSlug) async {
    // X-Tenant-Slug is attached by AuthInterceptor from TokenStorage.
    // For branding, the slug is not yet in TokenStorage (user not logged in).
    // Pass it as a request header override via Dio options.
    final response = await _apiClient.dio.get(
      '/api/mobile/branding',
      options: Options(headers: {'X-Tenant-Slug': tenantSlug}),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return TenantBranding.fromJson(data);
  }
}

final brandingRepositoryProvider = Provider<BrandingRepository>((ref) {
  return BrandingRepository(apiClient: ref.read(apiClientProvider));
});
