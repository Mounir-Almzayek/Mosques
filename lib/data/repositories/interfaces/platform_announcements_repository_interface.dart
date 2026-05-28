import '../../models/mosque/announcement_model.dart';
import '../../models/platform_announcements/settings_announcement_model.dart';

abstract class IPlatformAnnouncementsRepository {
  Stream<List<AnnouncementModel>> watchActiveForDisplay();
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements();
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer();
}
