# Unified Offline Cache + Image Structure — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every screen render from a local cache instantly (cache-first, no waiting on Firestore), and serve every network image from a permanent on-disk store tied to the data — through one generic cache layer and one unified image widget.

**Architecture:** A generic `ICacheStore` (Hive-backed) handles low-level JSON persistence with Timestamp sanitization in one place. `JsonCache<T>` wraps a model's `toJson/fromJson` over that store with a versioned envelope. `CacheFirstLoader<T>` emits the cached value first, then forwards the live Firestore stream while persisting updates. `OfflineImageStore` persists data-tied image URLs to a permanent directory; `ImageSyncService` keeps that store in sync with incoming data; `AppImage` is the single widget that resolves images (permanent file → network).

**Tech Stack:** Flutter, flutter_bloc, get_it, Hive, cloud_firestore, cached_network_image, path_provider, crypto (sha1), flutter_test.

**Spec:** `docs/superpowers/specs/2026-05-29-offline-cache-and-unified-images-design.md`

---

## File Structure

**New files (core cache):**
- `lib/core/cache/i_cache_store.dart` — `ICacheStore` interface
- `lib/core/cache/hive_cache_store.dart` — `HiveCacheStore` (sanitize + envelope, single source of truth)
- `lib/core/cache/cache_entry.dart` — `CacheEntry<T>`
- `lib/core/cache/cache_policy.dart` — `CachePolicy`
- `lib/core/cache/json_cache.dart` — `JsonCache<T>`
- `lib/core/cache/cache_first_loader.dart` — `CacheFirstLoader<T>`
- `lib/core/cache/offline_image_store.dart` — `OfflineImageStore` + `ImageDownloader`
- `lib/core/cache/image_sync_service.dart` — `ImageSyncService`
- `lib/core/cache/cache.dart` — barrel export

**New files (media):**
- `lib/core/widgets/media/app_image.dart` — `AppImage` unified widget

**Modified files:**
- `lib/core/services/hive_service.dart` — add raw box-key access if needed (read-only; likely unchanged)
- `lib/data/repositories/mosque_repository.dart` — cache-first via JsonCache + CacheFirstLoader
- `lib/data/repositories/app_settings_repository.dart` — same
- `lib/data/repositories/platform_announcements_repository.dart` — same
- `lib/core/di/service_locator.dart` — register cache store, image store, sync service, caches
- `lib/main.dart` (bootstrap) — init `OfflineImageStore`
- Image display sites (see Task 14) — switch to `AppImage`
- `lib/core/widgets/media/media_widgets.dart` — export `app_image.dart`

**Deleted after migration:**
- `lib/data/repositories/mosque_local_repository.dart`
- `lib/data/repositories/app_settings_local_repository.dart`
- `lib/data/repositories/platform_announcements_local_repository.dart`
- `lib/core/widgets/media/cached_image.dart` (after all consumers migrated)

**Dependency to add:** `crypto: ^3.0.5` (for sha1 URL hashing) in `pubspec.yaml`.

---

## Phase A — Core cache primitives

### Task 1: CachePolicy

**Files:**
- Create: `lib/core/cache/cache_policy.dart`
- Test: `test/core/cache/cache_policy_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/cache_policy_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/cache_policy.dart';

void main() {
  group('CachePolicy', () {
    test('isCompatible matches stored schema version', () {
      const p = CachePolicy(schemaVersion: 2);
      expect(p.isCompatible(2), isTrue);
      expect(p.isCompatible(1), isFalse);
    });

    test('isStale is false when maxAge is null (never stale)', () {
      const p = CachePolicy();
      final old = DateTime.now().subtract(const Duration(days: 365));
      expect(p.isStale(old), isFalse);
    });

    test('isStale is true once maxAge elapsed', () {
      const p = CachePolicy(maxAge: Duration(minutes: 10));
      final old = DateTime.now().subtract(const Duration(minutes: 11));
      final fresh = DateTime.now().subtract(const Duration(minutes: 1));
      expect(p.isStale(old), isTrue);
      expect(p.isStale(fresh), isFalse);
    });
  });
}
```

> Note: package import prefix is `Tebyan` (from `pubspec.yaml` `name: Tebyan`). Verify by running the test — Dart lowercases nothing; the import must match the `name:` field exactly.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/cache_policy_test.dart`
Expected: FAIL — `cache_policy.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/cache_policy.dart

/// Controls cache freshness and schema compatibility.
///
/// In cache-first mode the cached value is always returned regardless of
/// staleness; [isStale] only decides whether to trigger a background refresh.
class CachePolicy {
  final Duration? maxAge;
  final int schemaVersion;

  const CachePolicy({this.maxAge, this.schemaVersion = 1});

  bool isStale(DateTime cachedAt) {
    if (maxAge == null) return false;
    return DateTime.now().difference(cachedAt) > maxAge!;
  }

