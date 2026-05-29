/// Parses a date value coming from the neutral data layer.
///
/// Handles [DateTime] (from a live transport read) and millisecond-epoch
/// numbers (from the Hive cache). Backend-specific types (e.g. Firestore
/// `Timestamp`) never reach here — the transport normalizes them to [DateTime].
DateTime? parseDateOrMillis(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is double) return DateTime.fromMillisecondsSinceEpoch(v.round());
  return null;
}
