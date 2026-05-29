import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../models/mosque/announcement_model.dart';
import '../models/platform_announcements/settings_announcement_model.dart';
import 'interfaces/platform_announcements_repository_interface.dart';

/// Platform-wide announcements (all mosques) managed externally.
class PlatformAnnouncementsRepository
    implements IPlatformAnnouncementsRepository {
  final FirebaseFirestore? _firestore;
  final JsonCache<List<AnnouncementModel>> _displayCache;
  final CacheFirstLoader<List<AnnouncementModel>> _displayLoader;
  final CacheFirstLoader<List<SettingsAnnouncementModel>>? _settingsLoader;
  final Stream<List<AnnouncementModel>?> Function()? _displayRemoteOverride;

  PlatformAnnouncementsRepository({
    required FirebaseFirestore firestore,
    required JsonCache<List<AnnouncementModel>> displayCache,
    required JsonCache<List<SettingsAnnouncementModel>> settingsCache,
  })  : _firestore = firestore,
        _displayCache = displayCache,
        _displayLoader = CacheFirstLoader(displayCache),
        _settingsLoader = CacheFirstLoader(settingsCache),
        _displayRemoteOverride = null;

  PlatformAnnouncementsRepository.forTest({
    required JsonCache<List<AnnouncementModel>> displayCache,
    Stream<List<AnnouncementModel>?> Function()? displayRemote,
  })  : _firestore = null,
        _displayCache = displayCache,
        _displayLoader = CacheFirstLoader(displayCache),
        _settingsLoader = null,
        _displayRemoteOverride = displayRemote;

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

  Stream<List<AnnouncementModel>?> _displayFirestoreStream() {
    return _firestore!
        .collection(FirestoreSchema.platformAnnouncementsCollection)
        .snapshots()
        .map((snap) {
          final now = DateTime.now();
          final list = snap.docs
              .where(
                (d) => d.id != FirestoreSchema.settingsAnnouncementsDocId,
              )
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) => _isInWindow(a, now))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          return list;
        });
  }

  Stream<List<SettingsAnnouncementModel>?> _settingsFirestoreStream() {
    final docRef = _firestore!
        .collection(FirestoreSchema.platformAnnouncementsCollection)
        .doc(FirestoreSchema.settingsAnnouncementsDocId);

    return docRef.snapshots().map((doc) => _settingsListFromData(doc.data()));
  }

  @override
  Stream<List<AnnouncementModel>> watchActiveForDisplay() =>
      _displayLoader
          .stream(
            remote: _displayRemoteOverride ?? _displayFirestoreStream,
          )
          .map((v) => v ?? const <AnnouncementModel>[]);

  @override
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements() =>
      _settingsLoader!
          .stream(remote: _settingsFirestoreStream)
          .map((v) => v ?? const <SettingsAnnouncementModel>[]);

  @override
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer() async {
    try {
      final snap = await _firestore!
          .collection(FirestoreSchema.platformAnnouncementsCollection)
          .get(const GetOptions(source: Source.server));
      final now = DateTime.now();
      final list = snap.docs
          .where((d) => d.id != FirestoreSchema.settingsAnnouncementsDocId)
          .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
          .where((a) => _isInWindow(a, now))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      await _displayCache.save(list);
      return list;
    } catch (_) {
      return (await _displayCache.read())?.value ?? const [];
    }
  }
}
