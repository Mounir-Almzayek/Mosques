import 'user_active_mosque_local_repository.dart';

/// Bridges the local active-mosque cache with optional remote sync.
///
/// With the new backend, `users/me` already exposes `activeMosqueId` and the
/// login response includes it as well — so syncing from the server is no
/// longer something we have to do here. We keep the API surface so callers
/// (splash bloc, language bloc) still compile.
class UserActiveMosqueRepository {
  UserActiveMosqueRepository._();

  /// Local-only read. Returns null when no mosque is selected.
  static String? getCachedActiveMosqueId() =>
      UserActiveMosqueLocalRepository.getCachedActiveMosqueId();

  /// No-op in the new backend: the active mosque id arrives via login /
  /// `GET /mobile/me`. The signature is kept so existing call sites compile.
  static Future<void> syncBestEffort(String? uid) async {
    return;
  }

  static Future<void> clearLocalCache() =>
      UserActiveMosqueLocalRepository.clearActiveMosqueId();
}
