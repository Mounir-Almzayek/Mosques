import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../cache/cache.dart';
import '../constants/firestore_schema.dart';
import '../../data/models/app/app_settings_model.dart';
import '../../data/repositories/app_settings_repository.dart';
import '../../data/repositories/interfaces/app_settings_repository_interface.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../data/models/mosque/announcement_model.dart';
import '../../data/models/mosque/mosque_model.dart';
import '../../data/models/platform_announcements/settings_announcement_model.dart';
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
      cache: JsonCache<MosqueModel>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.activeMosqueCacheKey,
        toJson: (m) => {'id': m.id, ...m.toMap()},
        fromJson: (m) => MosqueModel.fromMap(m, m['id']?.toString() ?? ''),
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );

  // App Settings
  sl.registerLazySingleton<IAppSettingsRepository>(
    () => AppSettingsRepository(
      firestore: sl<FirebaseFirestore>(),
      cache: JsonCache<AppSettingsModel>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.appSettingsCacheKey,
        toJson: (s) => s.toMap(),
        fromJson: AppSettingsModel.fromMap,
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );

  // Platform Announcements
  sl.registerLazySingleton<IPlatformAnnouncementsRepository>(
    () => PlatformAnnouncementsRepository(
      firestore: sl<FirebaseFirestore>(),
      displayCache: JsonCache<List<AnnouncementModel>>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.platformAnnouncementsCacheKey,
        toJson: (list) =>
            {'items': list.map((a) => {...a.toMap(), 'id': a.id}).toList()},
        fromJson: (m) => (m['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) {
              final map = Map<String, dynamic>.from(e);
              final conv = <String, dynamic>{};
              map.forEach((k, v) {
                conv[k] =
                    (k == 'start_date' ||
                                k == 'end_date' ||
                                k == 'created_at') &&
                            v is int
                        ? Timestamp.fromMillisecondsSinceEpoch(v)
                        : v;
              });
              return AnnouncementModel.fromMap(
                  conv, conv['id']?.toString() ?? '');
            })
            .toList(),
      ),
      settingsCache: JsonCache<List<SettingsAnnouncementModel>>(
        store: sl<ICacheStore>(),
        cacheKey: FirestoreSchema.settingsAnnouncementsCacheKey,
        toJson: (list) => {'items': list.map((a) => a.toMap()).toList()},
        fromJson: (m) => (m['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) {
              final map = Map<String, dynamic>.from(e);
              final conv = <String, dynamic>{};
              map.forEach((k, v) {
                conv[k] =
                    (k == 'start_date' || k == 'end_date') && v is int
                        ? Timestamp.fromMillisecondsSinceEpoch(v)
                        : v;
              });
              return SettingsAnnouncementModel.fromMap(
                  conv, conv['id']?.toString() ?? '');
            })
            .toList(),
      ),
    ),
  );
}
