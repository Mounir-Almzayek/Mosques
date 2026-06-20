import '../../models/mosque/announcement.dart';
import '../../models/platform_announcements/settings_announcement_model.dart';

abstract class IPlatformAnnouncementsRepository {
  Stream<List<Announcement>> watchActiveForDisplay();
  Stream<List<SettingsAnnouncementModel>> watchSettingsAnnouncements();
  Future<List<Announcement>> fetchActiveForDisplayFromServer();
}
