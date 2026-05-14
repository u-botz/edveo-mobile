import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingQueue = [];

  AuthInterceptor(this._dio);

  // ─── Attach headers to every outgoing request ───────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    final slug = await TokenStorage.getTenantSlug();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (slug != null) {
      options.headers['X-Tenant-Slug'] = slug;
    }

    handler.next(options);
  }

  // ─── Handle 401 — attempt one refresh then retry ────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Do not retry refresh endpoint — avoids infinite loop
    if (statusCode == 401 && path != '/api/tenant/auth/refresh') {
      if (_isRefreshing) {
        // Queue the request until refresh completes
        _pendingQueue.add(_PendingRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      final newToken = await _attemptRefresh();

      if (newToken != null) {
        // Retry the original failed request with new token
        _isRefreshing = false;
        _retryPending(newToken);
        handler.resolve(await _retry(err.requestOptions, newToken));
      } else {
        // Refresh failed — clear session and propagate error
        _isRefreshing = false;
        _rejectPending(err);
        await TokenStorage.clearSession();
        _redirectToLogin();
        handler.next(err);
      }

      return;
    }

    handler.next(err);
  }

  // ─── Attempt token refresh ───────────────────────────────────────────────
  Future<String?> _attemptRefresh() async {
    try {
      final expiredToken = await TokenStorage.getAccessToken();
      final slug = await TokenStorage.getTenantSlug();

      if (expiredToken == null || slug == null) return null;

      final response = await _dio.post(
        '/api/tenant/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $expiredToken',
            'X-Tenant-Slug': slug,
            // Skip interceptor on this call to avoid recursion
            'X-Skip-Interceptor': 'true',
          },
        ),
      );

      final newToken =
          response.data['data']['access_token'] as String?;

      if (newToken != null) {
        await TokenStorage.updateToken(newToken);
      }

      return newToken;
    } catch (_) {
      return null;
    }
  }

  // ─── Retry original request with new token ───────────────────────────────
  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String newToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $newToken';
    return _dio.fetch(options);
  }

  // ─── Flush pending queue after successful refresh ────────────────────────
  void _retryPending(String newToken) {
    for (final pending in _pendingQueue) {
      pending.options.headers['Authorization'] = 'Bearer $newToken';
      _dio.fetch(pending.options).then(
            (response) => pending.handler.resolve(response),
            onError: (e) => pending.handler.next(e as DioException),
          );
    }
    _pendingQueue.clear();
  }

  // ─── Reject pending queue after failed refresh ───────────────────────────
  void _rejectPending(DioException err) {
    for (final pending in _pendingQueue) {
      pending.handler.next(err);
    }
    _pendingQueue.clear();
  }

  // ─── Navigate to login ───────────────────────────────────────────────────
  // Replace this with your GoRouter navigation once router is set up
  void _redirectToLogin() {
    // TODO: AppRouter.router.go('/login');
  }
}

// ─── Internal model for queued requests ─────────────────────────────────────
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.options, this.handler);
}
