/// Optional client-side fallback when a user has no `users/{uid}.active_mosque_id`
/// (e.g. Auth user exists but Firestore profile was never created).
///
/// Build example:
///   flutter run --dart-define=DEFAULT_ACTIVE_MOSQUE_ID=your_mosque_doc_id
abstract final class FirebaseUserBootstrap {
  FirebaseUserBootstrap._();

  static const String defaultActiveMosqueId = String.fromEnvironment(
    'DEFAULT_ACTIVE_MOSQUE_ID',
    defaultValue: '',
  );

  static bool get hasDefaultMosqueId => defaultActiveMosqueId.isNotEmpty;
}
