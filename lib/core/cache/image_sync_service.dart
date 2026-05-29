import '../../data/models/app/app_settings_model.dart';
import '../../data/models/mosque/mosque_model.dart';
import 'offline_image_store.dart';

/// Keeps [OfflineImageStore] in sync with the image URLs referenced by the
/// app's data. After each data update, referenced images are downloaded (if
/// absent) and orphaned images are pruned.
///
/// Mosque images and app-settings background-library images are tracked as
/// separate categories; pruning always targets the UNION of both so a sync of
/// one category never deletes the other's images.
class ImageSyncService {
  final OfflineImageStore _store;
  Set<String> _mosqueUrls = {};
  Set<String> _appSettingsUrls = {};

  ImageSyncService(this._store);

  static bool _isHttp(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  /// Low-level: download every http URL in [urls] (deduped) and prune to
  /// exactly that set. Used directly when a single authoritative URL list is
  /// known; category tracking is bypassed.
  Future<void> syncUrls(List<String> urls) async {
    final keep = urls.where(_isHttp).toSet();
    await _downloadAll(keep);
    await _pruneSafely(keep);
  }

  Future<void> syncMosque(MosqueModel mosque) async {
    _mosqueUrls = <String>[
      ...mosque.albumImageUrls,
      if (mosque.publishedAlbumImageUrl != null) mosque.publishedAlbumImageUrl!,
      mosque.designSettings.background.value,
    ].where(_isHttp).toSet();
    await _syncTracked();
  }

  Future<void> syncAppSettings(AppSettingsModel settings) async {
    _appSettingsUrls = settings.backgroundLibraryUrls.where(_isHttp).toSet();
    await _syncTracked();
  }

  Future<void> _syncTracked() async {
    final keep = {..._mosqueUrls, ..._appSettingsUrls};
    await _downloadAll(keep);
    await _pruneSafely(keep);
  }

  Future<void> _downloadAll(Set<String> urls) async {
    for (final url in urls) {
      try {
        await _store.fetchAndStore(url);
      } catch (_) {
        // best-effort; image will load over network later
      }
    }
  }

  Future<void> _pruneSafely(Set<String> keep) async {
    try {
      await _store.prune(keep);
    } catch (_) {}
  }
}
