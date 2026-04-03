import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/hive_service.dart';
import '../models/app/app_settings_model.dart';

class AppSettingsLocalRepository {
  AppSettingsLocalRepository._();

  static const String _cacheKey = 'app_settings_cache_v1';

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

  static Future<void> saveSettings(AppSettingsModel p) async {
    final raw = p.toMap();
    final storable = _sanitizeForHive(raw) as Map<String, dynamic>;
    await HiveService.saveData(_cacheKey, storable);
  }

  static Future<AppSettingsModel?> getCached() async {
    final raw = await HiveService.getData(_cacheKey);
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);
    try {
      return AppSettingsModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    await HiveService.deleteData(_cacheKey);
  }
}
