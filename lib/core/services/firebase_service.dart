import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../firebase_options.dart';
import 'local_notification_service.dart';
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';

class FirebaseService {
  static FirebaseMessaging? _messaging;
  static String? _fcmToken;
  static int _notificationId = 0;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Explicitly enable offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // FCM + local notifications: mobile/desktop only (web needs VAPID/service worker setup)
      if (kIsWeb) {
        return;
      }

      _messaging = FirebaseMessaging.instance;

      await LocalNotificationService.initialize();
      await _requestNotificationPermission();
      await _getDeviceToken();
      _setupNotificationHandlers();
    } catch (e) {
      if (kDebugMode) {
        print("Firebase initialization failed: $e");
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
    await _syncTokenToCurrentUser();
  }

  static void _setupNotificationHandlers() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _syncTokenToCurrentUser();
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onNotificationTapped(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _onNotificationTapped(message.data);
      }
    });

    _messaging?.onTokenRefresh.listen((token) async {
      _fcmToken = token;
      await _syncTokenToCurrentUser();
    });
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? "Notification";
    final body = message.notification?.body ?? "";
    final payload = jsonEncode(message.data);

    LocalNotificationService.showNotification(
      id: ++_notificationId,
      title: title,
      body: body,
      payload: payload,
    );
  }

  static void _onNotificationTapped(Map<String, dynamic> data) {
    try {
      final context = Pages.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            context.push(Routes.settingsPath);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Navigation error: $e");
      }
    }
  }

  static String? get fcmToken => _fcmToken;

  static Future<String?> refreshToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    _fcmToken = await messaging.getToken();
    await _syncTokenToCurrentUser();
    return _fcmToken;
  }

  static Future<void> syncTokenToCurrentUser() async {
    await _syncTokenToCurrentUser();
  }

  static Future<void> _syncTokenToCurrentUser() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    try {
      await AuthRepository.saveFcmToken(token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token sync failed: $e');
      }
    }
  }
}
