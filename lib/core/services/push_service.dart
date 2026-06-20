import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../firebase_options.dart';
import 'local_notification_service.dart';

/// Receives push notifications and forwards FCM device tokens to the backend.
///
/// Replaces the old `FirebaseService`. The Firebase Cloud Messaging client SDK
/// stays for delivery only; user identity comes from the backend.
class PushService {
  static FirebaseMessaging? _messaging;
  static String? _fcmToken;
  static int _notificationId = 0;
  static Future<void> Function(PushDeviceRegistration registration)?
      _onRegisterDevice;
  static Future<void>? _initFuture;

  /// Wired by the DI layer once `IAuthRepository` is ready so the registration
  /// hits `PUT /mobile/devices/current` whenever the FCM token rotates.
  static void setRegisterDeviceCallback(
    Future<void> Function(PushDeviceRegistration registration) callback,
  ) {
    _onRegisterDevice = callback;
    // If we already have a token in hand, try to register it now.
    if ((_fcmToken ?? '').isNotEmpty) {
      _registerCurrentDevice();
    }
  }

  static String? get fcmToken => _fcmToken;

  static Future<void> init() {
    return _initFuture ??= _initOnce();
  }

  static Future<void> _initOnce() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // FCM + local notifications: mobile/desktop only (web needs VAPID).
      if (kIsWeb) return;

      _messaging = FirebaseMessaging.instance;

      await LocalNotificationService.initialize();
      await _requestNotificationPermission();
      await _getDeviceToken();
      _setupNotificationHandlers();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PushService initialization failed: $e');
      }
    }
  }

  static Future<void> _requestNotificationPermission() async {
    final messaging = _messaging;
    if (messaging == null) return;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static Future<void> _getDeviceToken() async {
    final messaging = _messaging;
    if (messaging == null) return;
    _fcmToken = await messaging.getToken();
    if (kDebugMode && _fcmToken != null) {
      debugPrint('FCM Token: $_fcmToken');
    }
    await _registerCurrentDevice();
  }

  static void _setupNotificationHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _onNotificationTapped(message.data),
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _onNotificationTapped(message.data);
    });
    _messaging?.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      await _registerCurrentDevice();
    });
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    final payload = jsonEncode(message.data);

    LocalNotificationService.showNotification(
      id: ++_notificationId,
      title: title,
      body: body,
      payload: payload,
    );
  }

  static void _onNotificationTapped(Map<String, dynamic> data) {
    // Route handling stays in the local-notification layer; payload arrives
    // there via `showNotification(payload: ...)`.
  }

  /// Forces a fresh token fetch and re-registers it with the backend.
  static Future<String?> refreshToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    _fcmToken = await messaging.getToken();
    await _registerCurrentDevice();
    return _fcmToken;
  }

  static Future<void> _registerCurrentDevice() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    final callback = _onRegisterDevice;
    if (callback == null) return;
    try {
      final info = await _collectClientInfo();
      await callback(PushDeviceRegistration(
        deviceKind: _resolveDeviceKind(),
        notificationProvider: 'fcm',
        pushToken: token,
        clientInfo: info,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Device registration failed: $e');
      }
    }
  }

  static String _resolveDeviceKind() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
    } catch (_) {}
    return 'unknown';
  }

  static Future<Map<String, dynamic>> _collectClientInfo() async {
    String appVersion = '';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    String osVersion = '';
    try {
      if (!kIsWeb) osVersion = Platform.operatingSystemVersion;
    } catch (_) {}
    return {
      'appVersion': appVersion,
      if (osVersion.isNotEmpty) 'osVersion': osVersion,
    };
  }
}

/// Payload handed to the registration callback. Keeping the shape here so the
/// auth repository doesn't have to know about Firebase types.
class PushDeviceRegistration {
  final String deviceKind;
  final String notificationProvider;
  final String pushToken;
  final Map<String, dynamic> clientInfo;

  const PushDeviceRegistration({
    required this.deviceKind,
    required this.notificationProvider,
    required this.pushToken,
    required this.clientInfo,
  });

  Map<String, dynamic> toJson({String? deviceId}) => {
        'deviceId': ?deviceId,
        'deviceKind': deviceKind,
        'notificationProvider': notificationProvider,
        'pushToken': pushToken,
        'clientInfo': clientInfo,
      };
}
