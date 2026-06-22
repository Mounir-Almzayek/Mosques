import 'dart:async';
import 'dart:convert';
import 'dart:math';

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Dio get raw => _dio;

  // ---------------------------------------------------------------------------
  // Interceptors
  // ---------------------------------------------------------------------------
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _ensureRequestId(options);
    options.extra['__request_started_at'] =
        DateTime.now().microsecondsSinceEpoch;
    final token = _tokens.accessToken;
    if (token != null && token.isNotEmpty && !_skipAuth(options)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    _logRequest(options, requestId);
    handler.next(options);
  }

  void _onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    handler.next(response);
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
        _logRefreshAttempt(err.requestOptions);
        await _runRefresh();
        final newToken = _tokens.accessToken;
        final retryOptions = err.requestOptions.copyWith(
          headers: {
            ...err.requestOptions.headers,
            if (newToken != null && newToken.isNotEmpty)
              'Authorization': 'Bearer $newToken',
          },
          extra: {...err.requestOptions.extra, '__retried_after_refresh': true},
        );
        final retried = await _dio.fetch<dynamic>(retryOptions);
        return handler.resolve(retried);
      } catch (refreshError) {
        // Refresh failed → drop session and propagate.
        await _tokens.clear();
        try {
          onSessionExpired?.call();
        } catch (_) {
          /* swallow callback errors */
        }
      }
    }
    _logError(err);
    handler.next(err);
  }

  Future<void> _runRefresh() {
    if (_refreshInFlight != null) return _refreshInFlight!.future;

    final completer = Completer<void>();
    _refreshInFlight = completer;

    () async {
      final refreshToken = _tokens.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.completeError(
          ApiException(
            code: 'unauthenticated',
            message: 'No refresh token available.',
          ),
        );
        return;
      }
      try {
        // Bypass interceptor by using a clean Dio instance for the refresh.
        final fresh = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            sendTimeout: ApiConfig.sendTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
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
    return _send(
      () => _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(
      () => _dio.post(
        path,
        data: body,
        queryParameters: query,
        options: Options(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(
      () => _dio.put(
        path,
        data: body,
        queryParameters: query,
        options: Options(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(
      () => _dio.patch(
        path,
        data: body,
        queryParameters: query,
        options: Options(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _send(
      () => _dio.delete(
        path,
        data: body,
        queryParameters: query,
        options: Options(headers: headers),
      ),
    );
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
          details: details is Map ? Map<String, dynamic>.from(details) : null,
          requestId: err['requestId']?.toString(),
        );
      }
    }
    return ApiException.malformed(response.statusCode, null);
  }

  // ---------------------------------------------------------------------------
  // Request tracking logs
  // ---------------------------------------------------------------------------
  String _ensureRequestId(RequestOptions options) {
    final existing = options.headers['X-Request-ID']?.toString();
    if (existing != null && existing.isNotEmpty) return existing;
    final requestId = _newRequestId();
    options.headers['X-Request-ID'] = requestId;
    return requestId;
  }

  String _newRequestId() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = Random().nextInt(0xFFFFFF).toRadixString(36).padLeft(5, '0');
    return 'mob_$now$random';
  }

  void _logRequest(RequestOptions options, String requestId) {
    if (!kDebugMode) return;
    debugPrint(
      '[HTTP -->] $requestId ${options.method} ${_safePath(options)} '
      'base=${options.baseUrl}',
    );
    final payload = _safePayload(options.data);
    if (payload != null) debugPrint('[HTTP payload] $requestId $payload');
  }

  void _logResponse(Response<dynamic> response) {
    if (!kDebugMode) return;
    final options = response.requestOptions;
    final requestId = _responseRequestId(response);
    debugPrint(
      '[HTTP <--] $requestId ${options.method} ${_safePath(options)} '
      'status=${response.statusCode ?? '-'} duration=${_durationMs(options)}ms',
    );
    final payload = _safePayload(response.data);
    if (payload != null) debugPrint('[HTTP response] $requestId $payload');
  }

  void _logError(DioException err) {
    if (!kDebugMode) return;
    final options = err.requestOptions;
    final requestId = err.response == null
        ? options.headers['X-Request-ID']?.toString()
        : _responseRequestId(err.response!);
    final effectiveRequestId = requestId ?? 'request_unset';
    debugPrint(
      '[HTTP ERR] $effectiveRequestId ${options.method} ${_safePath(options)} '
      'status=${err.response?.statusCode ?? '-'} type=${err.type.name} '
      'duration=${_durationMs(options)}ms message=${err.message ?? '-'}',
    );
    final payload = _safePayload(err.response?.data);
    if (payload != null) {
      debugPrint('[HTTP error response] $effectiveRequestId $payload');
    }
  }

  void _logRefreshAttempt(RequestOptions options) {
    if (!kDebugMode) return;
    debugPrint(
      '[HTTP RETRY] ${options.headers['X-Request-ID'] ?? 'request_unset'} '
      '${options.method} ${_safePath(options)} refreshing token after 401',
    );
  }

  String _responseRequestId(Response<dynamic> response) {
    final header = response.headers.value('X-Request-ID');
    if (header != null && header.isNotEmpty) return header;
    final body = response.data;
    if (body is Map) {
      final meta = body['meta'];
      if (meta is Map && meta['requestId'] != null) {
        return meta['requestId'].toString();
      }
      final error = body['error'];
      if (error is Map && error['requestId'] != null) {
        return error['requestId'].toString();
      }
    }
    return response.requestOptions.headers['X-Request-ID']?.toString() ??
        'request_unset';
  }

  int _durationMs(RequestOptions options) {
    final startedAt = options.extra['__request_started_at'];
    if (startedAt is! int) return -1;
    final elapsedMicros = DateTime.now().microsecondsSinceEpoch - startedAt;
    return (elapsedMicros / 1000).round();
  }

  String _safePath(RequestOptions options) {
    final query = Map<String, dynamic>.from(options.queryParameters)
      ..removeWhere((key, _) => _isSensitiveKey(key));
    final uri = Uri(
      path: options.path,
      queryParameters: query.isEmpty
          ? null
          : query.map((key, value) => MapEntry(key, value?.toString())),
    );
    return uri.toString();
  }

  bool _isSensitiveKey(Object key) {
    final value = key.toString().toLowerCase();
    return value.contains('token') ||
        value.contains('password') ||
        value.contains('secret') ||
        value.contains('authorization');
  }

  String? _safePayload(Object? payload) {
    if (payload == null) return null;
    Object? safeValue;
    if (payload is FormData) {
      safeValue = {
        'fields': {
          for (final field in payload.fields)
            if (!_isSensitiveKey(field.key)) field.key: field.value,
        },
        'files': payload.files
            .map(
              (file) => {
                'field': file.key,
                'filename': file.value.filename,
                'contentType': file.value.contentType?.toString(),
                'length': file.value.length,
              },
            )
            .toList(),
      };
    } else {
      safeValue = _redactSensitive(payload);
    }
    return _truncate(_stringify(safeValue));
  }

  Object? _redactSensitive(Object? value) {
    if (value is Map) {
      return value.map((key, nested) {
        if (_isSensitiveKey(key)) return MapEntry(key.toString(), '<redacted>');
        return MapEntry(key.toString(), _redactSensitive(nested));
      });
    }
    if (value is Iterable) return value.map(_redactSensitive).toList();
    return value;
  }

  String _stringify(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  String _truncate(String value, {int maxChars = 4000}) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars)}... <truncated ${value.length - maxChars} chars>';
  }
}
