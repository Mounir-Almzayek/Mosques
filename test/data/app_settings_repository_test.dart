import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/app/app_settings_model.dart';
import 'package:Tebyan/data/repositories/app_settings_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;
import '../support/fake_realtime_transport.dart';

void main() {
  test('streamAppSettings emits cached value before remote', () async {
    final store = FakeCacheStore();
    final cache = JsonCache<AppSettingsModel>(
      store: store,
      cacheKey: 'app_settings',
      toJson: (s) => s.toMap(),
      fromJson: AppSettingsModel.fromMap,
    );
    await cache.save(const AppSettingsModel(backgroundLibraryUrls: ['https://x/a.png']));

    final repo = AppSettingsRepository(
      transport: FakeRealtimeTransport(),
      cache: cache,
    );

    final first = await repo.streamAppSettings.first;
    expect(first!.backgroundLibraryUrls, ['https://x/a.png']);
  });
}
