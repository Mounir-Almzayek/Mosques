part of 'language_bloc.dart';

abstract class LanguageState {
  final AppLanguage language;
  const LanguageState({required this.language});
}

class LanguageInitial extends LanguageState {
  const LanguageInitial({required super.language});
}

