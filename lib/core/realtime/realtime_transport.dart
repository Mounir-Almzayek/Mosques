import 'remote_document.dart';

/// The real-time data layer's backend contract.
///
/// All backend-specific access (currently Firestore) lives behind this
/// interface, so repositories hold only domain logic. Implementations exchange
/// only plain Dart types via [RemoteDocument] and accept [RemoteFieldValue]
/// sentinels in write payloads. Swapping backends means adding one
/// implementation — no repo, model, BLoC, or widget changes.
abstract interface class RealtimeTransport {
  /// Live stream of a single document. Emits `null` when the document is absent.
  Stream<RemoteDocument?> watchDocument(String collection, String id);

  /// Live stream of all documents in a collection.
  Stream<List<RemoteDocument>> watchCollection(String collection);

  /// One-shot read of a single document, or `null` if absent.
  ///
  /// When [serverOnly] is true, bypasses any local cache and reads from the
  /// server only.
  Future<RemoteDocument?> getDocument(
    String collection,
    String id, {
    bool serverOnly = false,
  });

  /// One-shot read of all documents in a collection.
  Future<List<RemoteDocument>> getCollection(
    String collection, {
    bool serverOnly = false,
  });

  /// Writes [data] to a document, merging with existing fields when [merge].
  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  });

  /// Updates the given fields of an existing document.
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  );
}
