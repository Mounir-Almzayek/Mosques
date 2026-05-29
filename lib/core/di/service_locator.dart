import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../cache/cache.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../../data/repositories/interfaces/app_settings_repository_interface.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../data/repositories/mosque_repository.dart';
import '../../data/repositories/platform_announcements_repository.dart';
import '../../features/auth/auth.dart' show AuthRepository, UserActiveMosqueRepository;

final sl = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Cache infrastructure
  sl.registerLazySingleton<ICacheStore>(() => HiveCacheStore());
  sl.registerLazySingleton<OfflineImageStore>(() => OfflineImageStore());
  sl.registerLazySingleton<ImageSyncService>(
    () => ImageSyncService(sl<OfflineImageStore>()),
  );

  // Auth
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Mosque
  sl.registerLazySingleton<IMosqueRepository>(
    () => MosqueRepository(
      firestore: sl<FirebaseFirestore>(),
      getActiveMosqueId: () => sl<IAuthRepository>().getActiveMosqueId(),
      syncActiveMosque: (uid) => UserActiveMosqueRepository.syncBestEffort(uid),
    ),
  );

  // App Settings
  sl.registerLazySingleton<IAppSettingsRepository>(
    () => AppSettingsRepository(firestore: sl<FirebaseFirestore>()),
  );

  // Platform Announcements
  sl.registerLazySingleton<IPlatformAnnouncementsRepository>(
    () => PlatformAnnouncementsRepository(firestore: sl<FirebaseFirestore>()),
  );
}
