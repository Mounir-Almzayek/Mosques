import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/mosque/announcement_model.dart';
import 'package:Tebyan/data/models/platform_announcements/settings_announcement_model.dart';
import 'package:Tebyan/data/repositories/platform_announcements_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;
import '../support/fake_realtime_transport.dart';

void main() {
  test('watchActiveForDisplay emits cached list before remote', () async {
    final store = FakeCacheStore();
    final cache = JsonCache<List<AnnouncementModel>>(
      store: store,
      cacheKey: 'announcements',
      toJson: (list) =>
          {'items': list.map((a) => {...a.toMap(), 'id': a.id}).toList()},
      fromJson: (m) => (m['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return AnnouncementModel.fromMap(map, map['id']?.toString() ?? '');
          })
          .toList(),
    );

    final settingsCache = JsonCache<List<SettingsAnnouncementModel>>(
      store: store,
      cacheKey: 'settings_announcements',
      toJson: (list) => {'items': list.map((a) => a.toMap()).toList()},
      fromJson: (m) => (m['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return SettingsAnnouncementModel.fromMap(
                map, map['id']?.toString() ?? '');
          })
          .toList(),
    );

    // Build one minimal valid announcement via fromMap, save it.
    final now = DateTime.now();
    final a = AnnouncementModel.fromMap({
      'title': 'Hello',
      'is_active': true,
      'order': 0,
      'start_date': now.subtract(const Duration(days: 1)),
      'end_date': now.add(const Duration(days: 1)),
    }, 'ann1');
    await cache.save([a]);

    final repo = PlatformAnnouncementsRepository(
      transport: FakeRealtimeTransport(),
      displayCache: cache,
      settingsCache: settingsCache,
    );

    final first = await repo.watchActiveForDisplay().first;
    expect(first.length, 1);
    expect(first.first.id, 'ann1');
  });
}