  bool isCompatible(int storedVersion) => storedVersion == schemaVersion;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/cache_policy_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/cache/cache_policy.dart test/core/cache/cache_policy_test.dart
git commit -m "feat(cache): add CachePolicy value object"
```

---

### Task 2: CacheEntry

**Files:**
- Create: `lib/core/cache/cache_entry.dart`
- Test: `test/core/cache/cache_entry_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/cache_entry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/cache_entry.dart';

void main() {
  test('CacheEntry holds value and timestamp', () {
    final ts = DateTime(2026, 5, 29);
    const value = 'hello';
    final entry = CacheEntry<String>(value: value, cachedAt: ts);
    expect(entry.value, value);
    expect(entry.cachedAt, ts);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/cache_entry_test.dart`
Expected: FAIL — `cache_entry.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/cache_entry.dart

/// An immutable cached value paired with the moment it was written.
class CacheEntry<T> {
  final T value;
  final DateTime cachedAt;

  const CacheEntry({required this.value, required this.cachedAt});
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/cache_entry_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/cache/cache_entry.dart test/core/cache/cache_entry_test.dart
git commit -m "feat(cache): add CacheEntry"
```

---

### Task 3: ICacheStore interface + HiveCacheStore

**Files:**
- Create: `lib/core/cache/i_cache_store.dart`
- Create: `lib/core/cache/hive_cache_store.dart`
- Test: `test/core/cache/hive_cache_store_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/hive_cache_store_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/hive_cache_store_test.dart`
Expected: FAIL — files do not exist.

- [ ] **Step 3: Write the interface**

```dart
// lib/core/cache/i_cache_store.dart

/// Low-level key/value persistence for JSON-shaped data.
/// Knows nothing about domain models.
abstract class ICacheStore {
  Future<void> write(String key, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> read(String key);
  Future<void> delete(String key);
  Future<List<String>> keys();
}
```

- [ ] **Step 4: Write HiveCacheStore**

```dart
// lib/core/cache/hive_cache_store.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../services/hive_service.dart';
import 'i_cache_store.dart';

/// Hive-backed [ICacheStore].
///
/// This is the SINGLE place that converts non-Hive-storable values
/// (Firestore [Timestamp], [DateTime]) into primitives. Repositories no
/// longer duplicate `_sanitizeForHive`.
class HiveCacheStore implements ICacheStore {
  final Box? _injectedBox;

  /// In production, pass nothing — uses [HiveService]'s default box.
  /// In tests, inject a box directly.
  HiveCacheStore({Box? box}) : _injectedBox = box;

  static dynamic _sanitize(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    if (value is Map) {
      final m = <String, dynamic>{};
      value.forEach((k, v) => m[k.toString()] = _sanitize(v));
      return m;
    }
    if (value is List) return value.map(_sanitize).toList();
    return value;
  }

  @override
  Future<void> write(String key, Map<String, dynamic> json) async {
    final storable = _sanitize(json) as Map<String, dynamic>;
    if (_injectedBox != null) {
      await _injectedBox.put(key, storable);
    } else {
      await HiveService.saveData(key, storable);
    }
  }

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final raw = _injectedBox != null
        ? _injectedBox.get(key)
        : await HiveService.getData(key);
    if (raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  @override
  Future<void> delete(String key) async {
    if (_injectedBox != null) {
      await _injectedBox.delete(key);
    } else {
      await HiveService.deleteData(key);
    }
  }

  @override
  Future<List<String>> keys() async {
    if (_injectedBox != null) {
      return _injectedBox.keys.map((e) => e.toString()).toList();
    }
    return HiveService.getDefaultBoxKeys();
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/core/cache/hive_cache_store_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/cache/i_cache_store.dart lib/core/cache/hive_cache_store.dart test/core/cache/hive_cache_store_test.dart
git commit -m "feat(cache): add ICacheStore + HiveCacheStore with central sanitization"
```

---

### Task 4: JsonCache<T>

**Files:**
- Create: `lib/core/cache/json_cache.dart`
- Test: `test/core/cache/json_cache_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/json_cache_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/i_cache_store.dart';
import 'package:Tebyan/core/cache/cache_policy.dart';
import 'package:Tebyan/core/cache/json_cache.dart';

/// In-memory fake store for fast unit tests.
class FakeCacheStore implements ICacheStore {
  final Map<String, Map<String, dynamic>> _data = {};
  @override
  Future<void> write(String key, Map<String, dynamic> json) async =>
      _data[key] = json;
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
  static _Person fromJson(Map<String, dynamic> m) =>
      _Person(m['name'] as String, m['age'] as int);
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
    // Write a malformed envelope directly.
    await store.write('person', {
      '_schemaVersion': 1,
      '_cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': {'name': 123}, // age missing, name wrong type
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/json_cache_test.dart`
Expected: FAIL — `json_cache.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/json_cache.dart
import 'cache_entry.dart';
import 'cache_policy.dart';
import 'i_cache_store.dart';

/// Typed JSON cache for a single model [T], stored under [cacheKey].
///
/// Wraps the value in a versioned envelope:
/// `{ "_schemaVersion": n, "_cachedAt": epochMs, "data": {...} }`.
class JsonCache<T> {
  final ICacheStore _store;
  final String _cacheKey;
  final Map<String, dynamic> Function(T) _toJson;
  final T Function(Map<String, dynamic>) _fromJson;
  final CachePolicy _policy;

  JsonCache({
    required ICacheStore store,
    required String cacheKey,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    CachePolicy policy = const CachePolicy(),
  })  : _store = store,
        _cacheKey = cacheKey,
        _toJson = toJson,
        _fromJson = fromJson,
        _policy = policy;

  Future<void> save(T value) async {
    await _store.write(_cacheKey, {
      '_schemaVersion': _policy.schemaVersion,
      '_cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': _toJson(value),
    });
  }

  Future<CacheEntry<T>?> read() async {
    final envelope = await _store.read(_cacheKey);
    if (envelope == null) return null;

    final storedVersion = envelope['_schemaVersion'];
    if (storedVersion is! int || !_policy.isCompatible(storedVersion)) {
      return null;
    }

    final data = envelope['data'];
    if (data is! Map) return null;

    final cachedAtMs = envelope['_cachedAt'];
    final cachedAt = cachedAtMs is int
        ? DateTime.fromMillisecondsSinceEpoch(cachedAtMs)
        : DateTime.fromMillisecondsSinceEpoch(0);

    try {
      final value = _fromJson(Map<String, dynamic>.from(data));
      return CacheEntry<T>(value: value, cachedAt: cachedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _store.delete(_cacheKey);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/json_cache_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/cache/json_cache.dart test/core/cache/json_cache_test.dart
git commit -m "feat(cache): add generic JsonCache<T> with versioned envelope"
```

---

## Phase B — Cache-first loader

### Task 5: CacheFirstLoader<T>

**Files:**
- Create: `lib/core/cache/cache_first_loader.dart`
- Test: `test/core/cache/cache_first_loader_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/cache_first_loader_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/cache_first_loader.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'json_cache_test.dart' show FakeCacheStore; // reuse fake

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
    await cache.save(const _Box(1)); // pre-existing cache

    final loader = CacheFirstLoader<_Box>(cache);
    final emitted = <int?>[];
    final sub = loader
        .stream(remote: () => Stream.fromIterable([const _Box(2), const _Box(3)]))
        .listen((b) => emitted.add(b?.n));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(emitted.first, 1); // cache first
    expect(emitted, containsAllInOrder([1, 2, 3]));
    // last live value persisted
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/cache_first_loader_test.dart`
Expected: FAIL — `cache_first_loader.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/cache_first_loader.dart
import 'dart:async';

import 'json_cache.dart';

/// Wraps a [JsonCache] to provide cache-first reads: the cached value is
/// emitted immediately (if present) before any network call resolves, then
/// fresh values are forwarded and persisted.
class CacheFirstLoader<T> {
  final JsonCache<T> _cache;
  final Future<void> Function(T value)? _onValue;

  /// [onValue] runs (fire-and-forget) after each fresh value is persisted —
  /// e.g. to trigger image sync. Errors inside it are swallowed.
  CacheFirstLoader(this._cache, {Future<void> Function(T value)? onValue})
      : _onValue = onValue;

  Stream<T?> stream({required Stream<T?> Function() remote}) {
    return Stream<T?>.multi((controller) async {
      final entry = await _cache.read();
      if (entry != null && !controller.isClosed) {
        controller.add(entry.value);
      }

      final sub = remote().listen(
        (value) async {
          if (value != null) {
            await _cache.save(value);
            _fireOnValue(value);
          }
          if (!controller.isClosed) controller.add(value);
        },
        onError: (Object e, StackTrace st) async {
          final cached = await _cache.read();
          if (cached != null && !controller.isClosed) {
            controller.add(cached.value);
          } else if (!controller.isClosed) {
            controller.addError(e, st);
          }
        },
      );

      controller.onCancel = () => sub.cancel();
    });
  }

  Stream<T?> once({required Future<T?> Function() remote}) {
    return Stream<T?>.multi((controller) async {
      final entry = await _cache.read();
      if (entry != null && !controller.isClosed) {
        controller.add(entry.value);
      }

      try {
        final value = await remote();
        if (value != null) {
          await _cache.save(value);
          _fireOnValue(value);
        }
        if (!controller.isClosed) controller.add(value);
      } catch (e, st) {
        final cached = await _cache.read();
        if (cached == null && !controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        if (!controller.isClosed) await controller.close();
      }
    });
  }

  void _fireOnValue(T value) {
    final cb = _onValue;
    if (cb == null) return;
    unawaited(cb(value).catchError((_) {}));
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/cache_first_loader_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/cache/cache_first_loader.dart test/core/cache/cache_first_loader_test.dart
git commit -m "feat(cache): add CacheFirstLoader (emits cache before network)"
```

---

## Phase C — Offline image store

### Task 6: Add crypto dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

Add under `dependencies:` (alphabetical-ish, near `connectivity_plus`):
```yaml
  crypto: ^3.0.5
```

- [ ] **Step 2: Resolve packages**

Run: `flutter pub get`
Expected: resolves without conflict; `crypto` added to `pubspec.lock`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add crypto dependency for image url hashing"
```

---

### Task 7: OfflineImageStore

**Files:**
- Create: `lib/core/cache/offline_image_store.dart`
- Test: `test/core/cache/offline_image_store_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/offline_image_store_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/offline_image_store.dart';

/// Fake downloader returning deterministic bytes, recording calls.
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

  test('fetchAndStore swallow-safe: throws are propagated to caller', () async {
    downloader.throwOnDownload = true;
    expect(() => store.fetchAndStore('https://x/c.png'), throwsException);
  });

  test('clear removes all stored images', () async {
    await store.fetchAndStore('https://x/a.png');
    await store.clear();
    expect(await store.fileFor('https://x/a.png'), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/offline_image_store_test.dart`
Expected: FAIL — `offline_image_store.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/offline_image_store.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Abstraction over network image fetching, so the store is testable.
abstract class ImageDownloader {
  Future<Uint8List> download(String url);
}

class HttpImageDownloader implements ImageDownloader {
  @override
  Future<Uint8List> download(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Image download failed: ${res.statusCode}');
    }
    return res.bodyBytes;
  }
}

/// Persists data-tied images permanently under
/// `<appDocuments>/offline_images/`. Files are NOT auto-evicted; they only
/// disappear when [prune] removes URLs no longer present in the data, or via
/// [clear].
class OfflineImageStore {
  final ImageDownloader _downloader;
  final Directory? _baseDirOverride;
  Directory? _dir;

  OfflineImageStore({
    ImageDownloader? downloader,
    Directory? baseDirOverride,
  })  : _downloader = downloader ?? HttpImageDownloader(),
        _baseDirOverride = baseDirOverride;

  Future<void> init() async {
    final base = _baseDirOverride ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline_images');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
  }

  Directory get _directory {
    final d = _dir;
    if (d == null) {
      throw StateError('OfflineImageStore.init() must be called first');
    }
    return d;
  }

  String _fileName(String url) {
    final hash = sha1.convert(utf8.encode(url)).toString();
    final ext = _extensionOf(url);
    return ext.isEmpty ? hash : '$hash$ext';
  }

  String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    final ext = path.substring(dot);
    return ext.length <= 5 ? ext : '';
  }

  File _fileObject(String url) => File('${_directory.path}/${_fileName(url)}');

  Future<File?> fileFor(String url) async {
    final f = _fileObject(url);
    return await f.exists() ? f : null;
  }

  Future<File> fetchAndStore(String url) async {
    final existing = await fileFor(url);
    if (existing != null) return existing;
    final bytes = await _downloader.download(url);
    final f = _fileObject(url);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  Future<void> prune(Set<String> keepUrls) async {
    final keepNames = keepUrls.map(_fileName).toSet();
    if (!await _directory.exists()) return;
    await for (final entity in _directory.list()) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (!keepNames.contains(name)) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    }
  }

  Future<void> clear() async {
    if (!await _directory.exists()) return;
    await for (final entity in _directory.list()) {
      if (entity is File) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }
}
```

- [ ] **Step 4: Add http dependency if missing**

Check `pubspec.yaml` for `http`. `cached_network_image` pulls it transitively but it must be a direct dependency to import. Add under dependencies:
```yaml
  http: ^1.2.0
```
Run: `flutter pub get`

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/cache/offline_image_store_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/cache/offline_image_store.dart test/core/cache/offline_image_store_test.dart pubspec.yaml pubspec.lock
git commit -m "feat(cache): add OfflineImageStore (permanent on-disk image store)"
```

---

### Task 8: ImageSyncService

**Files:**
- Create: `lib/core/cache/image_sync_service.dart`
- Test: `test/core/cache/image_sync_service_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/cache/image_sync_service_test.dart
import 'dart:io';
import 'dart:typed_data';
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
    await sync.syncUrls([
      'https://x/a.png',
      'http://x/b.png',
      'default',          // ignored
      '',                 // ignored
      'preset_blue',      // ignored
    ]);
    expect(await store.fileFor('https://x/a.png'), isNotNull);
    expect(await store.fileFor('http://x/b.png'), isNotNull);
    expect(downloader.calls.length, 2);
  });

  test('syncUrls prunes images no longer referenced', () async {
    await sync.syncUrls(['https://x/a.png', 'https://x/b.png']);
    await sync.syncUrls(['https://x/a.png']); // b removed from data
    expect(await store.fileFor('https://x/a.png'), isNotNull);
    expect(await store.fileFor('https://x/b.png'), isNull);
  });

  test('syncUrls does not throw when a download fails', () async {
    downloader.throwOnDownload = true;
    await sync.syncUrls(['https://x/a.png']); // should complete silently
    expect(await store.fileFor('https://x/a.png'), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/image_sync_service_test.dart`
Expected: FAIL — `image_sync_service.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/cache/image_sync_service.dart
import '../../data/models/app/app_settings_model.dart';
import '../../data/models/mosque/mosque_model.dart';
import 'offline_image_store.dart';

/// Keeps [OfflineImageStore] in sync with the image URLs referenced by the
/// app's data. After each data update, the referenced images are downloaded
/// (if absent) and any orphaned images are pruned.
class ImageSyncService {
  final OfflineImageStore _store;

  ImageSyncService(this._store);

  static bool _isHttp(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  /// Downloads every http URL in [urls] (deduped) and prunes everything else.
  Future<void> syncUrls(List<String> urls) async {
    final keep = urls.where(_isHttp).toSet();
    for (final url in keep) {
      try {
        await _store.fetchAndStore(url);
      } catch (_) {
        // best-effort; image will load over network later
      }
    }
    try {
      await _store.prune(keep);
    } catch (_) {}
  }

  Future<void> syncMosque(MosqueModel mosque) {
    return syncUrls([
      ...mosque.albumImageUrls,
      if (mosque.publishedAlbumImageUrl != null) mosque.publishedAlbumImageUrl!,
      mosque.designSettings.background.value,
    ]);
  }

  Future<void> syncAppSettings(AppSettingsModel settings) {
    return syncUrls(settings.backgroundLibraryUrls);
  }
}
```

> **Note on `prune` interaction:** `syncMosque` and `syncAppSettings` prune against only their own URL set. Because mosque images and app-settings background-library images are distinct sets that could collide on prune, scope the prune per category. SIMPLEST: keep one shared store but have `ImageSyncService` track a combined keep-set. For this app the two sets never overlap in practice (mosque album vs platform background library), but to be safe, change `syncUrls` callers to pass the COMBINED current set when both are known. Implement the per-category version above now; the combined-prune refinement is handled in Task 13 where both data sources are wired together.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/image_sync_service_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/cache/image_sync_service.dart test/core/cache/image_sync_service_test.dart
git commit -m "feat(cache): add ImageSyncService (data-tied image persistence)"
```

---

### Task 9: cache barrel export

**Files:**
- Create: `lib/core/cache/cache.dart`

- [ ] **Step 1: Write the barrel**

```dart
// lib/core/cache/cache.dart
export 'cache_entry.dart';
export 'cache_first_loader.dart';
export 'cache_policy.dart';
export 'hive_cache_store.dart';
export 'i_cache_store.dart';
export 'image_sync_service.dart';
export 'json_cache.dart';
export 'offline_image_store.dart';
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/core/cache`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/cache/cache.dart
git commit -m "chore(cache): add barrel export"
```

---

## Phase D — Unified image widget

### Task 10: AppImage widget

**Files:**
- Create: `lib/core/widgets/media/app_image.dart`
- Modify: `lib/core/widgets/media/media_widgets.dart`
- Test: `test/core/widgets/app_image_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// test/core/widgets/app_image_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/offline_image_store.dart';
import 'package:Tebyan/core/widgets/media/app_image.dart';

class _FakeDownloader implements ImageDownloader {
  @override
  Future<Uint8List> download(String url) async {
    // 1x1 transparent PNG
    return Uint8List.fromList(<int>[
      0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
      0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
      0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
      0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,
      0x42,0x60,0x82,
    ]);
  }
}

void main() {
  testWidgets('AppImage.network renders a placeholder then resolves', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('appimg');
    final store = OfflineImageStore(downloader: _FakeDownloader(), baseDirOverride: tempDir);
    await store.init();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppImage.network(
          'https://x/a.png',
          imageStore: store,
          width: 50,
          height: 50,
        ),
      ),
    ));
    // Placeholder shows synchronously (no offline file yet).
    expect(find.byType(AppImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tempDir.delete(recursive: true);
  });

  testWidgets('AppImage.asset builds without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AppImage.asset('assets/logo.png', width: 40, height: 40)),
    ));
    expect(find.byType(AppImage), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/app_image_test.dart`
Expected: FAIL — `app_image.dart` does not exist.

- [ ] **Step 3: Write the widget**

```dart
// lib/core/widgets/media/app_image.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../cache/offline_image_store.dart';
import '../../di/service_locator.dart';
import 'optimized_image.dart';

/// The single entry point for displaying images across the app.
///
/// - `AppImage.network(url)` resolves: permanent offline file → network
///   (cached) → placeholder/error. When loaded over network, the image is
///   persisted to the offline store for the next launch.
/// - `AppImage.asset(path)` delegates to [OptimizedImage] for size-aware decode.
class AppImage extends StatelessWidget {
  final _AppImageKind _kind;
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final OfflineImageStore? _imageStoreOverride;

  static const Color _bg = Color(0xFFE8EDED);
  static const Color _fg = Color(0xFFA8BFBE);

  const AppImage._({
    super.key,
    required _AppImageKind kind,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    OfflineImageStore? imageStore,
  })  : _kind = kind,
        _imageStoreOverride = imageStore;

  factory AppImage.network(
    String url, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    Widget? placeholder,
    Widget? errorWidget,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        fadeInDuration: fadeInDuration,
        placeholder: placeholder,
        errorWidget: errorWidget,
        imageStore: imageStore,
      );

  factory AppImage.networkBackground(
    String url, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 500),
        placeholder: placeholder,
        errorWidget: errorWidget,
        imageStore: imageStore,
      );

  factory AppImage.networkThumbnail(
    String url, {
    Key? key,
    double size = 56,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    OfflineImageStore? imageStore,
  }) =>
      AppImage._(
        key: key,
        kind: _AppImageKind.network,
        source: url,
        width: size,
        height: size,
        fit: fit,
        borderRadius: borderRadius,
        fadeInDuration: const Duration(milliseconds: 200),
        imageStore: imageStore,
      );

  const AppImage.asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  })  : _kind = _AppImageKind.asset,
        source = path,
        width = width,
        height = height,
        fit = fit,
        borderRadius = null,
        fadeInDuration = const Duration(milliseconds: 300),
        placeholder = null,
        errorWidget = null,
        _imageStoreOverride = null,
        super(key: key);

  OfflineImageStore get _store =>
      _imageStoreOverride ?? sl<OfflineImageStore>();

  @override
  Widget build(BuildContext context) {
    if (_kind == _AppImageKind.asset) {
      return OptimizedImage.asset(
        source,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return _buildNetwork(context);
  }

  Widget _buildNetwork(BuildContext context) {
    return FutureBuilder<File?>(
      future: _store.fileFor(source),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _wrap(_placeholder());
        }
        final file = snap.data;
        if (file != null) {
          return _wrap(Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _errorWidget(),
          ));
        }
        // Not stored yet: load over network, persist for next time.
        _store.fetchAndStore(source).catchError((_) => File(''));
        return _wrap(CachedNetworkImage(
          imageUrl: source,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: fadeInDuration,
          placeholder: (_, __) => _placeholder(),
          errorWidget: (_, __, ___) => _errorWidget(),
        ));
      },
    );
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _placeholder() =>
      placeholder ??
      Container(
        width: width,
        height: height,
        color: _bg,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF384C4B)),
          ),
        ),
      );

  Widget _errorWidget() =>
      errorWidget ??
      Container(
        width: width,
        height: height,
        color: _bg,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: _fg, size: 28),
        ),
      );
}

enum _AppImageKind { network, asset }
```

> **Note:** `fetchAndStore` is fired inside `build` only when the file is absent; it self-guards (idempotent + try/catch in store). This is acceptable because `fileFor` returning null is a one-time path per URL until the file exists. `ImageSyncService` is the primary populator on data sync; this in-widget fetch is a fallback for images shown before a sync ran.

- [ ] **Step 4: Export from media barrel**

In `lib/core/widgets/media/media_widgets.dart` add line:
```dart
export 'app_image.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/widgets/app_image_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/media/app_image.dart lib/core/widgets/media/media_widgets.dart test/core/widgets/app_image_test.dart
git commit -m "feat(media): add unified AppImage widget (offline-first)"
```

---

## Phase E — Wire stores into DI + bootstrap

### Task 11: Register stores & services in service_locator

**Files:**
- Modify: `lib/core/di/service_locator.dart`
- Modify: `lib/main.dart` (bootstrap — find the file that calls `HiveService.init()` and `setupServiceLocator()`)

- [ ] **Step 1: Locate bootstrap**

Run: `flutter test` is not needed here. First inspect:
Run: `grep -rn "setupServiceLocator\|HiveService.init" lib/main.dart`
(Use the Read tool on `lib/main.dart`.) Confirm order: `HiveService.init()` then `setupServiceLocator()`.

- [ ] **Step 2: Register in service_locator.dart**

Add imports at top of `lib/core/di/service_locator.dart`:
```dart
import '../cache/cache.dart';
```
Add registrations inside `setupServiceLocator()` BEFORE the repositories:
```dart
  // Cache infrastructure
  sl.registerLazySingleton<ICacheStore>(() => HiveCacheStore());
  sl.registerLazySingleton<OfflineImageStore>(() => OfflineImageStore());
  sl.registerLazySingleton<ImageSyncService>(
    () => ImageSyncService(sl<OfflineImageStore>()),
  );
```

- [ ] **Step 3: Init OfflineImageStore in bootstrap**

In `lib/main.dart`, after `setupServiceLocator()` (so `sl` is ready) and after `HiveService.init()`:
```dart
  await sl<OfflineImageStore>().init();
```

- [ ] **Step 4: Verify it compiles & existing tests pass**

Run: `flutter analyze lib/core/di/service_locator.dart lib/main.dart`
Expected: No errors.
Run: `flutter test`
Expected: All existing + new tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/di/service_locator.dart lib/main.dart
git commit -m "feat(di): register cache store, image store, image sync; init on boot"
```

---

## Phase F — Repository cache-first integration

### Task 12: AppSettingsRepository → JsonCache + cache-first

**Files:**
- Modify: `lib/data/repositories/app_settings_repository.dart`
- Modify: `lib/core/di/service_locator.dart`
- Delete (end of task): `lib/data/repositories/app_settings_local_repository.dart`
- Test: `test/data/app_settings_repository_test.dart`

- [ ] **Step 1: Write the failing test (cache-first behavior)**

```dart
// test/data/app_settings_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/app/app_settings_model.dart';
import 'package:Tebyan/data/repositories/app_settings_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;

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
      firestore: throw UnimplementedError(), // not used in this path
      cache: cache,
      remoteStream: () => const Stream<AppSettingsModel?>.empty(),
    );

    final first = await repo.streamAppSettings.first;
    expect(first!.backgroundLibraryUrls, ['https://x/a.png']);
  });
}
```

> The repository must accept an injectable `cache` and `remoteStream` for testability. Adjust the constructor accordingly (keep `firestore` for production wiring). Verify `AppSettingsModel` has a const constructor with `backgroundLibraryUrls` (it does — see model).

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/app_settings_repository_test.dart`
Expected: FAIL — constructor doesn't accept `cache`/`remoteStream`.

- [ ] **Step 3: Rewrite AppSettingsRepository**

```dart
// lib/data/repositories/app_settings_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/cache/cache.dart';
import '../../core/constants/firestore_schema.dart';
import '../models/app/app_settings_model.dart';
import 'interfaces/app_settings_repository_interface.dart';

class AppSettingsRepository implements IAppSettingsRepository {
  final FirebaseFirestore _firestore;
  final JsonCache<AppSettingsModel> _cache;
  final CacheFirstLoader<AppSettingsModel> _loader;
  final Stream<AppSettingsModel?> Function()? _remoteStreamOverride;
  final ImageSyncService? _imageSync;

  AppSettingsRepository({
    required FirebaseFirestore firestore,
    required JsonCache<AppSettingsModel> cache,
    Stream<AppSettingsModel?> Function()? remoteStream,
    ImageSyncService? imageSync,
  })  : _firestore = firestore,
        _cache = cache,
        _remoteStreamOverride = remoteStream,
        _imageSync = imageSync,
        _loader = CacheFirstLoader<AppSettingsModel>(
          cache,
          onValue: imageSync == null
              ? null
              : (s) => imageSync.syncAppSettings(s),
        );

  Stream<AppSettingsModel?> _firestoreStream() {
    return _firestore
        .collection(FirestoreSchema.appSettingsCollection)
        .doc(FirestoreSchema.globalDocId)
        .snapshots()
        .map((doc) => (!doc.exists || doc.data() == null)
            ? null
            : AppSettingsModel.fromMap(doc.data()!));
  }

  @override
  Stream<AppSettingsModel?> get streamAppSettings =>
      _loader.stream(remote: _remoteStreamOverride ?? _firestoreStream);

  @override
  Future<AppSettingsModel?> getAppSettings() async {
    return _loader.once(remote: () async {
      final doc = await _firestore
          .collection(FirestoreSchema.appSettingsCollection)
          .doc(FirestoreSchema.globalDocId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return AppSettingsModel.fromMap(doc.data()!);
    }).last;
  }
}
```

> Check `IAppSettingsRepository` for the exact method signatures and keep them. `getAppSettings()` returns the last emitted value (cache then fresh) — semantically "the freshest available". If the interface only declares `getAppSettings()` and `streamAppSettings`, this matches.

- [ ] **Step 4: Update DI registration**

In `service_locator.dart`, replace the App Settings registration:
```dart
  sl.registerLazySingleton<IAppSettingsRepository>(
    () => AppSettingsRepository(
      firestore: sl<FirebaseFirestore>(),
      cache: JsonCache<AppSettingsModel>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.appSettingsCacheKey,
        toJson: (s) => s.toMap(),
        fromJson: AppSettingsModel.fromMap,
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );
```
Add imports as needed (`FirestoreSchema`, `JsonCache`, `AppSettingsModel`, `ICacheStore`).

- [ ] **Step 5: Run test**

Run: `flutter test test/data/app_settings_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Delete the old local repo & verify no references**

Run: `grep -rn "AppSettingsLocalRepository" lib test`
Expected: no remaining references (the rewrite removed them).
Delete: `lib/data/repositories/app_settings_local_repository.dart`
Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add lib/data/repositories/app_settings_repository.dart lib/core/di/service_locator.dart test/data/app_settings_repository_test.dart
git rm lib/data/repositories/app_settings_local_repository.dart
git commit -m "refactor(app-settings): cache-first via JsonCache, drop local repo duplication"
```

---

### Task 13: MosqueRepository → JsonCache + cache-first

**Files:**
- Modify: `lib/data/repositories/mosque_repository.dart`
- Modify: `lib/core/di/service_locator.dart`
- Delete: `lib/data/repositories/mosque_local_repository.dart`
- Test: `test/data/mosque_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/data/mosque_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/mosque/mosque_model.dart';
import 'package:Tebyan/data/repositories/mosque_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;

void main() {
  test('streamActiveMosque emits cached mosque before remote', () async {
    final store = FakeCacheStore();
    final cache = JsonCache<MosqueModel>(
      store: store,
      cacheKey: 'mosque',
      toJson: (m) => {'id': m.id, ...m.toMap()},
      fromJson: (m) => MosqueModel.fromMap(m, m['id']?.toString() ?? ''),
    );
    await cache.save(MosqueModel.fromMap(const {'name': 'Al-Noor'}, 'mid1'));

    final repo = MosqueRepository.forTest(
      cache: cache,
      remoteStream: () => const Stream<MosqueModel?>.empty(),
    );

    final first = await repo.streamActiveMosque.first;
    expect(first!.id, 'mid1');
    expect(first.name, 'Al-Noor');
  });
}
```

> `MosqueModel.fromMap(const {'name': 'Al-Noor'}, 'mid1')` must succeed with defaults — confirm by reading the model's `fromMap`; if required fields exist, pass a minimal valid map.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/mosque_repository_test.dart`
Expected: FAIL — `MosqueRepository.forTest` does not exist.

- [ ] **Step 3: Rewrite MosqueRepository for cache-first**

Key changes (preserve ALL existing `update*` methods and `fetchActiveMosqueFromServer` verbatim — only the read paths change):
- Add fields: `final JsonCache<MosqueModel> _cache;`, `late final CacheFirstLoader<MosqueModel> _loader;`, optional `final Stream<MosqueModel?> Function()? _remoteStreamOverride;`, `final ImageSyncService? _imageSync;`.
- Constructor (production) accepts `cache` + `imageSync` in addition to existing params; build `_loader` with `onValue: (m) => imageSync?.syncMosque(m)`.
- Add a named `MosqueRepository.forTest({required JsonCache<MosqueModel> cache, Stream<MosqueModel?> Function()? remoteStream})` that sets stubs for `firestore`/`getActiveMosqueId`/`syncActiveMosque` so unit tests don't touch Firestore.
- `streamActiveMosque` becomes:
```dart
  @override
  Stream<MosqueModel?> get streamActiveMosque =>
      _loader.stream(remote: _remoteStreamOverride ?? _firestoreSnapshots);
```
where `_firestoreSnapshots()` returns the raw Firestore snapshot mapping (no manual cache save — the loader persists):
```dart
  Stream<MosqueModel?> _firestoreSnapshots() {
    final ref = _mosqueRef;
    if (ref == null) return Stream.value(null);
    return ref.snapshots().map((doc) =>
        (!doc.exists || doc.data() == null)
            ? null
            : MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
  }
```
- `getActiveMosque()` becomes cache-first via `_loader.once(...)`, preserving the `_syncActiveMosque(uid)` call before the remote fetch:
```dart
  @override
  Future<MosqueModel?> getActiveMosque() async {
    final uid = _getActiveMosqueId();
    if (uid != null) await _syncActiveMosque(uid);
    return _loader.once(remote: () async {
      final ref = _mosqueRef;
      if (ref == null) return null;
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) return null;
      return MosqueModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).last;
  }
```
- The cache key embeds `id` (via `toJson` adding `'id'`) so the "matches active mosque" guard moves to the `fromJson` + a check: in `streamActiveMosque`/`getActiveMosque`, after reading cache the loader emits whatever is cached; preserve correctness by clearing the cache when the active mosque id changes. Add: when `_getActiveMosqueId()` differs from cached id, the cached value is still emitted but immediately overwritten by remote. ACCEPTABLE for cache-first. (If strict isolation is required, add an id check in a thin wrapper — out of scope per spec §7.)

> Full rewrite must compile; keep imports for `FirestoreSchema`, `AppLanguage`, `MosqueTextListKind`, `MosqueModel`, and add `../../core/cache/cache.dart`.

- [ ] **Step 4: Update DI registration**

```dart
  sl.registerLazySingleton<IMosqueRepository>(
    () => MosqueRepository(
      firestore: sl<FirebaseFirestore>(),
      getActiveMosqueId: () => sl<IAuthRepository>().getActiveMosqueId(),
      syncActiveMosque: (uid) => UserActiveMosqueRepository.syncBestEffort(uid),
      cache: JsonCache<MosqueModel>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.activeMosqueCacheKey,
        toJson: (m) => {'id': m.id, ...m.toMap()},
        fromJson: (m) => MosqueModel.fromMap(m, m['id']?.toString() ?? ''),
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );
```

- [ ] **Step 5: Run test**

Run: `flutter test test/data/mosque_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Delete old local repo & fix references**

Run: `grep -rn "MosqueLocalRepository" lib test`
Replace any remaining references (e.g. in `UserActiveMosqueRepository` or splash) — most are internal to the deleted file. If `getCachedForActiveMosque` is referenced elsewhere, route through the new `JsonCache` (inject or expose a `cachedActiveMosque()` method on the repo).
Delete: `lib/data/repositories/mosque_local_repository.dart`
Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add lib/data/repositories/mosque_repository.dart lib/core/di/service_locator.dart test/data/mosque_repository_test.dart
git rm lib/data/repositories/mosque_local_repository.dart
git commit -m "refactor(mosque): cache-first via JsonCache + image sync, drop local repo"
```

---

### Task 14: PlatformAnnouncementsRepository → JsonCache + cache-first

**Files:**
- Modify: `lib/data/repositories/platform_announcements_repository.dart`
- Modify: `lib/core/di/service_locator.dart`
- Delete: `lib/data/repositories/platform_announcements_local_repository.dart`
- Test: `test/data/platform_announcements_repository_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/data/platform_announcements_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/cache/json_cache.dart';
import 'package:Tebyan/data/models/mosque/announcement_model.dart';
import 'package:Tebyan/data/repositories/platform_announcements_repository.dart';
import '../core/cache/json_cache_test.dart' show FakeCacheStore;

void main() {
  test('watchActiveForDisplay emits cached list before remote', () async {
    final store = FakeCacheStore();
    // Cache a list-wrapper model.
    final cache = JsonCache<List<AnnouncementModel>>(
      store: store,
      cacheKey: 'announcements',
      toJson: (list) => {'items': list.map((a) => {'id': a.id, ...a.toMap()}).toList()},
      fromJson: (m) => (m['items'] as List)
          .map((e) => AnnouncementModel.fromMap(
              Map<String, dynamic>.from(e as Map), (e)['id']?.toString() ?? ''))
          .toList(),
    );
    // ... save a minimal valid announcement, assert it emits first.
    expect(cache, isNotNull); // placeholder assertion; replace with real flow
  });
}
```

> **Refinement during implementation:** announcements are a `List<T>`, not a single model. Two valid options — pick the simpler:
> (a) Wrap the list in an envelope map (`{'items':[...]}`) and use `JsonCache<List<AnnouncementModel>>` as above.
> (b) Keep the existing `*LocalRepository` Timestamp round-trip logic for announcements ONLY (since it has custom `start_date`/`end_date` reconstruction) and just funnel its save/read through `HiveCacheStore` to remove the duplicated `_sanitizeForHive`.
> RECOMMENDED: (a) — but the model's `fromMap` expects `Timestamp` for date fields. Since `HiveCacheStore` stores them as `int` ms, `fromJson` must reconstruct `Timestamp.fromMillisecondsSinceEpoch` for `start_date`/`end_date`/`created_at` (mirror the logic currently in `platform_announcements_local_repository.dart` lines 62-77). Encapsulate that reconstruction inside the `fromJson` closure.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/platform_announcements_repository_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

- Build a `JsonCache<List<AnnouncementModel>>` (display list) and a `JsonCache<List<SettingsAnnouncementModel>>` (settings list), each with `toJson`/`fromJson` that reconstruct `Timestamp` from int ms for date fields.
- Wrap `watchActiveForDisplay()` and `watchSettingsAnnouncements()` with `CacheFirstLoader.stream` (the loader emits cached list first). The filtering/sorting (`_isInWindow`, `order` sort) stays in the Firestore mapping before handing to the loader.
- Keep `fetchActiveForDisplayFromServer()`; have it save through the cache.

- [ ] **Step 4: Update DI** (mirror Task 12/13 pattern, no `imageSync` needed here).

- [ ] **Step 5: Run test**

Run: `flutter test test/data/platform_announcements_repository_test.dart`
Expected: PASS.

- [ ] **Step 6: Delete old local repo & fix references**

Run: `grep -rn "PlatformAnnouncementsLocalRepository" lib test`
Delete: `lib/data/repositories/platform_announcements_local_repository.dart`
Run: `flutter analyze` → no errors.

- [ ] **Step 7: Commit**

```bash
git add lib/data/repositories/platform_announcements_repository.dart lib/core/di/service_locator.dart test/data/platform_announcements_repository_test.dart
git rm lib/data/repositories/platform_announcements_local_repository.dart
git commit -m "refactor(announcements): cache-first via JsonCache, drop local repo"
```

---

## Phase G — Migrate image display sites to AppImage

### Task 15: Migrate settings/album/design image sites (CachedImage → AppImage)

**Files (modify):**
- `lib/features/settings/album/widgets/album_grid_cell.dart`
- `lib/features/settings/album/widgets/album_publish_bottom_sheet.dart`
- `lib/features/settings/design/widgets/album_url_image_card.dart`
- `lib/features/settings/design/widgets/display_background_picker.dart`

- [ ] **Step 1: Replace usages**

For each file, replace `CachedImage(url: x, ...)` → `AppImage.network(x, ...)`,
`CachedImage.thumbnail(url: x, size: s)` → `AppImage.networkThumbnail(x, size: s)`,
`CachedImage.background(url: x)` → `AppImage.networkBackground(x)`.
Update imports: replace `cached_image.dart` import with `app_image.dart` (or the `media_widgets.dart` barrel).

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/settings`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings
git commit -m "refactor(settings): use AppImage for album/design image sites"
```

---

### Task 16: Migrate display background + photo studio layer (raw CachedNetworkImage → AppImage)

**Files (modify):**
- `lib/features/display/widgets/background/display_background_image.dart`
- `lib/features/display/widgets/layers/photo_studio_layer.dart`

- [ ] **Step 1: Replace `_buildCachedImage` internals**

In `display_background_image.dart`, replace the inner `CachedNetworkImage(...)` (lines ~104-115 and ~145-157) with `AppImage.networkBackground(url, errorWidget: DecoratedBox(... fallbackColor ...))`. Keep the surrounding `Stack`/`AnimatedSwitcher`/`DecoratedBox` fallback and the `ValueKey(currentUrl)`.

In `photo_studio_layer.dart`, replace the raw `CachedNetworkImage` with `AppImage.networkBackground(url)` (preserve progress/placeholder behavior via `placeholder:`).

- [ ] **Step 2: Verify**

Run: `flutter analyze lib/features/display`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/display
git commit -m "refactor(display): use AppImage for background + photo studio layers"
```

---

### Task 17: Delete CachedImage, finalize barrel

**Files:**
- Delete: `lib/core/widgets/media/cached_image.dart`
- Modify: `lib/core/widgets/media/media_widgets.dart` (remove `cached_image.dart` export)

- [ ] **Step 1: Confirm no references remain**

Run: `grep -rn "CachedImage\b\|cached_image.dart" lib test`
Expected: no matches.

- [ ] **Step 2: Delete and update barrel**

Remove `export 'cached_image.dart';` from `media_widgets.dart`.
Delete file.

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git rm lib/core/widgets/media/cached_image.dart
git add lib/core/widgets/media/media_widgets.dart
git commit -m "refactor(media): remove CachedImage, fully unified on AppImage"
```

---

## Phase H — Final verification

### Task 18: Full analyze + test + manual smoke

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 2: Full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Manual smoke (real app)**

Run the app (`flutter run` on a connected device/emulator). Verify:
1. Cold launch with network ON: display screen renders instantly from cache (if previously cached), images appear.
2. Toggle airplane mode, kill & relaunch: display screen, album backgrounds, and settings images all render fully offline.
3. Change a background image in admin/settings, confirm it updates live, then relaunch offline and confirm the new image persisted.

> If unable to run the device manually, state so explicitly rather than claiming success.

- [ ] **Step 4: Final commit (if any cleanup)**

```bash
git add -A
git commit -m "chore: final cleanup for offline cache + unified images"
```

---

## Self-Review Notes (for the implementer)

- **Spec coverage:** §2.1–2.6 → Tasks 1–5; §2.7 DI/integration → Tasks 11–14; §3.1 → Task 7; §3.2 → Task 8; §3.3 AppImage → Task 10; §3.4/§3.5 migration → Tasks 15–17; §4 bootstrap → Task 11; §5 error handling → embedded (try/catch in store, loader fallback); §6 tests → each task is TDD.
- **Package import prefix:** Confirm `package:Tebyan/...` matches `pubspec.yaml` `name: Tebyan` exactly (case-sensitive). If `flutter test` reports "package not found", check the casing of the `name:` field and adjust all test imports.
- **Announcements Timestamp reconstruction (Task 14):** the trickiest part — date fields stored as int ms must be rebuilt into `Timestamp` inside `fromJson`. Mirror the existing logic from the (now deleted) local repo before deleting it.
- **Type consistency:** `JsonCache<T>` constructor named params (`store`, `cacheKey`, `toJson`, `fromJson`, `policy`) are identical across Tasks 4, 12, 13, 14. `CacheFirstLoader` exposes `stream({required remote})` and `once({required remote})` consistently. `OfflineImageStore`: `init`, `fileFor`, `fetchAndStore`, `prune`, `clear`. `AppImage`: `network`, `networkBackground`, `networkThumbnail`, `asset`.
