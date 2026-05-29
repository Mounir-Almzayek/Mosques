import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/offline_image_store.dart';

class FakeDownloader implements ImageDownloader {
  final List<String> calls = [];
  bool throwOnDownload = false;
  @override
  Future<Uint8List> download(String url) async {
    calls.add(url);
    if (throwOnDownload) throw Exception('network');
    return Uint8List.fromList(url.codeUnits);
  }
}

void main() {
  late Directory tempDir;
  late FakeDownloader downloader;
  late OfflineImageStore store;
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('img_store_test');
    downloader = FakeDownloader();
    store = OfflineImageStore(downloader: downloader, baseDirOverride: tempDir);
    await store.init();
  });
  tearDown(() async => tempDir.delete(recursive: true));
  test('fileFor returns null before download', () async {
    expect(await store.fileFor('https://x/a.png'), isNull);
  });
  test('fetchAndStore persists the file and fileFor finds it', () async {
    final f = await store.fetchAndStore('https://x/a.png');
    expect(await f.exists(), isTrue);
    final found = await store.fileFor('https://x/a.png');
    expect(found, isNotNull);
    expect(found!.path, f.path);
  });
  test('fetchAndStore is idempotent (no re-download if present)', () async {
    await store.fetchAndStore('https://x/a.png');
    await store.fetchAndStore('https://x/a.png');
    expect(downloader.calls.length, 1);
  });
  test('prune deletes files whose url is not in keep set', () async {
    await store.fetchAndStore('https://x/a.png');
    await store.fetchAndStore('https://x/b.png');
    await store.prune({'https://x/a.png'});
    expect(await store.fileFor('https://x/a.png'), isNotNull);
    expect(await store.fileFor('https://x/b.png'), isNull);
  });
  test('fetchAndStore propagates download errors', () async {
    downloader.throwOnDownload = true;
    expect(() => store.fetchAndStore('https://x/c.png'), throwsException);
  });
  test('clear removes all stored images', () async {
    await store.fetchAndStore('https://x/a.png');
    await store.clear();
    expect(await store.fileFor('https://x/a.png'), isNull);
  });
}
