import 'dart:io';

import 'package:flutter/foundation.dart';

/// Backend connection settings.
///
/// Override via `--dart-define`:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
///
/// Defaults when unset:
/// - Android emulator uses `10.0.2.2` to reach the host's localhost.
/// - Other platforms use `localhost`.
abstract final class ApiConfig {
  ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _envWsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  /// Full HTTP base URL including the API version prefix.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _ensureNoTrailingSlash(_envBaseUrl);
    return '${_defaultHost('http')}/api/v1';
  }

  /// Full WebSocket base URL including the API version prefix.
  static String get wsBaseUrl {
    if (_envWsUrl.isNotEmpty) return _ensureNoTrailingSlash(_envWsUrl);
    return '${_defaultHost('ws')}/api/v1';
  }

  /// HTTP request timeouts.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// WebSocket reconnect back-off.
  static const Duration wsReconnectInitial = Duration(seconds: 1);
  static const Duration wsReconnectMax = Duration(seconds: 30);

  /// Heartbeat watchdog — if no frame arrives within this window, reconnect.
  static const Duration wsHeartbeatTimeout = Duration(seconds: 60);

  static String resolvePublicUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) return trimmed;
    if (trimmed.startsWith('//')) {
      return '${Uri.parse(baseUrl).scheme}:$trimmed';
    }

    final base = Uri.parse(baseUrl);
    final origin = '${base.scheme}://${base.authority}';
    if (trimmed.startsWith('/')) return '$origin$trimmed';
    return '$origin/$trimmed';
  }

  static bool canResolvePublicUrl(String value) =>
      resolvePublicUrl(value).startsWith('http');

  static String _defaultHost(String scheme) {
    // Web/desktop: localhost. Android emulator: 10.0.2.2.
    if (kIsWeb) return '$scheme://localhost:8000';
    try {
      if (Platform.isAndroid) return '$scheme://10.0.2.2:8000';
    } catch (_) {
      // Platform may be unavailable in some environments (tests, etc.).
    }
    return '$scheme://localhost:8000';
  }

  static String _ensureNoTrailingSlash(String value) {
    if (value.endsWith('/')) return value.substring(0, value.length - 1);
    return value;
  }
}
