import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../../core/realtime/realtime_transport.dart';
import '../../core/realtime/remote_document.dart';
import '../models/mosque/announcement_model.dart';
import '../models/platform_announcements/settings_announcement_model.dart';
import 'interfaces/platform_announcements_repository_interface.dart';

/// Platform-wide announcements (all mosques) managed externally.
class PlatformAnnouncementsRepository
    implements IPlatformAnnouncementsRepository {
  final RealtimeTransport _transport;
  final JsonCache<List<AnnouncementModel>> _displayCache;
  final CacheFirstLoader<List<AnnouncementModel>> _displayLoader;
  final CacheFirstLoader<List<SettingsAnnouncementModel>> _settingsLoader;

  PlatformAnnouncementsRepository({
    required RealtimeTransport transport,
    required JsonCache<List<AnnouncementModel>> displayCache,
    required JsonCache<List<SettingsAnnouncementModel>> settingsCache,
  })  : _transport = transport,
        _displayCache = displayCache,
        _displayLoader = CacheFirstLoader(displayCache),
        _settingsLoader = CacheFirstLoader(settingsCache);

  bool _isInWindow(AnnouncementModel a, DateTime now) {
    return a.isActive && !a.startDate.isAfter(now) && a.endDate.isAfter(now);
  }

  List<SettingsAnnouncementModel> _settingsListFromData(
    Map<String, dynamic>? data,
  ) {
    final rawItems =
        data?[FirestoreSchema.items] ?? data?['list'] ?? data?['announcements'];
    final rawList = rawItems is List ? rawItems : const [];
    final now = DateTime.now();

    return rawList
        .asMap()
        .entries
        .where((entry) => entry.value is Map)
        .map((entry) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          return SettingsAnnouncementModel.fromMap(
            map,
            'settings_${entry.key}',
          );
        })
        .where((item) => item.isVisibleAt(now))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<AnnouncementModel> _displayListFromDocs(
    List<RemoteDocument> docs,
    DateTime now,
  ) {
    return docs
        .where((d) => d.id != FirestoreSchema.settingsAnnouncementsDocId)
        .map((d) => AnnouncementModel.fromMap(d.data, d.id))
        .where((a) => _isInWindow(a, now))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Stream<List<AnnouncementModel>?> _displayRemoteStream() {
    return _transport
        .watchCollection(FirestoreSchema.platformAnnouncementsCollection)
        .map((docs) => _displayListFromDocs(docs, DateTime.now()));
  }

  Stream<List<SettingsAnnouncementModel>?> _settingsRemoteStream() {
    return _transport
        .watchDocument(
          FirestoreSchema.platformAnnouncementsCollection,
          FirestoreSchema.settingsAnnouncementsDocId,
        )
        .map((doc) => _settingsListFromData(doc?.data));
  }

  @override
  Stream<List<AnnouncementModel>> watchActiveForDisplay() =>
      _displayLoader.stream(remote: _displayRemoteStream).map((v) {
        // Re-apply the time window on every emission so cached lists
        // (filtered at save time) never surface expired announcements.
        final now = DateTime.now();
        return (v ?? const <AnnouncementModel>[])
            .where((a) => _isInWindow(a, now))
            .toList();
      });

  @override
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements() =>
      _settingsLoader.stream(remote: _settingsRemoteStream).map((v) {
        final now = DateTime.now();
        return (v ?? const <SettingsAnnouncementModel>[])
            .where((a) => a.isVisibleAt(now))
            .toList();
      });

  @override
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer() async {
    try {
      final docs = await _transport.getCollection(
        FirestoreSchema.platformAnnouncementsCollection,
        serverOnly: true,
      );
      final list = _displayListFromDocs(docs, DateTime.now());
      await _displayCache.save(list);
      return list;
    } catch (_) {
      return (await _displayCache.read())?.value ?? const [];
    }
  }
}
