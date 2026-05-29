import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/cache_first_loader.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'json_cache_test.dart' show FakeCacheStore;

class _Box {
  final int n;
  const _Box(this.n);
  Map<String, dynamic> toJson() => {'n': n};
  static _Box fromJson(Map<String, dynamic> m) => _Box(m['n'] as int);
}

JsonCache<_Box> buildBoxCache(FakeCacheStore store) => JsonCache<_Box>(
      store: store,
      cacheKey: 'box',
      toJson: (b) => b.toJson(),
      fromJson: _Box.fromJson,
    );

void main() {
  test('stream emits cached value first, then live values, persisting each', () async {
    final store = FakeCacheStore();
    final cache = buildBoxCache(store);
    await cache.save(const _Box(1));
    final loader = CacheFirstLoader<_Box>(cache);
    final emitted = <int?>[];
    final sub = loader
        .stream(remote: () => Stream.fromIterable([const _Box(2), const _Box(3)]))
        .listen((b) => emitted.add(b?.n));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emitted.first, 1);
    expect(emitted, containsAllInOrder([1, 2, 3]));
    final cached = await cache.read();
    expect(cached!.value.n, 3);
  });

  test('stream with no cache emits only live values', () async {
    final store = FakeCacheStore();
    final loader = CacheFirstLoader<_Box>(buildBoxCache(store));
    final emitted = <int?>[];
    final sub = loader
        .stream(remote: () => Stream.fromIterable([const _Box(9)]))
        .listen((b) => emitted.add(b?.n));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emitted, [9]);
  });

  test('once emits cache immediately then refreshed value', () async {
    final store = FakeCacheStore();
    final cache = buildBoxCache(store);
    await cache.save(const _Box(5));
    final loader = CacheFirstLoader<_Box>(cache);
    final emitted = <int?>[];
    final sub = loader
        .once(remote: () async => const _Box(7))
        .listen((b) => emitted.add(b?.n));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emitted, containsAllInOrder([5, 7]));
    expect((await cache.read())!.value.n, 7);
  });
}
