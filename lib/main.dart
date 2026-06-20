import 'package:flutter/material.dart';

import 'app.dart';
import 'core/cache/cache.dart';
import 'core/di/service_locator.dart';
import 'core/services/api_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/push_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_storage.dart';
import 'core/widgets/keep_screen_on_lifecycle.dart';
import 'data/repositories/interfaces/auth_repository_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent the screen from sleeping while the app is running (complements
  // android:keepScreenOn and the iOS idle timer).
  await KeepScreenOnLifecycle.enable();

  // Bootstrap local stores before anything reads from them.
  await StorageService.init();
  await HiveService.init();

  // Wire DI early so we can resolve TokenStorage / ApiService below.
  setupServiceLocator();

  // Restore cached auth tokens into memory.
  await sl<TokenStorage>().init();
  // Touch the API service so its interceptors are wired before first request.
  sl<ApiService>();

  await sl<OfflineImageStore>().init();

  // Push notifications: Firebase Cloud Messaging stays for delivery only.
  await PushService.init();

  // Forward FCM tokens to the backend whenever they rotate.
  PushService.setRegisterDeviceCallback(
    (registration) => sl<IAuthRepository>().saveFcmToken(registration.pushToken),
  );

  runApp(const MyApp());
}
