import 'dart:async';
import 'dart:convert';

import '../../core/constants/api_endpoints.dart';
import '../../core/enums/app_mode.dart';
import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/push_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/token_storage.dart';
import 'interfaces/auth_repository_interface.dart';
import '../../features/auth/models/auth_session.dart';
import '../../features/auth/models/auth_user.dart';
import 'user_active_mosque_local_repository.dart';
import 'user_active_mosque_repository.dart';

/// Backend-backed implementation of [IAuthRepository].
///
/// Holds the current user in memory and broadcasts updates so blocs that
/// used to subscribe to `FirebaseAuth.authStateChanges()` keep working.
class AuthRepository implements IAuthRepository {
  final ApiService _api;
  final TokenStorage _tokens;

  static const String _appModeKey = 'app_mode_override';
  static const String _userCacheKey = 'auth_user_cache_v1';

  AuthUser? _currentUser;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  AuthRepository({
    required ApiService api,
    required TokenStorage tokens,
  })  : _api = api,
        _tokens = tokens {
    _restoreCachedUser();
    // When the API decides the session is gone, drop the cached user.
    _api.onSessionExpired = () {
      _setCurrentUser(null);
      UserActiveMosqueLocalRepository.clearActiveMosqueId();
    };
  }

  // ---------------------------------------------------------------------------
  // Cached user
  // ---------------------------------------------------------------------------

  void _restoreCachedUser() {
    final raw = StorageService.getString(_userCacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        _currentUser = AuthUser.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Bad cache: clear it and move on.
      StorageService.remove(_userCacheKey);
    }
  }

  void _setCurrentUser(AuthUser? user) {
    _currentUser = user;
    if (user == null) {
      StorageService.remove(_userCacheKey);
    } else {
      StorageService.setString(_userCacheKey, json.encode(user.toJson()));
    }
    if (!_authStateController.isClosed) {
      _authStateController.add(user);
    }
  }

  // ---------------------------------------------------------------------------
  // IAuthRepository
  // ---------------------------------------------------------------------------

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  @override
  String? getActiveMosqueId() {
    final fromUser = _currentUser?.activeMosqueId;
    if (fromUser != null && fromUser.isNotEmpty) return fromUser;
    return UserActiveMosqueLocalRepository.getCachedActiveMosqueId();
  }

  @override
  Future<AuthSession> login(String email, String password) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };

    // Best-effort: include the FCM device payload so the backend can register
    // the device in one round-trip.
    final pushToken = PushService.fcmToken;
    if (pushToken != null && pushToken.isNotEmpty) {
      body['device'] = PushDeviceRegistration(
        deviceKind: _platformDeviceKind(),
        notificationProvider: 'fcm',
        pushToken: pushToken,
        clientInfo: const {},
      ).toJson();
    }

    final data = await _api.post(ApiEndpoints.authLogin, body: body);
    final session = AuthSession.fromJson(data);

    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresInSeconds: session.expiresInSeconds,
    );

    _setCurrentUser(session.user);

    // Persist active mosque id for the offline cache used at startup.
    final activeMosqueId = session.user.activeMosqueId ??
        (session.activeMosque?['id']?.toString());
    if (activeMosqueId != null && activeMosqueId.isNotEmpty) {
      await UserActiveMosqueLocalRepository.saveActiveMosqueId(activeMosqueId);
    } else {
      await UserActiveMosqueRepository.syncBestEffort(session.user.id);
    }

    return session;
  }

  @override
  Future<void> saveFcmToken(String token) async {
    if (token.trim().isEmpty) return;
    if (_currentUser == null) return;
    try {
      await _api.put(
        ApiEndpoints.devicesCurrent,
        body: PushDeviceRegistration(
          deviceKind: _platformDeviceKind(),
          notificationProvider: 'fcm',
          pushToken: token,
          clientInfo: const {},
        ).toJson(),
      );
    } on ApiException {
      // Token sync is best-effort; swallow.
    }
  }

  @override
  Future<void> logout() async {
    final refresh = _tokens.refreshToken;
    try {
      if (refresh != null && refresh.isNotEmpty) {
        await _api.post(
          ApiEndpoints.authLogout,
          body: {'refreshToken': refresh, 'revokeDevice': false},
        );
      }
    } catch (_) {
      // Continue with local cleanup even if the call fails.
    }
    await _tokens.clear();
    _setCurrentUser(null);
    await UserActiveMosqueRepository.clearLocalCache();
    await HiveService.deleteData(ApiEndpoints.activeMosqueCacheKey);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    // The backend's change-password route requires the current password too.
    // The legacy ProfileBloc only passes the new value, so we forward an
    // empty current password — accepted only when the user is in a
    // first-login state. Prefer [changePassword] from new UI.
    await changePassword(
      currentPassword: '',
      newPassword: newPassword,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = await _api.post(
      ApiEndpoints.authChangePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    // Backend returns a fresh token pair after a successful change.
    final access = data['accessToken']?.toString();
    final refresh = data['refreshToken']?.toString();
    final expires = (data['expiresInSeconds'] as num?)?.toInt();
    if (access != null && access.isNotEmpty) {
      if (refresh != null && refresh.isNotEmpty) {
        await _tokens.save(
          accessToken: access,
          refreshToken: refresh,
          expiresInSeconds: expires,
        );
      } else {
        await _tokens.updateAccessToken(
          accessToken: access,
          expiresInSeconds: expires,
        );
      }
    }
    // Clear the first-login flag locally so the UI doesn't gate on it.
    if (_currentUser?.passwordChangeRequired == true) {
      _setCurrentUser(
        _currentUser!.copyWith(passwordChangeRequired: false),
      );
    }
  }

  @override
  Future<void> updatePhone(String newPhone) async {
    if (_currentUser == null) return;
    final data = await _api.patch(
      ApiEndpoints.me,
      body: {'phone': newPhone},
    );
    final updatedUserJson = (data['user'] as Map?)?.cast<String, dynamic>();
    if (updatedUserJson != null) {
      _setCurrentUser(AuthUser.fromJson(updatedUserJson));
    } else {
      _setCurrentUser(_currentUser!.copyWith(phone: newPhone));
    }
  }

  @override
  Future<String?> getPhone() async {
    if (_currentUser?.phone != null) return _currentUser!.phone;
    try {
      final data = await _api.get(ApiEndpoints.me);
      final userJson = (data['user'] as Map?)?.cast<String, dynamic>();
      if (userJson != null) {
        final u = AuthUser.fromJson(userJson);
        _setCurrentUser(u);
        return u.phone;
      }
    } on ApiException {
      // ignore: best-effort
    }
    return null;
  }

  @override
  AppMode? getAppModeOverride() {
    final value = StorageService.getString(_appModeKey);
    if (value == null || value.isEmpty) return null;
    return AppMode.fromString(value);
  }

  @override
  Future<void> setAppModeOverride(AppMode mode) async {
    await StorageService.setString(_appModeKey, mode.name);
  }

  /// Releases the broadcast controller. The singleton lives for the app
  /// lifetime so this is rarely needed outside of tests.
  Future<void> dispose() async {
    await _authStateController.close();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _platformDeviceKind() {
    // Mirrors PushService.resolveDeviceKind logic; duplicated here to avoid
    // a Platform import in this file.
    try {
      final token = PushService.fcmToken;
      return (token != null && token.isNotEmpty) ? 'android' : 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
}
