import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/enums/app_mode.dart';
import '../../../core/enums/registration_type.dart';

abstract class IAuthRepository {
  User? get currentUser;
  String? getActiveMosqueId();

  Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? mosqueId,
    required RegistrationType type,
  });

  Future<bool> isMosqueIdAvailable(String mosqueId);
  Future<UserCredential> login(String email, String password);
  Future<void> saveFcmToken(String token);
  Future<void> logout();
  Future<void> updatePassword(String newPassword);
  Future<void> updatePhone(String newPhone);
  Future<String?> getPhone();
  AppMode? getAppModeOverride();
  Future<void> setAppModeOverride(AppMode mode);
}
