import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement_model.dart';
import 'platform_announcements_local_repository.dart';

/// إعلانات المنصة (كل المساجد) — تُدار من خارج تطبيق الجوال (كونسول، سكربت Admin SDK، لوحة داخلية).
/// نفس شكل حقول [AnnouncementModel] مثل `mosque_ads` داخل المسجد.
class PlatformAnnouncementsRepository {
  PlatformAnnouncementsRepository._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'platform_announcements';

  static bool _isInWindow(AnnouncementModel a, DateTime now) {
    return a.isActive &&
        !a.startDate.isAfter(now) &&
        a.endDate.isAfter(now);
  }

  /// بث مباشر للإعلانات النشطة (حسب التاريخ في العميل — نفس منطق شريط المسجد).
  static Stream<List<AnnouncementModel>> watchActiveForDisplay() {
    return _db
        .collection(_collection)
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

  /// نفس [watchActiveForDisplay] لكن قراءة لمرة واحدة من السيرفر (تجاوز الكاش).
  static Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer() async {
    try {
      final snap = await _db
          .collection(_collection)
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
