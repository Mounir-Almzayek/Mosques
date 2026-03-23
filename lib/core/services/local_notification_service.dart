import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    '1',
    'project 1',
    description: 'project 1 app',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) async {
    if (kDebugMode) {
      print("Notification tapped! Payload: ${response.payload}");
    }

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

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      channelShowBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    try {
      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotificationsPlugin.zonedSchedule(
        id: id,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: title,
        body: body,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotificationsPlugin.cancelAll();
  }

  static Future<void> clearAllDeliveredNotifications() async {
    try {
      await _localNotificationsPlugin.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing notifications: $e');
      }
    }
  }
}

