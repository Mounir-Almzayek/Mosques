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
    unawaited(cb(value).catchError((Object _) {}));
  }
}
