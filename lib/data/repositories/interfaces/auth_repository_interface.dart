import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/enums/app_mode.dart';

abstract class IAuthRepository {
  User? get currentUser;
  String? getActiveMosqueId();

  Future<UserCredential> login(String email, String password);
  Future<void> saveFcmToken(String token);
  Future<void> logout();
  Future<void> updatePassword(String newPassword);
  Future<void> updatePhone(String newPhone);
  Future<String?> getPhone();
  AppMode? getAppModeOverride();
  Future<void> setAppModeOverride(AppMode mode);
}
