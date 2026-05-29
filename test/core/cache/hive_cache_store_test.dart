import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:Tebyan/core/cache/hive_cache_store.dart';

void main() {
  late Directory tempDir;
  late Box box;
  late HiveCacheStore store;
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox('test_box');
    store = HiveCacheStore(box: box);
  });
  tearDown(() async {
    await box.clear();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });
  test('write then read round-trips a plain map', () async {
    await store.write('k', {'a': 1, 'b': 'text'});
    final out = await store.read('k');
    expect(out, {'a': 1, 'b': 'text'});
  });
  test('sanitizes Firestore Timestamp to millisecondsSinceEpoch on write', () async {
    final ts = Timestamp.fromMillisecondsSinceEpoch(1730000000000);
    await store.write('k', {'created': ts, 'nested': {'when': ts}});
    final out = await store.read('k');
    expect(out!['created'], 1730000000000);
    expect((out['nested'] as Map)['when'], 1730000000000);
  });
  test('sanitizes Timestamp inside lists', () async {
    final ts = Timestamp.fromMillisecondsSinceEpoch(42);
    await store.write('k', {'list': [{'t': ts}]});
    final out = await store.read('k');
    expect(((out!['list'] as List).first as Map)['t'], 42);
  });
  test('read returns null for missing key', () async {
    expect(await store.read('absent'), isNull);
  });
  test('delete removes the entry', () async {
    await store.write('k', {'a': 1});
    await store.delete('k');
    expect(await store.read('k'), isNull);
  });
  test('keys lists written keys', () async {
    await store.write('k1', {'a': 1});
    await store.write('k2', {'b': 2});
    final keys = await store.keys();
    expect(keys, containsAll(['k1', 'k2']));
  });
}
