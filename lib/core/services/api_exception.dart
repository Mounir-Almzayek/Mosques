/// Unified backend error.
///
/// Built from the backend's error envelope:
/// ```
/// { "success": false, "error": { "code", "message", "details", "requestId" } }
/// ```
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final String? requestId;
  final Object? cause;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
    this.requestId,
    this.cause,
  });

  /// Mapped from Dio's network / timeout failures.
  factory ApiException.network(Object cause) => ApiException(
        code: 'network_error',
        message: 'Network unavailable. Please check your connection.',
        cause: cause,
      );

  /// Backend reachable but returned a non-2xx without an envelope (rare).
  factory ApiException.malformed(int? status, Object? cause) => ApiException(
        code: 'malformed_response',
        message: 'Unexpected response from server.',
        statusCode: status,
        cause: cause,
      );

  bool get isAuthError =>
      code == 'unauthenticated' ||
      code == 'token_expired' ||
      statusCode == 401;

  bool get isPermissionDenied =>
      code == 'permission_denied' || statusCode == 403;

  @override
  String toString() =>
      'ApiException($code${statusCode != null ? ' [$statusCode]' : ''}): $message';
}
