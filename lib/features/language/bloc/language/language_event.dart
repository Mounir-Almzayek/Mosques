part of 'language_bloc.dart';

abstract class LanguageEvent {
  const LanguageEvent();
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  final AppLanguage language;
  const ChangeLanguage(this.language);
}

/// Applied after reading Firestore (no write-back to Firebase to avoid loops).
class RemoteLanguageChanged extends LanguageEvent {
  final AppLanguage language;
  const RemoteLanguageChanged(this.language);
}

