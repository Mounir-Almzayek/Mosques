import '../../../core/services/storage_service.dart';

class AuthLocalRepository {
  static const String _tokenKey = 'refresh_token';

  /// Retrieve saved token
  static String retrieveToken() {
    String? tokenValue = StorageService.getString(_tokenKey);
    return tokenValue ?? "";
  }

  /// Save token to local storage
  static Future<void> saveToken(String token) async {
    await StorageService.setString(_tokenKey, token);
  }

  /// Clear authentication-related data
  static void clearAuthData() {
    StorageService.remove(_tokenKey);
  }
}
