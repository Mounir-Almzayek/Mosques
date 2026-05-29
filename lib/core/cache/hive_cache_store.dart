import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';
import 'i_cache_store.dart';

/// Hive-backed [ICacheStore].
///
/// This is the SINGLE place that converts non-Hive-storable values
/// (Firestore [Timestamp], [DateTime]) into primitives. Repositories no
/// longer duplicate `_sanitizeForHive`.
class HiveCacheStore implements ICacheStore {
  final Box? _injectedBox;
  HiveCacheStore({Box? box}) : _injectedBox = box;
  static dynamic _sanitize(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is Map) {
      final m = <String, dynamic>{};
      value.forEach((k, v) => m[k.toString()] = _sanitize(v));
      return m;
    }
    if (value is List) return value.map(_sanitize).toList();
    return value;
  }
  @override
  Future<void> write(String key, Map<String, dynamic> json) async {
    final storable = _sanitize(json) as Map<String, dynamic>;
    if (_injectedBox != null) {
      await _injectedBox.put(key, storable);
    } else {
      await HiveService.saveData(key, storable);
    }
  }
  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final raw = _injectedBox != null ? _injectedBox.get(key) : await HiveService.getData(key);
    if (raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }
  @override
  Future<void> delete(String key) async {
    if (_injectedBox != null) {
      await _injectedBox.delete(key);
    } else {
      await HiveService.deleteData(key);
    }
  }
  @override
  Future<List<String>> keys() async {
    if (_injectedBox != null) {
      return _injectedBox.keys.map((e) => e.toString()).toList();
    }
    return HiveService.getDefaultBoxKeys();
  }
}
