/// Parses a date value coming from the neutral data layer.
///
/// Handles [DateTime] (already-decoded values), ISO-8601 [String] (HTTP/WS
/// payloads from the backend), and millisecond-epoch numbers (Hive cache).
/// Backend-specific types never reach here — the transport layer normalises
/// them before handing data to the models.
DateTime? parseDateOrMillis(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.round());
  if (v is String) {
    if (v.isEmpty) return null;
    return DateTime.tryParse(v);
  }
  return null;
}
