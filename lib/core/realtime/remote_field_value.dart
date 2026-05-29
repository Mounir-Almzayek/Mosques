/// Transport-neutral write sentinels.
///
/// Repositories use these instead of backend-specific values; the active
/// [RealtimeTransport] translates them into its backend's equivalents
/// (e.g. Firestore `FieldValue.serverTimestamp()` / `FieldValue.delete()`).
enum RemoteFieldValue { serverTimestamp, delete }
