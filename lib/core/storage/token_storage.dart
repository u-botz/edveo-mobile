import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccessToken = 'edveo_access_token';
  static const _keyTenantSlug  = 'edveo_tenant_slug';
  static const _keyLastRefresh = 'edveo_last_refresh_at';

  static Future<void> saveSession({
    required String accessToken,
    required String tenantSlug,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyTenantSlug,  value: tenantSlug),
      _storage.write(
        key: _keyLastRefresh,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<String?> getTenantSlug() =>
      _storage.read(key: _keyTenantSlug);

  static Future<int?> getLastRefreshAt() async {
    final raw = await _storage.read(key: _keyLastRefresh);
    return raw != null ? int.tryParse(raw) : null;
  }

  static Future<void> updateToken(String accessToken) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(
        key: _keyLastRefresh,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyTenantSlug),
      _storage.delete(key: _keyLastRefresh),
    ]);
  }

  static Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
