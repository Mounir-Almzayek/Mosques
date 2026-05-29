import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../../core/realtime/realtime_transport.dart';
import '../models/app/app_settings_model.dart';
import 'interfaces/app_settings_repository_interface.dart';

class AppSettingsRepository implements IAppSettingsRepository {
  final RealtimeTransport _transport;
  final CacheFirstLoader<AppSettingsModel> _loader;

  AppSettingsRepository({
    required RealtimeTransport transport,
    required JsonCache<AppSettingsModel> cache,
    ImageSyncService? imageSync,
  })  : _transport = transport,
        _loader = CacheFirstLoader<AppSettingsModel>(
          cache,
          onValue: imageSync?.syncAppSettings,
        );

  Stream<AppSettingsModel?> _remoteStream() {
    return _transport
        .watchDocument(
          FirestoreSchema.appSettingsCollection,
          FirestoreSchema.globalDocId,
        )
        .map((doc) => doc == null ? null : AppSettingsModel.fromMap(doc.data));
  }

  @override
  Stream<AppSettingsModel?> get streamAppSettings =>
      _loader.stream(remote: _remoteStream);

  @override
  Future<AppSettingsModel?> getAppSettings() {
    return _loader.once(remote: () async {
      final doc = await _transport.getDocument(
        FirestoreSchema.appSettingsCollection,
        FirestoreSchema.globalDocId,
      );
      return doc == null ? null : AppSettingsModel.fromMap(doc.data);
    }).last;
  }
}
