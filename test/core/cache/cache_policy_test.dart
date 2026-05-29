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
