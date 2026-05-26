import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_schema.dart';
import '../models/mosque/announcement_model.dart';
import 'interfaces/platform_announcements_repository_interface.dart';
import 'platform_announcements_local_repository.dart';

/// Platform-wide announcements (all mosques) managed externally.
class PlatformAnnouncementsRepository
    implements IPlatformAnnouncementsRepository {
  final FirebaseFirestore _firestore;

  PlatformAnnouncementsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  bool _isInWindow(AnnouncementModel a, DateTime now) {
    return a.isActive &&
        !a.startDate.isAfter(now) &&
        a.endDate.isAfter(now);
  }

  @override
  Stream<List<AnnouncementModel>> watchActiveForDisplay() {
    return _firestore
        .collection(FirestoreSchema.platformAnnouncementsCollection)
        .snapshots()
        .asyncMap((snap) async {
      final now = DateTime.now();
      final list = snap.docs
          .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
          .where((a) => _isInWindow(a, now))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      await PlatformAnnouncementsLocalRepository.saveAnnouncements(list);
      return list;
    }).handleError((_) async {
      return await PlatformAnnouncementsLocalRepository.getCached() ?? [];
    });
  }

  @override
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer() async {
    try {
      final snap = await _firestore
          .collection(FirestoreSchema.platformAnnouncementsCollection)
          .get(const GetOptions(source: Source.server));
      final now = DateTime.now();
      final list = snap.docs
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
