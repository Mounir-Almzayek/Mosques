/// A backend-neutral document snapshot.
///
/// [data] contains only plain Dart types (`String`, `num`, `bool`, `DateTime`,
/// `List`, `Map`) — never a backend-specific type. A `null` [RemoteDocument]
/// from a transport means the document is absent / does not exist.
class RemoteDocument {
  final String id;
  final Map<String, dynamic> data;

  const RemoteDocument({required this.id, required this.data});
}
