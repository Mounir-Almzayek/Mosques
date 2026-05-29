import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/mosque/announcement_model.dart';
import 'package:Tebyan/data/repositories/platform_announcements_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;

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
            final conv = <String, dynamic>{};
            map.forEach((k, v) {
              conv[k] =
                  (k == 'start_date' || k == 'end_date' || k == 'created_at') &&
                          v is int
                      ? Timestamp.fromMillisecondsSinceEpoch(v)
                      : v;
            });
            return AnnouncementModel.fromMap(conv, conv['id']?.toString() ?? '');
          })
          .toList(),
    );

    // Build one minimal valid announcement via fromMap, save it.
    final now = DateTime.now();
    final a = AnnouncementModel.fromMap({
      'title': 'Hello',
      'is_active': true,
      'order': 0,
      'start_date': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'end_date': Timestamp.fromDate(now.add(const Duration(days: 1))),
    }, 'ann1');
    await cache.save([a]);

    final repo = PlatformAnnouncementsRepository.forTest(
      displayCache: cache,
      displayRemote: () => const Stream<List<AnnouncementModel>?>.empty(),
    );

    final first = await repo.watchActiveForDisplay().first;
    expect(first.length, 1);
    expect(first.first.id, 'ann1');
  });
}
