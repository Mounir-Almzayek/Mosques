/// An immutable cached value paired with the moment it was written.
class CacheEntry<T> {
  final T value;
  final DateTime cachedAt;
  const CacheEntry({required this.value, required this.cachedAt});
}
