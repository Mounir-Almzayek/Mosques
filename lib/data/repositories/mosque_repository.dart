import 'dart:async';

import '../../core/cache/cache.dart';
import '../../core/enums/app_language.dart';
import '../datasources/mosque_remote_data_source.dart';
import '../models/mosque/mosque_bootstrap.dart';
import 'interfaces/mosque_repository_interface.dart';

/// Backend-native mosque repository. Reads return [MosqueBootstrap] from
/// [MosqueRemoteDataSource]; writes route each sub-object to its dedicated
/// endpoint. The cache-first layer is unchanged — only the model type differs.
class MosqueRepository implements IMosqueRepository {
  final MosqueRemoteDataSource _dataSource;
  final String? Function() _getActiveMosqueId;
  final Future<void> Function(String) _syncActiveMosque;
  final JsonCache<MosqueBootstrap> _cache;
  final CacheFirstLoader<MosqueBootstrap> _loader;

  /// Last bootstrap observed, used to diff announcement/alert lists on write.
  MosqueBootstrap? _latest;
  final StreamController<MosqueBootstrap?> _manualRefreshController =
      StreamController<MosqueBootstrap?>.broadcast();

  MosqueRepository({
    required MosqueRemoteDataSource dataSource,
    required String? Function() getActiveMosqueId,
    required Future<void> Function(String) syncActiveMosque,
    required JsonCache<MosqueBootstrap> cache,
    ImageSyncService? imageSync,
  }) : _dataSource = dataSource,
       _getActiveMosqueId = getActiveMosqueId,
       _syncActiveMosque = syncActiveMosque,
       _cache = cache,
       _loader = CacheFirstLoader<MosqueBootstrap>(
         cache,
         onValue: imageSync?.syncMosque,
       );

  String? get _activeId {
    final id = _getActiveMosqueId();
    return (id == null || id.isEmpty) ? null : id;
  }

  String _requireActiveId() {
    final id = _activeId;
    if (id == null) throw Exception('No active mosque');
    return id;
  }

  @override
  Stream<MosqueBootstrap?> get streamActiveMosque =>
      _loader.stream(remote: _remoteStream);

  Stream<MosqueBootstrap?> _remoteStream() {
    final id = _activeId;
    if (id == null) return Stream.value(null);
    final controller = StreamController<MosqueBootstrap?>();
    StreamSubscription<MosqueBootstrap?>? bootstrapSub;
    StreamSubscription<MosqueBootstrap?>? refreshSub;

    controller.onListen = () {
      bootstrapSub = _dataSource
          .watchBootstrap(id)
          .listen(
            (b) {
              if (b != null) _latest = b;
              if (!controller.isClosed) controller.add(b);
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) controller.addError(error, stackTrace);
            },
          );
      refreshSub = _manualRefreshController.stream.listen((b) {
        if (b != null) _latest = b;
        if (!controller.isClosed) controller.add(b);
      });
    };
    controller.onCancel = () async {
      await bootstrapSub?.cancel();
      await refreshSub?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<MosqueBootstrap?> getActiveMosque() async {
    final uid = _activeId;
    if (uid != null) await _syncActiveMosque(uid);
    return _loader
        .once(
          remote: () async {
            final id = _activeId;
            if (id == null) return null;
            final b = await _dataSource.fetchBootstrap(id);
            if (b != null) _latest = b;
            return b;
          },
        )
        .last;
  }

  @override
  Future<MosqueBootstrap?> fetchActiveMosqueFromServer() async {
    final uid = _activeId;
    if (uid != null) await _syncActiveMosque(uid);
    if (uid == null) return null;
    final b = await _dataSource.fetchBootstrap(uid);
    if (b == null) return null;
    _latest = b;
    await _cache.save(b);
    _manualRefreshController.add(b);
    return b;
  }

  @override
  Future<PrayerSettingsPreview> previewPrayerSettings(MosqueBootstrap mosque) {
    return _dataSource.previewPrayerSettings(
      _requireActiveId(),
      mosque.prayerSettings,
    );
  }

  @override
  Future<void> updateMosque(MosqueBootstrap mosque) async {
    final id = _requireActiveId();
    final m = mosque.mosque;
    await _dataSource.patchMosque(id, {
      'name': m.name,
      'city': m.city,
      if (m.countryCode != null) 'countryCode': m.countryCode,
      if (m.administrativeDivisionId != null)
        'administrativeDivisionId': m.administrativeDivisionId,
      'latitude': double.tryParse(m.latitude) ?? 0,
      'longitude': double.tryParse(m.longitude) ?? 0,
      'timezone': m.timezone,
      'languageCode': m.languageCode,
      'defaultRiwayahCode': m.defaultRiwayahCode,
    });
  }

  @override
  Future<void> updateDesignSettings(MosqueBootstrap mosque) async {
    await _dataSource.putDisplaySettings(
      _requireActiveId(),
      mosque.displaySettings,
    );
  }

  @override
  Future<MosqueBootstrap> uploadAlbumImage(String filePath) async {
    final displaySettings = await _dataSource.uploadAlbumImage(
      _requireActiveId(),
      filePath,
    );
    final current = _latest ?? await getActiveMosque();
    if (current == null) {
      throw Exception('No active mosque');
    }
    final updated = current.copyWith(displaySettings: displaySettings);
    _latest = updated;
    await _cache.save(updated);
    _manualRefreshController.add(updated);
    return updated;
  }

  @override
  Future<void> updateLanguageCode(AppLanguage language) async {
    await _dataSource.patchMosque(_requireActiveId(), {
      'languageCode': language.code,
    });
  }

  @override
  Future<void> updateIqamaSettings(MosqueBootstrap mosque) async {
    await _dataSource.putPrayerSettings(
      _requireActiveId(),
      mosque.prayerSettings,
    );
  }

  @override
  Future<void> updateMosqueTextList(
    MosqueBootstrap mosque,
    MosqueTextListKind kind,
  ) async {
    await _dataSource.putReligiousContent(_requireActiveId(), mosque.content);
  }

  @override
  Future<void> updateAnnouncements(MosqueBootstrap mosque) async {
    await _dataSource.reconcileAnnouncements(
      _requireActiveId(),
      announcementType: 'announcement',
      previous: _latest?.ads ?? const [],
      next: mosque.ads,
    );
  }

  @override
  Future<void> updateActiveAlerts(MosqueBootstrap mosque) async {
    await _dataSource.reconcileAnnouncements(
      _requireActiveId(),
      announcementType: 'alert',
      previous: _latest?.savedAlerts ?? const [],
      next: mosque.savedAlerts,
    );
  }
}
