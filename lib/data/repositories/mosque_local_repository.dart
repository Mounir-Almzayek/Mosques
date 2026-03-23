import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/hive_service.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../models/mosque_model.dart';

/// تخزين آخر نسخة معروفة من بيانات المسجد النشط في Hive (بدون Timestamp).
/// يعمل مع [UserActiveMosqueRepository] و [AsyncRunner.offlineTask].
class MosqueLocalRepository {
  MosqueLocalRepository._();

  static const String _cacheKey = 'active_mosque_cache_v1';

  static dynamic _sanitizeForHive(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is Map) {
      final m = <String, dynamic>{};
      value.forEach((k, v) {
        m[k.toString()] = _sanitizeForHive(v);
      });
      return m;
    }
    if (value is List) {
      return value.map(_sanitizeForHive).toList();
    }
    return value;
  }

  static Future<void> saveMosque(MosqueModel m) async {
    final raw = <String, dynamic>{
      'id': m.id,
      ...m.toMap(),
    };
    final storable = _sanitizeForHive(raw) as Map<String, dynamic>;
    await HiveService.saveData(_cacheKey, storable);
  }

  /// يعيد النسخة المحفوظة فقط إذا طابقت [AuthRepository.getActiveMosqueId].
  static Future<MosqueModel?> getCachedForActiveMosque() async {
    final activeId = AuthRepository.getActiveMosqueId();
    if (activeId == null || activeId.isEmpty) return null;

    final raw = await HiveService.getData(_cacheKey);
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);
    final cachedId = map['id']?.toString();
    if (cachedId == null || cachedId != activeId) return null;

    try {
      return MosqueModel.fromMap(map, cachedId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    await HiveService.deleteData(_cacheKey);
  }
}
