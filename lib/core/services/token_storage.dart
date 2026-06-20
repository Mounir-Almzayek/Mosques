import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for backend access/refresh tokens.
///
/// Tokens never go through SharedPreferences. Reads are cached in memory so
/// auth interceptors do not block on platform IPC for every request.
class TokenStorage {
  static const String _accessKey = 'auth.access_token';
  static const String _refreshKey = 'auth.refresh_token';
  static const String _expiresAtKey = 'auth.expires_at';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  String? _accessTokenCache;
  String? _refreshTokenCache;
  DateTime? _expiresAtCache;
  bool _loaded = false;

  /// Loads cached values into memory. Must be awaited at startup.
  Future<void> init() async {
    _accessTokenCache = await _storage.read(key: _accessKey);
    _refreshTokenCache = await _storage.read(key: _refreshKey);
    final raw = await _storage.read(key: _expiresAtKey);
    if (raw != null) {
      _expiresAtCache = DateTime.tryParse(raw);
    }
    _loaded = true;
  }

  bool get isInitialized => _loaded;
  String? get accessToken => _accessTokenCache;
  String? get refreshToken => _refreshTokenCache;
  DateTime? get expiresAt => _expiresAtCache;
  bool get hasSession =>
      (_accessTokenCache != null && _accessTokenCache!.isNotEmpty) ||
      (_refreshTokenCache != null && _refreshTokenCache!.isNotEmpty);

  /// Treats the access token as expired when within [skew] of expiry, so the
  /// refresh runs before an in-flight request can 401.
  bool isAccessTokenExpired({
    Duration skew = const Duration(seconds: 30),
  }) {
    final expires = _expiresAtCache;
    if (expires == null) return false;
    return DateTime.now().isAfter(expires.subtract(skew));
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    int? expiresInSeconds,
  }) async {
    _accessTokenCache = accessToken;
    _refreshTokenCache = refreshToken;
    _expiresAtCache = expiresInSeconds == null
        ? null
        : DateTime.now().add(Duration(seconds: expiresInSeconds));

    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    if (_expiresAtCache != null) {
      await _storage.write(
        key: _expiresAtKey,
        value: _expiresAtCache!.toIso8601String(),
      );
    } else {
      await _storage.delete(key: _expiresAtKey);
    }
  }

  Future<void> updateAccessToken({
    required String accessToken,
    int? expiresInSeconds,
  }) async {
    _accessTokenCache = accessToken;
    _expiresAtCache = expiresInSeconds == null
        ? null
        : DateTime.now().add(Duration(seconds: expiresInSeconds));

    await _storage.write(key: _accessKey, value: accessToken);
    if (_expiresAtCache != null) {
      await _storage.write(
        key: _expiresAtKey,
        value: _expiresAtCache!.toIso8601String(),
      );
    } else {
      await _storage.delete(key: _expiresAtKey);
    }
  }

  Future<void> clear() async {
    _accessTokenCache = null;
    _refreshTokenCache = null;
    _expiresAtCache = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
