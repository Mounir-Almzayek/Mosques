import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../models/app/app_settings_model.dart';
import 'interfaces/app_settings_repository_interface.dart';

class AppSettingsRepository implements IAppSettingsRepository {
  final FirebaseFirestore? _firestore;
  final CacheFirstLoader<AppSettingsModel> _loader;
  final Stream<AppSettingsModel?> Function()? _remoteStreamOverride;

  AppSettingsRepository({
    required FirebaseFirestore firestore,
    required JsonCache<AppSettingsModel> cache,
    ImageSyncService? imageSync,
  })  : _firestore = firestore,
        _remoteStreamOverride = null,
        _loader = CacheFirstLoader<AppSettingsModel>(
          cache,
          onValue: imageSync?.syncAppSettings,
        );

  AppSettingsRepository.forTest({
    required JsonCache<AppSettingsModel> cache,
    Stream<AppSettingsModel?> Function()? remoteStream,
  })  : _firestore = null,
        _remoteStreamOverride = remoteStream,
        _loader = CacheFirstLoader<AppSettingsModel>(cache);

  Stream<AppSettingsModel?> _firestoreStream() {
    return _firestore!
        .collection(FirestoreSchema.appSettingsCollection)
        .doc(FirestoreSchema.globalDocId)
        .snapshots()
        .map((doc) => (!doc.exists || doc.data() == null)
            ? null
            : AppSettingsModel.fromMap(doc.data()!));
  }

  @override
  Stream<AppSettingsModel?> get streamAppSettings =>
      _loader.stream(remote: _remoteStreamOverride ?? _firestoreStream);

  @override
  Future<AppSettingsModel?> getAppSettings() {
    return _loader.once(remote: () async {
      final doc = await _firestore!
          .collection(FirestoreSchema.appSettingsCollection)
          .doc(FirestoreSchema.globalDocId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return AppSettingsModel.fromMap(doc.data()!);
    }).last;
  }
}
