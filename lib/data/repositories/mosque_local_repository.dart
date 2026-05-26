import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_schema.dart';
import '../../core/services/hive_service.dart';
import '../../features/auth/repository/user_active_mosque_repository.dart';
import '../models/mosque/mosque_model.dart';

/// Local cache for the active mosque data in Hive (Timestamp-free).
/// Works with [UserActiveMosqueRepository] and offline fallback.
class MosqueLocalRepository {
  MosqueLocalRepository._();

  static const String _cacheKey = FirestoreSchema.activeMosqueCacheKey;

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

  /// Returns the cached mosque only if it matches the locally-stored active mosque ID.
  static Future<MosqueModel?> getCachedForActiveMosque() async {
    final activeId = UserActiveMosqueRepository.getCachedActiveMosqueId();
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
