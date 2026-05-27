/// Centralised Firestore collection names, field names, document IDs,
/// and Hive cache keys.
///
/// Using these constants instead of hardcoded strings eliminates typos and
/// makes rename-refactors a single-line change.
abstract final class FirestoreSchema {
  // ---------------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------------
  static const String mosquesCollection = 'mosques';
  static const String usersCollection = 'users';
  static const String appSettingsCollection = 'app_settings';
  static const String platformAnnouncementsCollection =
      'platform_announcements';

  // ---------------------------------------------------------------------------
  // Document IDs
  // ---------------------------------------------------------------------------
  static const String globalDocId = 'global';

  // ---------------------------------------------------------------------------
  // Mosque fields — basic info
  // ---------------------------------------------------------------------------
  static const String name = 'name';
  static const String city = 'city';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String logoUrl = 'logo_url';
  static const String adminEmail = 'admin_email';

  // ---------------------------------------------------------------------------
  // Mosque fields — settings & content
  // ---------------------------------------------------------------------------
  static const String designSettings = 'design_settings';
  static const String iqamaOffsets = 'iqama_offsets';
  static const String prayerOffsets = 'prayer_offsets';
  static const String calculationMethod = 'calculation_method';
  static const String languageCode = 'language_code';
  static const String appLanguageCode = 'app_language_code';

  // ---------------------------------------------------------------------------
  // Mosque fields — religious text lists
  // ---------------------------------------------------------------------------
  static const String hadiths = 'hadiths';
  static const String verses = 'verses';
  static const String duas = 'duas';
  static const String adhkar = 'adhkar';

  // ---------------------------------------------------------------------------
  // Mosque fields — announcements, alerts, media
  // ---------------------------------------------------------------------------
  static const String mosqueAds = 'mosque_ads';
  static const String activeAlerts = 'active_alerts';
  static const String photoStudioUrls = 'photo_studio_urls';
  static const String backgroundAlbumUrls = 'background_album_urls';

  // ---------------------------------------------------------------------------
  // Design settings fields
  // ---------------------------------------------------------------------------
  static const String prayerCardScale = 'prayer_card_scale';

  // ---------------------------------------------------------------------------
  // App settings fields
  // ---------------------------------------------------------------------------
  static const String backgroundFolderUrl = 'background_folder_url';

  // ---------------------------------------------------------------------------
  // Mosque fields — timestamps
  // ---------------------------------------------------------------------------
  static const String updatedAt = 'updated_at';
  static const String lastSeen = 'last_seen';
  static const String createdAt = 'created_at';

  // ---------------------------------------------------------------------------
  // User fields
  // ---------------------------------------------------------------------------
  static const String email = 'email';
  static const String phone = 'phone';
  static const String activeMosqueId = 'active_mosque_id';
  static const String fcmToken = 'fcm_token';
  static const String fcmTokens = 'fcm_tokens';
  static const String fcmTokenUpdatedAt = 'fcm_token_updated_at';

  // ---------------------------------------------------------------------------
  // Platform announcement fields
  // ---------------------------------------------------------------------------
  static const String isActive = 'is_active';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';

  // ---------------------------------------------------------------------------
  // Hive cache keys
  // ---------------------------------------------------------------------------
  static const String activeMosqueCacheKey = 'active_mosque_cache_v1';
  static const String appSettingsCacheKey = 'app_settings_cache_v1';
  static const String platformAnnouncementsCacheKey =
      'platform_announcements_cache_v1';
}
