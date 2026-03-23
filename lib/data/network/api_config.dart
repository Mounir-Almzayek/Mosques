import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
/// Base URL configuration for the system
class APIConfig {
  // Production and Debug hosts (fallback values)
  static const String _prodHost = "survey-api.system2030.com";
  static const String _debugHost = "survey-api.system2030.com";

  // Frontend URLs (fallback values)
  static const String _defaultSurveyFrontendUrl =
      "https://survey-frontend.system2030.com";
  static const String _defaultLocale = "ar";

  /// Get the current API host based on environment variables or build mode
  static String get host {
    // Try environment variables first
    if (dotenv.isInitialized) {
      final envUrl =
          dotenv.env['API_BASE_URL_${kReleaseMode ? 'PROD' : 'DEV'}'];
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl.replaceAll('https://', '');
      }
    }
    // Fallback to hardcoded values
    return kDebugMode ? _debugHost : _prodHost;
  }

  /// Get the survey frontend base URL
  static String get surveyFrontendBaseUrl {
    if (dotenv.isInitialized) {
      final envUrl = dotenv
          .env['SURVEY_FRONTEND_BASE_URL_${kReleaseMode ? 'PROD' : 'DEV'}'];
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl;
      }
    }
    return _defaultSurveyFrontendUrl;
  }

  /// Get the default locale for survey links
  static String get defaultLocale {
    if (dotenv.isInitialized) {
      final locale = dotenv.env['SURVEY_DEFAULT_LOCALE'];
      if (locale != null && locale.isNotEmpty) {
        return locale;
      }
    }
    return _defaultLocale;
  }

  /// Base URL for the API
  static String get baseUrl => "https://$host";

  /// Full API endpoint URL
  static String get appAPI => baseUrl;

  /// Get full image URL from a relative path
  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('https://')) {
      return imagePath;
    }
    return "$baseUrl$imagePath";
  }

  /// Build public survey URL with short code
  static String buildPublicSurveyUrl(String shortCode, {String? locale}) {
    final loc = locale ?? defaultLocale;
    return "$surveyFrontendBaseUrl/$loc/survey/$shortCode";
  }

  /// Build short-lived survey URL with location parameters
  static String buildShortLivedSurveyUrl(
    String shortCode,
    double latitude,
    double longitude, {
    String? locale,
  }) {
    final loc = locale ?? defaultLocale;
    return "$surveyFrontendBaseUrl/$loc/survey/$shortCode?lat=$latitude&lng=$longitude";
  }
}
