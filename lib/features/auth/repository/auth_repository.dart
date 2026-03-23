import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/storage_service.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import 'user_active_mosque_repository.dart';

class AuthRepository {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _isDisplayModeKey = 'is_display_mode';

  static User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  static Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserActiveMosqueRepository.syncBestEffort(credential.user?.uid);
    return credential;
  }

  /// Sign out
  static Future<void> logout() async {
    await _auth.signOut();
    await UserActiveMosqueRepository.clearLocalCache();
    await MosqueLocalRepository.clearCache();
  }

  /// آخر مسجد نشط محفوظ محلياً (ويتم تحديثه من السيرفر عند توفر الشبكة).
  static String? getActiveMosqueId() {
    return UserActiveMosqueRepository.getCachedActiveMosqueId();
  }

  /// Check if device is manually set as display mode
  static bool? getIsDisplayModeOverride() {
    return StorageService.getBool(_isDisplayModeKey);
  }

  static Future<void> setIsDisplayModeOverride(bool isDisplay) async {
    await StorageService.setBool(_isDisplayModeKey, isDisplay);
  }
}
