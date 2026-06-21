import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/auth_result.dart';
import 'models/me_model.dart';
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
      return AuthResult.failure(
        message: e.response?.data?['error']?['message'] ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return AuthResult.failure(message: 'Login failed');
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────
  Future<String> loginWithGoogle({
    required String idToken,
    required String tenantSlug,
  }) async {
    final response = await _dio.post(
      '/api/mobile/auth/google',
      data: {'id_token': idToken},
      options: Options(
        headers: {'X-Tenant-Slug': tenantSlug},
      ),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final role = user['role'] as String;

    await TokenStorage.saveSession(
      accessToken: accessToken,
      tenantSlug: tenantSlug,
    );

    return role;
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

  // Mobile More-page logout — clears local session regardless of network result.
  Future<void> mobileLogout() async {
    try {
      await _dio.post('/api/mobile/auth/logout');
    } catch (_) {
      // Ignore network errors — local session is always cleared
    } finally {
      await TokenStorage.clearSession();
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      '/api/mobile/auth/update-password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // ─── Get current user ────────────────────────────────────────────────────
  Future<MeModel?> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/mobile/auth/me');
      return MeModel.fromJson(
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
  /// Persists the rotated token so blacklist-enabled servers don't strand mobile
  /// on the old (now-blacklisted) token. AuthInterceptor owns 401 handling.
  Future<void> refreshToken() async {
    final response = await _dio.post('/api/tenant/auth/refresh');
    final newToken =
        response.data['data']['access_token'] as String?;
    if (newToken != null) {
      await TokenStorage.updateToken(newToken);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
