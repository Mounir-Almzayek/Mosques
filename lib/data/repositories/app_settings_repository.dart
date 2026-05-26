import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_schema.dart';
import '../models/app/app_settings_model.dart';
import 'app_settings_local_repository.dart';
import 'interfaces/app_settings_repository_interface.dart';

class AppSettingsRepository implements IAppSettingsRepository {
  final FirebaseFirestore _firestore;

  AppSettingsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<AppSettingsModel?> getAppSettings() async {
    try {
      final doc = await _firestore
          .collection(FirestoreSchema.appSettingsCollection)
          .doc(FirestoreSchema.globalDocId)
          .get();
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

  @override
  Stream<AppSettingsModel?> get streamAppSettings {
    return _firestore
        .collection(FirestoreSchema.appSettingsCollection)
        .doc(FirestoreSchema.globalDocId)
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
