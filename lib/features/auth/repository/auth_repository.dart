import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_schema.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/enums/registration_type.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import 'user_active_mosque_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _appModeKey = 'app_mode_override';

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? mosqueId,
    required RegistrationType type,
  }) async {
    UserCredential? credential;
    try {
      // 1. Create Firebase Auth account
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Create user document in Firestore
      final userMap = {
        FirestoreSchema.email: email,
        FirestoreSchema.phone: phone,
        FirestoreSchema.createdAt: FieldValue.serverTimestamp(),
        FirestoreSchema.activeMosqueId: type.isNew ? mosqueId : null,
      };
      await _firestore.collection(FirestoreSchema.usersCollection).doc(uid).set(userMap);

      // 3. If new mosque requested, create it atomically
      if (type.isNew && mosqueId != null) {
        await _createMosque(mosqueId, email);
        await UserActiveMosqueRepository.syncBestEffort(uid);
      }
    } catch (e) {
      final uid = credential?.user?.uid;
      if (uid != null) {
        await _firestore.collection(FirestoreSchema.usersCollection).doc(uid).delete().catchError((_) {});
      }
      await credential?.user?.delete().catchError((_) {});
      rethrow;
    }
  }

  @override
  Future<bool> isMosqueIdAvailable(String mosqueId) async {
    try {
      final doc = await _firestore.collection(FirestoreSchema.mosquesCollection).doc(mosqueId).get();
      return !doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return true;
      rethrow;
    }
  }

  Future<void> _createMosque(String mosqueId, String adminEmail) async {
    final defaultMosque = MosqueModel(
      id: mosqueId,
      name: mosqueId.replaceAll('_', ' ').toUpperCase(),
      city: '',
      latitude: 0,
      longitude: 0,
      prayerCalculationMethod: 'MuslimWorldLeague',
      appLanguageCode: 'ar',
      designSettings: const DesignSettingsModel(),
      iqamaSettings: IqamaSettingsModel.defaultSettings(),
      prayerOffsets: const PrayerOffsetsModel(),
    );
    final ref = _firestore.collection(FirestoreSchema.mosquesCollection).doc(mosqueId);
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        throw Exception('mosque_id_taken');
      }
      tx.set(ref, {
        ...defaultMosque.toMap(),
        FirestoreSchema.adminEmail: adminEmail,
        FirestoreSchema.createdAt: FieldValue.serverTimestamp(),
      });
    });
  }

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

    await _firestore.collection(FirestoreSchema.usersCollection).doc(user.uid).set({
      FirestoreSchema.fcmToken: token,
      FirestoreSchema.fcmTokens: FieldValue.arrayUnion([token]),
      FirestoreSchema.fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await UserActiveMosqueRepository.clearLocalCache();
    await MosqueLocalRepository.clearCache();
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
      await _firestore.collection(FirestoreSchema.usersCollection).doc(user.uid).set(
        {FirestoreSchema.phone: newPhone},
        SetOptions(merge: true),
      );
    }
  }

  @override
  Future<String?> getPhone() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection(FirestoreSchema.usersCollection).doc(user.uid).get();
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
