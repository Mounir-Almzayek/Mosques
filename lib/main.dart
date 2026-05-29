import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/storage_service.dart';
import 'core/cache/cache.dart';
import 'core/di/service_locator.dart';
import 'core/services/firebase_service.dart';
import 'core/widgets/keep_screen_on_lifecycle.dart';
import 'data/repositories/interfaces/auth_repository_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // منع إطفاء الشاشة / السكون أثناء تشغيل التطبيق (يُكمّل android:keepScreenOn و iOS idle timer).
  await KeepScreenOnLifecycle.enable();

  // Initialize services
  await StorageService.init();
  await HiveService.init();
  await FirebaseService.init();

  // Set up DI after Firebase is initialized
  setupServiceLocator();
  await sl<OfflineImageStore>().init();

  // Wire the FCM token callback now that DI is ready
  FirebaseService.setFcmTokenCallback(
    (token) => sl<IAuthRepository>().saveFcmToken(token),
  );

  runApp(const MyApp());
}
