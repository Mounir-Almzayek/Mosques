import '../../models/app/app_settings_model.dart';

abstract class IAppSettingsRepository {
  Future<AppSettingsModel?> getAppSettings();
  Stream<AppSettingsModel?> get streamAppSettings;
}
