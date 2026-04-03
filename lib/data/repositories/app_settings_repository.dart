import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app/app_settings_model.dart';
import 'app_settings_local_repository.dart';

class AppSettingsRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب الإعدادات العامة من كولكشن منفصلة 'app_settings'.
  /// نعيد الكاش المحلي في حال فشل الاتصال.
  static Future<AppSettingsModel?> getAppSettings() async {
    try {
      final doc = await _firestore.collection('app_settings').doc('global').get();
      if (!doc.exists || doc.data() == null) {
        return AppSettingsLocalRepository.getCached();
      }
      final settings = AppSettingsModel.fromMap(doc.data()!);
      await AppSettingsLocalRepository.saveSettings(settings);
      return settings;
    } catch (_) {
      return AppSettingsLocalRepository.getCached();
    }
  }

  /// بث مباشر للإعدادات العامة لمراقبة التحديثات فورياً.
  static Stream<AppSettingsModel?> get streamAppSettings {
    return _firestore
        .collection('app_settings')
        .doc('global')
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists || doc.data() == null) return null;
      final settings = AppSettingsModel.fromMap(doc.data()!);
      await AppSettingsLocalRepository.saveSettings(settings);
      return settings;
    }).handleError((_) async {
      return await AppSettingsLocalRepository.getCached();
    });
  }
}
