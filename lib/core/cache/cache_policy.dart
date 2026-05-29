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
