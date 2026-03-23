import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/user_active_mosque_repository.dart';
import '../models/mosque_model.dart';
import 'mosque_local_repository.dart';
import '../../core/enums/app_language.dart';

class MosqueRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current user's active mosque ID
  static String? get _activeMosqueId => AuthRepository.getActiveMosqueId();

  /// Reference to the active mosque document
  static DocumentReference? get _mosqueRef {
    final id = _activeMosqueId;
    if (id == null || id.isEmpty) return null;
    return _firestore.collection('mosques').doc(id);
  }

  /// Get the active mosque data
  static Future<MosqueModel?> getActiveMosque() async {
    final uid = AuthRepository.currentUser?.uid;
    if (uid != null) {
      await UserActiveMosqueRepository.syncBestEffort(uid);
    }

    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) {
        return MosqueLocalRepository.getCachedForActiveMosque();
      }

      final mosque =
          MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    } catch (_) {
      return MosqueLocalRepository.getCachedForActiveMosque();
    }
  }

  /// جلب مستند المسجد من السيرفر مباشرة (تجاوز الكاش) — مثلاً للمزامنة الدورية على شاشة العرض.
  static Future<MosqueModel?> fetchActiveMosqueFromServer() async {
    final uid = AuthRepository.currentUser?.uid;
    if (uid != null) {
      await UserActiveMosqueRepository.syncBestEffort(uid);
    }

    final ref = _mosqueRef;
    if (ref == null) return null;

    try {
      final doc = await ref.get(const GetOptions(source: Source.server));
      if (!doc.exists || doc.data() == null) return null;
      final mosque =
          MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    } catch (_) {
      return null;
    }
  }

  /// Update the entire mosque document
  static Future<void> updateMosque(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    final data = mosque.toMap();
    data['updated_at'] = FieldValue.serverTimestamp();
    data['last_seen'] = FieldValue.serverTimestamp();
    // Drop legacy logo URL (no longer using Firebase Storage for logos)
    data['logo_url'] = FieldValue.delete();
    await ref.set(data, SetOptions(merge: true));
  }

  /// Update just the design settings
  static Future<void> updateDesignSettings(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      'design_settings': mosque.designSettings.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// Update just the app language for the active mosque document.
  static Future<void> updateLanguageCode(AppLanguage language) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      'language_code': language.code,
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// Update just the iqama settings
  static Future<void> updateIqamaSettings(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      'iqama_offsets': mosque.iqamaSettings.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// تحديث قائمة نصوص واحدة (أحاديث، آيات، أدعية، أذكار).
  static Future<void> updateMosqueTextList(MosqueModel mosque, MosqueTextListKind kind) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    final field = switch (kind) {
      MosqueTextListKind.hadith => 'hadiths',
      MosqueTextListKind.verse => 'verses',
      MosqueTextListKind.dua => 'duas',
      MosqueTextListKind.adhkar => 'adhkar',
    };
    final list = mosque.listByKind(kind).map((e) => e.toMap()).toList();

    await ref.update({
      field: list,
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// Update just the announcements list
  static Future<void> updateAnnouncements(MosqueModel mosque) async {
    final ref = _mosqueRef;
    if (ref == null) throw Exception('No active mosque');

    await ref.update({
      'mosque_ads': mosque.announcements.map((a) => a.toMap()).toList(),
      'updated_at': FieldValue.serverTimestamp(),
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// Update last seen timestamp (useful for display screens)
  static Future<void> updateLastSeen() async {
    final ref = _mosqueRef;
    if (ref == null) return;

    await ref.update({
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  /// Stream to listen to real-time changes
  static Stream<MosqueModel?> get streamActiveMosque {
    final ref = _mosqueRef;
    if (ref == null) return Stream.value(null);

    return ref.snapshots().asyncMap((doc) async {
      if (!doc.exists || doc.data() == null) return null;
      final mosque =
          MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      await MosqueLocalRepository.saveMosque(mosque);
      return mosque;
    });
  }
}
