/// Unified backend route paths (relative to ApiConfig.baseUrl).
///
/// Covers auth, mobile/me, mosques, and the display WebSocket.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  static const String authLogin = '/mobile/auth/login';
  static const String authRefresh = '/mobile/auth/refresh';
  static const String authLogout = '/mobile/auth/logout';
  static const String authChangePassword = '/mobile/auth/change-password';
  static const String authLogoutOtherSessions =
      '/mobile/auth/logout-other-sessions';

  // ---------------------------------------------------------------------------
  // Me + devices
  // ---------------------------------------------------------------------------
  static const String me = '/mobile/me';
  static const String devicesCurrent = '/mobile/devices/current';

  // ---------------------------------------------------------------------------
  // App bootstrap
  // ---------------------------------------------------------------------------
  static const String appBootstrap = '/mobile/app/bootstrap';

  // ---------------------------------------------------------------------------
  // Administrative divisions
  // ---------------------------------------------------------------------------
  static const String administrativeDivisions =
      '/dashboard/administrative-divisions';
  static String administrativeDivisionPath(String id) =>
      '$administrativeDivisions/$id/path';

  // ---------------------------------------------------------------------------
  // AI recitation
  // ---------------------------------------------------------------------------
  static const String aiSessionRequests = '/mobile/ai/session-requests';
  static String aiSessionEvents(String requestId) =>
      '$aiSessionRequests/$requestId/events';

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------
  static const String notifications = '/mobile/mosques/notifications';
  static const String notificationsUnreadCount =
      '/mobile/mosques/notifications/unread-count';
  static const String notificationsWs = '/mobile/mosques/notifications/ws';
  static String notificationRead(String messageId) =>
      '$notifications/$messageId/read';

  // ---------------------------------------------------------------------------
  // Mosques
  // ---------------------------------------------------------------------------
  static const String mosques = '/mobile/mosques';

  static String mosque(String id) => '$mosques/$id';
  static String mosqueBootstrap(String id) => '$mosques/$id/bootstrap';
  static String mosquePrayerSettings(String id) =>
      '$mosques/$id/prayer-settings';
  static String mosqueDisplaySettings(String id) =>
      '$mosques/$id/display-settings';
  static String mosquePublishedAlbum(String id) =>
      '$mosques/$id/display-settings/published-album';
  static String mosqueReligiousContent(String id) =>
      '$mosques/$id/religious-content';
  static String mosqueAnnouncements(String id) => '$mosques/$id/announcements';
  static String mosqueAnnouncement(String mosqueId, String announcementId) =>
      '$mosques/$mosqueId/announcements/$announcementId';
  static String mosqueAlerts(String id) => '$mosques/$id/alerts';
  static String mosqueAlertCancel(String mosqueId, String alertId) =>
      '$mosques/$mosqueId/alerts/$alertId/cancel';

  // ---------------------------------------------------------------------------
  // Display WebSocket (uses publicSlug, not id)
  // ---------------------------------------------------------------------------
  static String displayWs(String publicSlug) =>
      '/display/mosques/$publicSlug/ws';
  static String displaySnapshot(String publicSlug) =>
      '/display/mosques/$publicSlug/snapshot';

  // ---------------------------------------------------------------------------
  // Hive cache keys (preserved from the previous schema so cached blobs stay
  // valid across the migration).
  // ---------------------------------------------------------------------------
  static const String activeMosqueCacheKey = 'active_mosque_cache_v1';
  static const String appSettingsCacheKey = 'app_settings_cache_v1';
  static const String platformAnnouncementsCacheKey =
      'platform_announcements_cache_v1';
  static const String settingsAnnouncementsCacheKey =
      'settings_announcements_cache_v1';
}
