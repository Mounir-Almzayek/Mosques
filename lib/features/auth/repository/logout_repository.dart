import '../../../core/enums/network/api_request_enums.dart';
import '../../../data/network/api_request.dart';
import '../models/logout_response.dart';

/// Logout Repository
/// Handles logout API calls
class LogoutRepository {
  /// Logout from the application
  ///
  /// Returns: LogoutResponse containing logout response
  static Future<LogoutResponse> logout() async {
    final apiRequest = APIRequest(
      path: '/auth/me/logout',
      method: HTTPMethod.get,
      authorizationOption: AuthorizationOption.authorized,
    );
    final response = await apiRequest.send();
    return LogoutResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
