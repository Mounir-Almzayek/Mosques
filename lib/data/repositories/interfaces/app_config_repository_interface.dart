import '../../models/app/app_config.dart';

abstract class IAppConfigRepository {
  Future<AppConfig?> getAppConfig();
  Stream<AppConfig?> get streamAppConfig;
}
