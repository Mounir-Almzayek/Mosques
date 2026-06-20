import 'storage_service.dart';

/// Tracks the last known `syncRevision` per mosque so the display WebSocket
/// can send `lastSyncRevision` in its hello frame and skip the initial
/// snapshot when nothing changed.
abstract final class SyncRevisionStore {
  SyncRevisionStore._();

  static String _key(String mosqueIdOrSlug) =>
      'sync_revision.$mosqueIdOrSlug';

  static int? read(String mosqueIdOrSlug) {
    final raw = StorageService.getString(_key(mosqueIdOrSlug));
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  static Future<void> write(String mosqueIdOrSlug, int revision) async {
    await StorageService.setString(_key(mosqueIdOrSlug), revision.toString());
  }

  static Future<void> clear(String mosqueIdOrSlug) async {
    await StorageService.remove(_key(mosqueIdOrSlug));
  }
}
