import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/offline_image_store.dart';
import 'package:Tebyan/core/cache/image_sync_service.dart';
import 'offline_image_store_test.dart' show FakeDownloader;

void main() {
  late Directory tempDir;
  late FakeDownloader downloader;
  late OfflineImageStore store;
  late ImageSyncService sync;
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('img_sync_test');
    downloader = FakeDownloader();
    store = OfflineImageStore(downloader: downloader, baseDirOverride: tempDir);
    await store.init();
    sync = ImageSyncService(store);
  });
  tearDown(() async => tempDir.delete(recursive: true));
  test('syncUrls downloads all http urls and ignores non-http', () async {
    await sync.syncUrls(['https://x/a.png', 'http://x/b.png', 'default', '', 'preset_blue']);
    expect(await store.fileFor('https://x/a.png'), isNotNull);
    expect(await store.fileFor('http://x/b.png'), isNotNull);
    expect(downloader.calls.length, 2);
  });
  test('syncUrls prunes images no longer referenced', () async {
    await sync.syncUrls(['https://x/a.png', 'https://x/b.png']);
    await sync.syncUrls(['https://x/a.png']);
    expect(await store.fileFor('https://x/a.png'), isNotNull);
    expect(await store.fileFor('https://x/b.png'), isNull);
  });
  test('syncUrls does not throw when a download fails', () async {
    downloader.throwOnDownload = true;
    await sync.syncUrls(['https://x/a.png']);
    expect(await store.fileFor('https://x/a.png'), isNull);
  });
}
