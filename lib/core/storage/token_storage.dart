import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccessToken = 'edveo_access_token';
  static const _keyTenantSlug  = 'edveo_tenant_slug';
  static const _keyLastRefresh = 'edveo_last_refresh_at';

  // In-memory cache — avoids a Keychain/Keystore platform-channel round-trip
  // on every outgoing request. Invalidated on write and on clearSession().
  static String? _cachedToken;
  static String? _cachedSlug;

  static Future<void> saveSession({
    required String accessToken,
    required String tenantSlug,
  }) async {
    _cachedToken = accessToken;
    _cachedSlug  = tenantSlug;
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyTenantSlug,  value: tenantSlug),
      _storage.write(
        key: _keyLastRefresh,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  static Future<void> saveTenantSlug(String slug) async {
    _cachedSlug = slug;
    await _storage.write(key: _keyTenantSlug, value: slug);
  }

  static Future<String?> getAccessToken() async {
    _cachedToken ??= await _storage.read(key: _keyAccessToken);
    return _cachedToken;
  }

  static Future<String?> getTenantSlug() async {
    _cachedSlug ??= await _storage.read(key: _keyTenantSlug);
    return _cachedSlug;
  }

  static Future<int?> getLastRefreshAt() async {
    final raw = await _storage.read(key: _keyLastRefresh);
    return raw != null ? int.tryParse(raw) : null;
  }

  static Future<void> updateToken(String accessToken) async {
    _cachedToken = accessToken;
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(
        key: _keyLastRefresh,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  static Future<void> clearSession() async {
    _cachedToken = null;
    _cachedSlug  = null;
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
