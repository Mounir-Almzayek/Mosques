import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_exception.dart';
import '../../core/services/api_service.dart';
import '../models/app/app_config.dart';

/// Reads the public app launch config from `GET /mobile/app/bootstrap`,
/// returning a typed [AppConfig].
class AppConfigRemoteDataSource {
  final ApiService _api;

  AppConfigRemoteDataSource({required ApiService api}) : _api = api;

  Future<AppConfig?> fetch() async {
    try {
      final raw = await _api.get(ApiEndpoints.appBootstrap);
      return AppConfig.fromJson(raw);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
