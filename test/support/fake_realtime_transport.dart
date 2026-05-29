import 'package:Tebyan/core/realtime/realtime_transport.dart';
import 'package:Tebyan/core/realtime/remote_document.dart';

/// A no-op [RealtimeTransport] for tests: live streams are empty and one-shot
/// reads resolve to absent. Enough to exercise cache-first read behavior
/// without a backend.
class FakeRealtimeTransport implements RealtimeTransport {
  @override
  Stream<RemoteDocument?> watchDocument(String collection, String id) =>
      const Stream<RemoteDocument?>.empty();

  @override
  Stream<List<RemoteDocument>> watchCollection(String collection) =>
      const Stream<List<RemoteDocument>>.empty();

  @override
  Future<RemoteDocument?> getDocument(
    String collection,
    String id, {
    bool serverOnly = false,
  }) async =>
      null;

  @override
  Future<List<RemoteDocument>> getCollection(
    String collection, {
    bool serverOnly = false,
  }) async =>
      const [];

  @override
  Future<void> setDocument(
    String collection,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {}

  @override
  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {}
}
