import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/config/firebase_user_bootstrap.dart';
import 'user_active_mosque_local_repository.dart';
import 'user_active_mosque_remote_repository.dart';

/// ينسخ بين السيرفر والمحلي: يفضّل الإنترنت لتحديث الكاش، وإلا يبقى الـ local كما هو.
class UserActiveMosqueRepository {
  UserActiveMosqueRepository._();

  /// قراءة فقط من المخزن المحلي (مناسب عند عدم وجود شبكة أو قبل أي محاولة سيرفر).
  static String? getCachedActiveMosqueId() =>
      UserActiveMosqueLocalRepository.getCachedActiveMosqueId();

  /// مزامنة من السيرفر إلى المحلي عند توفر الشبكة. لا يمسح الـ cache عند فشل الشبكة.
  static Future<void> syncFromRemoteToLocal(String uid) async {
    final id = await UserActiveMosqueRemoteRepository.fetchActiveMosqueId(uid);
    if (id != null) {
      await UserActiveMosqueLocalRepository.saveActiveMosqueId(id);
    }
  }

  /// أفضل سلوك: إن كان متصلاً يحدّث من Firestore؛ وإلا يفترض أن [getCachedActiveMosqueId] كافٍ.
  /// جلسة Firebase تبقى عادة بعد إعادة فتح التطبيق — [uid] من `FirebaseAuth.instance.currentUser`.
  ///
  /// إن بقي بدون مسجد: يحاول [FirebaseUserBootstrap] إذا عرّفت `DEFAULT_ACTIVE_MOSQUE_ID`.
  static Future<void> syncBestEffort(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    try {
      final result = await Connectivity().checkConnectivity();
      final offline = result.contains(ConnectivityResult.none);
      if (!offline) {
        await syncFromRemoteToLocal(uid);
      }
      if (getCachedActiveMosqueId() != null) return;
      if (FirebaseUserBootstrap.hasDefaultMosqueId) {
        await _bootstrapUserWithDefaultMosque(
          uid,
          FirebaseUserBootstrap.defaultActiveMosqueId,
        );
      }
    } catch (_) {
      // أخطاء الشبكة أو Firestore: الإبقاء على القيمة المحفوظة محلياً
    }
  }

  /// Fallback when `users/{uid}` has no `active_mosque_id` (e.g. old accounts).
  static Future<void> _bootstrapUserWithDefaultMosque(
    String uid,
    String defaultMosqueId,
  ) async {
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(uid);
      final snap = await ref.get();
      final existing = snap.data()?['active_mosque_id'];
      if (existing is String && existing.isNotEmpty) {
        await UserActiveMosqueLocalRepository.saveActiveMosqueId(existing);
        return;
      }
      await ref.set(
        {
          'active_mosque_id': defaultMosqueId,
          'profile_bootstrapped_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await UserActiveMosqueLocalRepository.saveActiveMosqueId(defaultMosqueId);
    } catch (_) {}
  }

  static Future<void> clearLocalCache() =>
      UserActiveMosqueLocalRepository.clearActiveMosqueId();
}
