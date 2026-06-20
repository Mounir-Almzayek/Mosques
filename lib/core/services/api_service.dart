import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Thin Dio wrapper for the mosque backend.
///
/// Responsibilities:
///   * attach `Authorization: Bearer <accessToken>` when present;
///   * unwrap the unified envelope (`{success, data, error, meta}`) and
///     translate failures into [ApiException];
///   * on 401, run a single refresh round, then retry the failed request once;
///   * surface raw [Dio] failures (timeouts, no network) as
///     `ApiException.network`.
///
/// The class does NOT know about specific routes; callers pass paths directly.
class ApiService {
  final Dio _dio;
  final TokenStorage _tokens;

  /// Optional hook fired when refresh ultimately fails so the app can route
  /// the user back to the login screen.
  void Function()? onSessionExpired;

  Completer<void>? _refreshInFlight;

  ApiService({required TokenStorage tokens, Dio? dio})
      : _tokens = tokens,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = ApiConfig.connectTimeout
      ..receiveTimeout = ApiConfig.receiveTimeout
      ..sendTimeout = ApiConfig.sendTimeout
      ..responseType = ResponseType.json
      ..headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Dio get raw => _dio;

  // ---------------------------------------------------------------------------
  // Interceptors
  // ---------------------------------------------------------------------------
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _tokens.accessToken;
    if (token != null && token.isNotEmpty && !_skipAuth(options)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  bool _skipAuth(RequestOptions options) {
    final path = options.path;
    return path == ApiEndpoints.authLogin ||
        path == ApiEndpoints.authRefresh ||
        path == ApiEndpoints.appBootstrap;
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final status = response?.statusCode;
    final extra = err.requestOptions.extra;
    final alreadyRetried = extra['__retried_after_refresh'] == true;

    // 401 with a refresh token available → refresh, then retry once.
    if (status == 401 &&
        !alreadyRetried &&
        !_skipAuth(err.requestOptions) &&
        (_tokens.refreshToken?.isNotEmpty ?? false)) {
      try {
        await _runRefresh();
        final newToken = _tokens.accessToken;
        final retryOptions = err.requestOptions.copyWith(
          headers: {
            ...err.requestOptions.headers,
            if (newToken != null && newToken.isNotEmpty)
              'Authorization': 'Bearer $newToken',
          },
          extra: {
            ...err.requestOptions.extra,
            '__retried_after_refresh': true,
          },
        );
        final retried = await _dio.fetch<dynamic>(retryOptions);
        return handler.resolve(retried);
      } catch (refreshError) {
        // Refresh failed → drop session and propagate.
        await _tokens.clear();
        try {
          onSessionExpired?.call();
        } catch (_) {/* swallow callback errors */}
      }
    }
    handler.next(err);
  }

  Future<void> _runRefresh() {
    if (_refreshInFlight != null) return _refreshInFlight!.future;

    final completer = Completer<void>();
    _refreshInFlight = completer;

    () async {
      final refreshToken = _tokens.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.completeError(ApiException(
          code: 'unauthenticated',
          message: 'No refresh token available.',
        ));
        return;
      }
      try {
        // Bypass interceptor by using a clean Dio instance for the refresh.
        final fresh = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          sendTimeout: ApiConfig.sendTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));
        final res = await fresh.post(
          ApiEndpoints.authRefresh,
          data: {'refreshToken': refreshToken},
        );
        final body = res.data;
        if (body is! Map || body['success'] != true) {
          throw ApiException(
            code: 'token_expired',
            message: 'Refresh rejected by server.',
            statusCode: res.statusCode,
          );
        }
        final data = (body['data'] as Map?)?.cast<String, dynamic>();
        final newAccess = data?['accessToken'] as String?;
        final newRefresh = data?['refreshToken'] as String?;
        final expiresInSeconds = (data?['expiresInSeconds'] as num?)?.toInt();
        if (newAccess == null || newAccess.isEmpty) {
          throw ApiException(
            code: 'malformed_response',
            message: 'Refresh response missing accessToken.',
          );
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await _tokens.save(
            accessToken: newAccess,
            refreshToken: newRefresh,
            expiresInSeconds: expiresInSeconds,
          );
        } else {
          await _tokens.updateAccessToken(
            accessToken: newAccess,
            expiresInSeconds: expiresInSeconds,
          );
        }
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      } finally {
        _refreshInFlight = null;
      }
    }();

    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // Public surface — every method returns the unwrapped `data` payload.
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(() => _dio.get(
          path,
          queryParameters: query,
          options: Options(headers: headers),
        ));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(() => _dio.post(
          path,
          data: body,
          queryParameters: query,
          options: Options(headers: headers),
        ));
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(() => _dio.put(
          path,
          data: body,
          queryParameters: query,
          options: Options(headers: headers),
        ));
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(() => _dio.patch(
          path,
          data: body,
          queryParameters: query,
          options: Options(headers: headers),
        ));
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(() => _dio.delete(
          path,
          data: body,
          queryParameters: query,
          options: Options(headers: headers),
        ));
  }

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() invoke,
  ) async {
    Response<dynamic> response;
    try {
      response = await invoke();
    } on DioException catch (e) {
      // 4xx/5xx with a body → translate via envelope.
      if (e.response != null && e.response!.data is Map) {
        throw _unwrapError(e.response!);
      }
      if (kDebugMode) {
        debugPrint('ApiService network failure: ${e.type} ${e.message}');
      }
      throw ApiException.network(e);
    } catch (e) {
      throw ApiException.network(e);
    }

    final body = response.data;
    if (body is! Map) {
      throw ApiException.malformed(response.statusCode, null);
    }
    if (body['success'] == false) {
      throw _unwrapError(response);
    }
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    // Some endpoints return `data: null` or a primitive. Normalise to {}.
    return <String, dynamic>{};
  }

  ApiException _unwrapError(Response response) {
    final body = response.data;
    if (body is Map) {
      final err = body['error'];
      if (err is Map) {
        final details = err['details'];
        return ApiException(
          code: err['code']?.toString() ?? 'unknown_error',
          message: err['message']?.toString() ?? 'Unknown error.',
          statusCode: response.statusCode,
          details: details is Map
              ? Map<String, dynamic>.from(details)
              : null,
          requestId: err['requestId']?.toString(),
        );
      }
    }
    return ApiException.malformed(response.statusCode, null);
  }
}
