import 'package:dio/dio.dart';
import '../network/dio_provider.dart';

class AppUpdateRepository {
  AppUpdateRepository._();

  static Future<void> downloadUpdate({
    required String url,
    required String savePath,
    Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    await DioProvider.instance.downloadFile(
      url,
      savePath,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
