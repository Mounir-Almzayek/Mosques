import '../../models/mosque/announcement_model.dart';

abstract class IPlatformAnnouncementsRepository {
  Stream<List<AnnouncementModel>> watchActiveForDisplay();
  Future<List<AnnouncementModel>> fetchActiveForDisplayFromServer();
}
