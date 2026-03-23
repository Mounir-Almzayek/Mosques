import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English'),
  arabic('ar', 'العربية');

  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

