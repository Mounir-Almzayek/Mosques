import '../l10n/generated/l10n.dart';
import 'api_exception.dart';

/// Maps any thrown error into a user-ready, localized message.
///
/// This is the single place errors become human text. BLoCs call it in their
/// catch blocks instead of `error.toString()`, so the UI never shows a raw
/// `ApiException(...)` string. Uses [S.current] — no [BuildContext] needed.
String errorMessage(Object? error) {
  final s = S.current;
  if (error is ApiException) {
    return switch (error.code) {
      'network_error' => s.error_network,
      'unauthenticated' || 'token_expired' => s.error_session_expired,
      'permission_denied' => s.error_permission_denied,
      // Validation errors carry the specific field problem in `message`.
      'validation_error' => error.message,
      'malformed_response' => s.error_occurred,
      _ => error.message.isNotEmpty ? error.message : s.error_occurred,
    };
  }
  return s.error_occurred;
}
