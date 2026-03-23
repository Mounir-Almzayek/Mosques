import 'app_exception.dart';

/// Error Helper
/// Utility functions for error handling
class ErrorHelper {
  /// Extract error message from various error types
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else if (error is String) {
      return error;
    }
    return 'An unexpected error occurred';
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    final message = getErrorMessage(error).toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket');
  }
}
