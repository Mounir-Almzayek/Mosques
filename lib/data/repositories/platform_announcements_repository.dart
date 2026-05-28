import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_schema.dart';
import '../models/mosque/announcement_model.dart';
import '../models/platform_announcements/settings_announcement_model.dart';
import 'interfaces/platform_announcements_repository_interface.dart';
import 'platform_announcements_local_repository.dart';

/// Platform-wide announcements (all mosques) managed externally.
class PlatformAnnouncementsRepository
    implements IPlatformAnnouncementsRepository {
  final FirebaseFirestore _firestore;

  PlatformAnnouncementsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  bool _isInWindow(AnnouncementModel a, DateTime now) {
    return a.isActive && !a.startDate.isAfter(now) && a.endDate.isAfter(now);
  }

  @override
  Stream<List<AnnouncementModel>> watchActiveForDisplay() {
    return _firestore
        .collection(FirestoreSchema.platformAnnouncementsCollection)
        .snapshots()
        .asyncMap((snap) async {
          final now = DateTime.now();
          final list =
              snap.docs
                  .where(
                    (d) => d.id != FirestoreSchema.settingsAnnouncementsDocId,
                  )
                  .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
                  .where((a) => _isInWindow(a, now))
                  .toList()
                ..sort((a, b) => a.order.compareTo(b.order));

          await PlatformAnnouncementsLocalRepository.saveAnnouncements(list);
          return list;
        })
        .handleError((_) async {
          return await PlatformAnnouncementsLocalRepository.getCached() ?? [];
        });
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

  @override
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements() {
    final docRef = _firestore
        .collection(FirestoreSchema.platformAnnouncementsCollection)
        .doc(FirestoreSchema.settingsAnnouncementsDocId);

    return Stream<List<SettingsAnnouncementModel>>.multi((controller) {
      final sub = docRef.snapshots().listen(
        (doc) async {
          final list = _settingsListFromData(doc.data());
          if (list.isNotEmpty) {
            await PlatformAnnouncementsLocalRepository.saveSettingsAnnouncements(
              list,
            );
          }
          if (!controller.isClosed) {
            controller.add(
              list.isNotEmpty
                  ? list
                  : await PlatformAnnouncementsLocalRepository.getCachedSettingsAnnouncements() ??
                        [],
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) async {
          if (!controller.isClosed) {
            controller.add(
              await PlatformAnnouncementsLocalRepository.getCachedSettingsAnnouncements() ??
                  [],
            );
          }
        },
      );

      controller.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer() async {
    try {
      final snap = await _firestore
          .collection(FirestoreSchema.platformAnnouncementsCollection)
          .get(const GetOptions(source: Source.server));
      final now = DateTime.now();
      final list =
          snap.docs
              .where((d) => d.id != FirestoreSchema.settingsAnnouncementsDocId)
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) => _isInWindow(a, now))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      await PlatformAnnouncementsLocalRepository.saveAnnouncements(list);
      return list;
    } catch (_) {
      return await PlatformAnnouncementsLocalRepository.getCached() ?? [];
    }
  }
}
