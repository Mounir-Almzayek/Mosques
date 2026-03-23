import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class SettingsLocalRepository {
  static const String _languageKey = 'selectedLanguage';
  static const String _isFirstTimeKey = 'isFirstTime';

  /// Device default locale (first-run priority).
  static Locale loadDeviceLanguage() {
    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      return Locale(deviceLocale.languageCode);
    } catch (_) {
      return const Locale('en');
    }
  }

  static Locale loadLanguage() {
    final String? storedLanguageCode = StorageService.getString(_languageKey);

    if (storedLanguageCode != null) {
      return Locale(storedLanguageCode);
    }

    try {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      return Locale(deviceLocale.languageCode);
    } catch (_) {
      return const Locale('en');
    }
  }

  static void storeLanguage(Locale locale) {
    StorageService.setString(_languageKey, locale.languageCode);
  }

  static bool isAppOpenedForFirstTime() {
    return StorageService.getBool(_isFirstTimeKey) ?? true;
  }

  static void markAppAsOpened() {
    StorageService.setBool(_isFirstTimeKey, false);
  }
}
