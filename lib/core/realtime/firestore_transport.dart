import 'package:cloud_firestore/cloud_firestore.dart';

import 'realtime_transport.dart';
import 'remote_document.dart';
import 'remote_field_value.dart';

/// The single place that knows about Firestore.
///
/// Translates the neutral [RealtimeTransport] contract into Firestore calls and
/// converts values at the boundary: on read, `Timestamp` → `DateTime`; on write,
/// `DateTime` → `Timestamp` and [RemoteFieldValue] sentinels → Firestore
/// `FieldValue`s. No Firestore type escapes this class.
class FirestoreTransport implements RealtimeTransport {
  final FirebaseFirestore _db;

  FirestoreTransport(this._db);

  @override
  Stream<RemoteDocument?> watchDocument(String collection, String id) {
    return _db.collection(collection).doc(id).snapshots().map(_toRemote);
  }

  @override
  Stream<List<RemoteDocument>> watchCollection(String collection) {
    return _db.collection(collection).snapshots().map(
          (snap) =>
              snap.docs.map(_toRemote).whereType<RemoteDocument>().toList(),
        );
  }

  @override
  Future<RemoteDocument?> getDocument(
    String collection,
    String id, {
    bool serverOnly = false,
  }) async {
    final doc = await _db
        .collection(collection)
        .doc(id)
        .get(serverOnly ? const GetOptions(source: Source.server) : null);
    return _toRemote(doc);
  }

  @override
  Future<List<RemoteDocument>> getCollection(
    String collection, {
    bool serverOnly = false,
  }) async {
    final snap = await _db
        .collection(collection)
        .get(serverOnly ? const GetOptions(source: Source.server) : null);
    return snap.docs.map(_toRemote).whereType<RemoteDocument>().toList();
  }

  @override
  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return _db
        .collection(collection)
        .doc(id)
        .set(_encode(data) as Map<String, dynamic>, SetOptions(merge: merge));
  }

  @override
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) {
    return _db
        .collection(collection)
        .doc(id)
        .update(_encode(data) as Map<String, dynamic>);
  }

  RemoteDocument? _toRemote(DocumentSnapshot<Object?> doc) {
    final data = doc.data();
    if (!doc.exists || data is! Map) return null;
    return RemoteDocument(
      id: doc.id,
      data: _decode(data) as Map<String, dynamic>,
    );
  }

  /// Firestore → neutral: `Timestamp` becomes `DateTime`.
  dynamic _decode(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _decode(v)),
      );
    }
    if (value is List) return value.map(_decode).toList();
    return value;
  }

  /// Neutral → Firestore: `DateTime` becomes `Timestamp`, sentinels become
  /// `FieldValue`s.
  dynamic _encode(dynamic value) {
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value == RemoteFieldValue.serverTimestamp) {
      return FieldValue.serverTimestamp();
    }
    if (value == RemoteFieldValue.delete) return FieldValue.delete();
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _encode(v)),
      );
    }
    if (value is List) return value.map(_encode).toList();
    return value;
  }
}
