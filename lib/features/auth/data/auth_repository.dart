import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/auth_result.dart';
import '../../../core/models/tenant_user.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(ApiClient client) : _dio = client.dio;

  // ─── Login ───────────────────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
    required String tenantSlug,
  }) async {
    try {
      final response = await _dio.post(
        '/api/tenant/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'X-Tenant-Slug': tenantSlug},
        ),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final user = TenantUser.fromJson(
        data['user'] as Map<String, dynamic>,
      );

      await TokenStorage.saveSession(
        accessToken: accessToken,
        tenantSlug: tenantSlug,
      );

      return AuthResult.success(user: user);
    } on DioException catch (e) {
      final message = e.response?.data['error']['message'] as String? ??
          'Login failed. Please try again.';
      return AuthResult.failure(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post('/api/tenant/auth/logout');
    } catch (_) {
      // Ignore network errors — clear local session regardless
    } finally {
      await TokenStorage.clearSession();
    }
  }

  // ─── Get current user ────────────────────────────────────────────────────
  Future<TenantUser?> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/mobile/auth/me');
      return TenantUser.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── Session restore on cold start ───────────────────────────────────────
  Future<bool> restoreSession() async {
    final hasSession = await TokenStorage.hasSession();
    if (!hasSession) return false;

    final user = await getCurrentUser();
    return user != null;
  }

  /// Called by SessionManager (timer) and AppLifecycleObserver (foreground recovery).
  /// AuthInterceptor owns 401 handling — this method just fires the request.
  Future<void> refreshToken() async {
    await _dio.post('/api/tenant/auth/refresh');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
