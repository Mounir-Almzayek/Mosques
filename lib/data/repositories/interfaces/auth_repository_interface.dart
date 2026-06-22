import '../../../core/enums/app_mode.dart';
import '../../../features/auth/models/auth_session.dart';
import '../../../features/auth/models/auth_user.dart';

/// Auth contract — backend-agnostic.
///
/// `AuthUser` replaces `firebase_auth.User`; `AuthSession` replaces
/// `firebase_auth.UserCredential`. Both expose the same fields the rest of
/// the app already reads (`uid`, `email`, …) so the migration touches only
/// the implementation, not the call sites.
abstract class IAuthRepository {
  /// Returns the cached authenticated user, or `null` if no session.
  AuthUser? get currentUser;

  /// Emits the current user on subscribe and on every auth state change.
  Stream<AuthUser?> authStateChanges();

  /// The mosque id the user has selected (cached locally).
  String? getActiveMosqueId();

  Future<AuthUser?> refreshCurrentUser();
  Future<AuthSession> login(String email, String password);
  Future<void> saveFcmToken(String token);
  Future<void> logout();

  /// Legacy single-field password change. Sends an empty `currentPassword`
  /// to the backend, which works only when the user is in a first-login or
  /// reset state.
  Future<void> updatePassword(String newPassword);

  /// Full password change: backend requires both fields. Use this from new
  /// UI; `updatePassword` is kept for backwards compatibility.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updatePhone(String newPhone);
  Future<String?> getPhone();
  AppMode? getAppModeOverride();
  Future<void> setAppModeOverride(AppMode mode);
}
