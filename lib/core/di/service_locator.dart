import 'package:get_it/get_it.dart';

import '../cache/cache.dart';
import '../constants/api_endpoints.dart';
import '../realtime/snapshot_sync.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../../data/datasources/app_config_remote_data_source.dart';
import '../../data/datasources/mosque_remote_data_source.dart';
import '../../data/models/app/app_config.dart';
import '../../data/models/mosque/mosque_bootstrap.dart';
import '../../data/models/platform_announcements/settings_announcement_model.dart';
import '../../data/repositories/app_config_repository.dart';
import '../../data/repositories/interfaces/app_config_repository_interface.dart';
import '../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../data/repositories/interfaces/mosque_repository_interface.dart';
import '../../data/repositories/interfaces/platform_announcements_repository_interface.dart';
import '../../data/repositories/mosque_repository.dart';
import '../../data/repositories/platform_announcements_repository.dart';
import '../../features/auth/auth.dart'
    show AuthRepository, UserActiveMosqueRepository;

final sl = GetIt.instance;

/// Wires every singleton the app uses against the HTTP/WS backend.
///
/// Resolution order: storage → API → auth → realtime/data sources → repos.
void setupServiceLocator() {
  // Tokens + HTTP client
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<ApiService>(
    () => ApiService(tokens: sl<TokenStorage>()),
  );

  // Auth
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      api: sl<ApiService>(),
      tokens: sl<TokenStorage>(),
    ),
  );

  // Realtime + data sources
  sl.registerLazySingleton<SnapshotSync>(
    () => SnapshotSync(tokens: sl<TokenStorage>()),
  );
  sl.registerLazySingleton<MosqueRemoteDataSource>(
    () => MosqueRemoteDataSource(
      api: sl<ApiService>(),
      sync: sl<SnapshotSync>(),
    ),
  );
  sl.registerLazySingleton<AppConfigRemoteDataSource>(
    () => AppConfigRemoteDataSource(api: sl<ApiService>()),
  );

  // Cache infrastructure
  sl.registerLazySingleton<ICacheStore>(() => HiveCacheStore());
  sl.registerLazySingleton<OfflineImageStore>(() => OfflineImageStore());
  sl.registerLazySingleton<ImageSyncService>(
    () => ImageSyncService(sl<OfflineImageStore>()),
  );

  // Mosque
  sl.registerLazySingleton<IMosqueRepository>(
    () => MosqueRepository(
      dataSource: sl<MosqueRemoteDataSource>(),
      getActiveMosqueId: () => sl<IAuthRepository>().getActiveMosqueId(),
      syncActiveMosque: (uid) => UserActiveMosqueRepository.syncBestEffort(uid),
      cache: JsonCache<MosqueBootstrap>(
        store: sl<ICacheStore>(),
        cacheKey: ApiEndpoints.activeMosqueCacheKey,
        toJson: (m) => m.toJson(),
        fromJson: MosqueBootstrap.fromJson,
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );

  // App config
  sl.registerLazySingleton<IAppConfigRepository>(
    () => AppConfigRepository(
      dataSource: sl<AppConfigRemoteDataSource>(),
      cache: JsonCache<AppConfig>(
        store: sl<ICacheStore>(),
        cacheKey: ApiEndpoints.appSettingsCacheKey,
        toJson: (s) => s.toJson(),
        fromJson: AppConfig.fromJson,
      ),
      imageSync: sl<ImageSyncService>(),
    ),
  );

  // Platform announcements
  sl.registerLazySingleton<IPlatformAnnouncementsRepository>(
    () => PlatformAnnouncementsRepository(
      dataSource: sl<MosqueRemoteDataSource>(),
      getActiveMosqueId: () => sl<IAuthRepository>().getActiveMosqueId(),
      displayCache: JsonCache<List<Announcement>>(
        store: sl<ICacheStore>(),
        cacheKey: ApiEndpoints.platformAnnouncementsCacheKey,
        toJson: (list) => {'items': list.map((a) => a.toJson()).toList()},
        fromJson: (m) => (m['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      ),
      settingsCache: JsonCache<List<SettingsAnnouncementModel>>(
        store: sl<ICacheStore>(),
        cacheKey: ApiEndpoints.settingsAnnouncementsCacheKey,
        toJson: (list) => {'items': list.map((a) => a.toMap()).toList()},
        fromJson: (m) => (m['items'] as List? ?? const [])
            .whereType<Map>()
            .map((e) {
              final map = Map<String, dynamic>.from(e);
              return SettingsAnnouncementModel.fromMap(
                  map, map['id']?.toString() ?? '');
            })
            .toList(),
      ),
    ),
  );
}
