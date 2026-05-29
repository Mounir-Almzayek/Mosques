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
