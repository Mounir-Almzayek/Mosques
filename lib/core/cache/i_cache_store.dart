/// Low-level key/value persistence for JSON-shaped data.
/// Knows nothing about domain models.
abstract class ICacheStore {
  Future<void> write(String key, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> read(String key);
  Future<void> delete(String key);
  Future<List<String>> keys();
}
