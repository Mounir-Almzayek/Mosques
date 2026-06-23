import '../../../core/enums/app_language.dart';
import '../../models/mosque/mosque_bootstrap.dart';

/// Mosque data access, in terms of the backend-native [MosqueBootstrap]
/// aggregate. Writes take the full bootstrap and the repository routes the
/// relevant sub-object to its dedicated backend endpoint.
abstract class IMosqueRepository {
  Stream<MosqueBootstrap?> get streamActiveMosque;
  Future<MosqueBootstrap?> getActiveMosque();
  Future<MosqueBootstrap?> fetchActiveMosqueFromServer();
  Future<PrayerSettingsPreview> previewPrayerSettings(MosqueBootstrap mosque);

  /// Top-level mosque profile (name/city/lat/long/languageCode/…).
  Future<void> updateMosque(MosqueBootstrap mosque);
  Future<void> updateDesignSettings(MosqueBootstrap mosque);
  Future<MosqueBootstrap> uploadAlbumImage(String filePath);
  Future<void> updateLanguageCode(AppLanguage language);
  Future<void> updateIqamaSettings(MosqueBootstrap mosque);
  Future<void> updateMosqueTextList(
    MosqueBootstrap mosque,
    MosqueTextListKind kind,
  );
  Future<void> updateAnnouncements(MosqueBootstrap mosque);
  Future<void> updateActiveAlerts(MosqueBootstrap mosque);
}
