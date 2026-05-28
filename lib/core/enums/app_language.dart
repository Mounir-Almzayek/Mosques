import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'English'),
  arabic('ar', 'العربية');

  final String code;
  final String name;

  const AppLanguage(this.code, this.name);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized == 'ar' || normalized == 'arabic') {
      return AppLanguage.arabic;
    }
    if (normalized == 'en' || normalized == 'english') {
      return AppLanguage.english;
    }
    return AppLanguage.english;
  }
}
