import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/i_cache_store.dart';
import 'package:Tebyan/core/cache/cache_policy.dart';
import 'package:Tebyan/core/cache/json_cache.dart';

class FakeCacheStore implements ICacheStore {
  final Map<String, Map<String, dynamic>> _data = {};
  @override
  Future<void> write(String key, Map<String, dynamic> json) async => _data[key] = json;
  @override
  Future<Map<String, dynamic>?> read(String key) async => _data[key];
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  Future<List<String>> keys() async => _data.keys.toList();
}

class _Person {
  final String name;
  final int age;
  const _Person(this.name, this.age);
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
  static _Person fromJson(Map<String, dynamic> m) => _Person(m['name'] as String, m['age'] as int);
}

JsonCache<_Person> buildCache(ICacheStore store, {int version = 1}) {
  return JsonCache<_Person>(
    store: store,
    cacheKey: 'person',
    toJson: (p) => p.toJson(),
    fromJson: _Person.fromJson,
    policy: CachePolicy(schemaVersion: version),
  );
}

void main() {
  test('save then read round-trips the model with a timestamp', () async {
    final store = FakeCacheStore();
    final cache = buildCache(store);
    await cache.save(const _Person('Ali', 30));
    final entry = await cache.read();
    expect(entry, isNotNull);
    expect(entry!.value.name, 'Ali');
    expect(entry.value.age, 30);
    expect(entry.cachedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
  });
  test('read returns null when nothing cached', () async {
    final cache = buildCache(FakeCacheStore());
    expect(await cache.read(), isNull);
  });
  test('read returns null when stored schema version is incompatible', () async {
    final store = FakeCacheStore();
    await buildCache(store, version: 1).save(const _Person('Ali', 30));
    final entryV2 = await buildCache(store, version: 2).read();
    expect(entryV2, isNull);
  });
  test('read returns null when decode throws', () async {
    final store = FakeCacheStore();
    await store.write('person', {
      '_schemaVersion': 1,
      '_cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': {'name': 123},
    });
    expect(await buildCache(store).read(), isNull);
  });
  test('clear removes the entry', () async {
    final store = FakeCacheStore();
    final cache = buildCache(store);
    await cache.save(const _Person('Ali', 30));
    await cache.clear();
    expect(await cache.read(), isNull);
  });
}
