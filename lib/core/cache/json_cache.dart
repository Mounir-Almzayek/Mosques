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
    if (storedVersion is! int || !_policy.isCompatible(storedVersion)) return null;
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
