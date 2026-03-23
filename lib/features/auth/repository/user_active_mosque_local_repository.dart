import '../../../core/services/storage_service.dart';

/// تخزين محلي لـ `active_mosque_id` — يبقى بعد إغلاق التطبيق ويعمل بدون شبكة.
class UserActiveMosqueLocalRepository {
  UserActiveMosqueLocalRepository._();

  static const String activeMosqueIdKey = 'active_mosque_id';

  static String? getCachedActiveMosqueId() {
    return StorageService.getString(activeMosqueIdKey);
  }

  static Future<void> saveActiveMosqueId(String id) async {
    await StorageService.setString(activeMosqueIdKey, id);
  }

  static Future<void> clearActiveMosqueId() async {
    await StorageService.remove(activeMosqueIdKey);
  }
}
