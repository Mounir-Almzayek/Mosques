import '../../core/cache/cache.dart';
import '../datasources/app_config_remote_data_source.dart';
import '../models/app/app_config.dart';
import 'interfaces/app_config_repository_interface.dart';

/// Backend-native app launch config repository (`GET /mobile/app/bootstrap`).
/// Replaces the Firebase-era `AppSettingsRepository`.
class AppConfigRepository implements IAppConfigRepository {
  final AppConfigRemoteDataSource _dataSource;
  final CacheFirstLoader<AppConfig> _loader;

  AppConfigRepository({
    required AppConfigRemoteDataSource dataSource,
    required JsonCache<AppConfig> cache,
    ImageSyncService? imageSync,
  })  : _dataSource = dataSource,
        _loader = CacheFirstLoader<AppConfig>(
          cache,
          onValue: imageSync?.syncAppConfig,
        );

  @override
  Stream<AppConfig?> get streamAppConfig =>
      _loader.stream(remote: () => Stream.fromFuture(_dataSource.fetch()));

  @override
  Future<AppConfig?> getAppConfig() =>
      _loader.once(remote: _dataSource.fetch).last;
}
