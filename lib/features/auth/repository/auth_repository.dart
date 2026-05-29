import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_schema.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import 'user_active_mosque_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _appModeKey = 'app_mode_override';

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserActiveMosqueRepository.syncBestEffort(credential.user?.uid);
    return credential;
  }

  @override
  Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null || token.trim().isEmpty) return;

    await _firestore
        .collection(FirestoreSchema.usersCollection)
        .doc(user.uid)
        .set({
          FirestoreSchema.fcmToken: token,
          FirestoreSchema.fcmTokens: FieldValue.arrayUnion([token]),
          FirestoreSchema.fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await UserActiveMosqueRepository.clearLocalCache();
    await HiveService.deleteData(FirestoreSchema.activeMosqueCacheKey);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  @override
  Future<void> updatePhone(String newPhone) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection(FirestoreSchema.usersCollection)
          .doc(user.uid)
          .set({FirestoreSchema.phone: newPhone}, SetOptions(merge: true));
    }
  }

  @override
  Future<String?> getPhone() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection(FirestoreSchema.usersCollection)
          .doc(user.uid)
          .get();
      return doc.data()?[FirestoreSchema.phone] as String?;
    }
    return null;
  }

  @override
  String? getActiveMosqueId() {
    return UserActiveMosqueRepository.getCachedActiveMosqueId();
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
}
