import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/enums/app_mode.dart';
import '../../../core/enums/registration_type.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/design_settings_model.dart';
import '../../../data/models/mosque_model.dart';
import '../../../data/repositories/mosque_local_repository.dart';
import 'user_active_mosque_repository.dart';

class AuthRepository {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _appModeKey = 'app_mode_override';

  static User? get currentUser => _auth.currentUser;

  /// تسجيل مستخدم جديد مع خيار إنشاء جامع أو الانضمام لموجود.
  static Future<void> register({
    required String email,
    required String password,
    required String phone,
    String? mosqueId,
    required RegistrationType type,
  }) async {
    UserCredential? credential;
    try {
      // 1. إنشاء حساب في Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. إنشاء مستند المستخدم في Firestore
      final userMap = {
        'email': email,
        'phone': phone,
        'created_at': FieldValue.serverTimestamp(),
        'active_mosque_id': type.isNew ? mosqueId : null,
      };
      await _firestore.collection('users').doc(uid).set(userMap);

      // 3. إذا كان المطلوب جامع جديد، نقوم بإنشائه بشكل ذري وآمن
      if (type.isNew && mosqueId != null) {
        await _createMosque(mosqueId, email);
        await UserActiveMosqueRepository.syncBestEffort(uid);
      }
    } catch (e) {
      final uid = credential?.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).delete().catchError((_) {});
      }
      await credential?.user?.delete().catchError((_) {});
      rethrow;
    }
  }

  /// التحقق المباشر من التوفر قد يفشل لغير المسجلين بسبب قواعد Firestore.
  /// نعيد `true` عند رفض القراءة، ويكون التحقق الحقيقي داخل [_createMosque].
  static Future<bool> isMosqueIdAvailable(String mosqueId) async {
    try {
      final doc = await _firestore.collection('mosques').doc(mosqueId).get();
      return !doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return true;
      rethrow;
    }
  }

  /// إنشاء مستند الجامع الجديد بالإعدادات الافتراضية.
  static Future<void> _createMosque(String mosqueId, String adminEmail) async {
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
    final ref = _firestore.collection('mosques').doc(mosqueId);
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        throw Exception('mosque_id_taken');
      }
      tx.set(ref, {
        ...defaultMosque.toMap(),
        'admin_email': adminEmail,
        'created_at': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Sign in with email and password
  static Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await UserActiveMosqueRepository.syncBestEffort(credential.user?.uid);
    return credential;
  }

  /// حفظ FCM token الحالي للمستخدم لاستخدامه لاحقاً في الإشعارات.
  static Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null || token.trim().isEmpty) return;

    await _firestore.collection('users').doc(user.uid).set({
      'fcm_token': token,
      'fcm_tokens': FieldValue.arrayUnion([token]),
      'fcm_token_updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Sign out
  static Future<void> logout() async {
    await _auth.signOut();
    await UserActiveMosqueRepository.clearLocalCache();
    await MosqueLocalRepository.clearCache();
  }

  /// Update user password
  static Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// Update user phone in Firestore
  static Future<void> updatePhone(String newPhone) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {'phone': newPhone},
        SetOptions(merge: true),
      );
    }
  }

  /// Get user phone from Firestore
  static Future<String?> getPhone() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['phone'] as String?;
    }
    return null;
  }

  /// آخر مسجد نشط محفوظ محلياً (ويتم تحديثه من السيرفر عند توفر الشبكة).
  static String? getActiveMosqueId() {
    return UserActiveMosqueRepository.getCachedActiveMosqueId();
  }

  /// جلب وضع التشغيل المحفوظ محلياً (إعدادات أم شاشة عرض).
  static AppMode? getAppModeOverride() {
    final value = StorageService.getString(_appModeKey);
    if (value == null || value.isEmpty) return null;
    return AppMode.fromString(value);
  }

  /// حفظ وضع التشغيل المختار ليكون دائماً عند الفتح القادم.
  static Future<void> setAppModeOverride(AppMode mode) async {
    await StorageService.setString(_appModeKey, mode.name);
  }
}
