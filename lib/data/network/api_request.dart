import 'package:dio/dio.dart';
import '../../features/auth/repository/auth_local_repository.dart';
import '../../features/splash/repositories/settings_local_repository.dart';
import 'api_config.dart';
import 'dio_provider.dart';

/// Enum to specify the HTTP method used in a request.
enum HTTPMethod { get, post, delete, put, patch }

/// Enum to specify the type of body sent:
enum BodyType { data, formData }

/// Enum to specify the type of request:
enum RequestType { request, download }

/// Enum to specify the shape of the sent data:
enum DataShape { map, list, none }

/// Enum to specify whether the request requires authorization:
enum AuthorizationOption { authorized, unauthorized }

/// Extension that converts HTTPMethod enum values to their corresponding string representations.
extension HTTPMethodString on HTTPMethod {
  String get string {
    switch (this) {
      case HTTPMethod.get:
        return "get";
      case HTTPMethod.post:
        return "post";
      case HTTPMethod.delete:
        return "delete";
      case HTTPMethod.patch:
        return "patch";
      case HTTPMethod.put:
        return "put";
    }
  }
}

/// APIRequest class that constructs and sends HTTP requests.
class APIRequest {
  String? baseUrl;
  String get fullUrl => (baseUrl ?? APIConfig.appAPI) + path;
  String path;
  HTTPMethod method;
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String>? additionalHeaders;
  Map<String, String>? query;
  dynamic body;
  BodyType bodyType;
  RequestType requestType;
  AuthorizationOption authorizationOption;
  String? fileUrl;
  String? savePath;
  String? _cachedToken;

  Future<String> get token async {
    _cachedToken ??= AuthLocalRepository.retrieveToken();
    return _cachedToken ?? "";
  }

  bool isSendingVersion;
  bool isSendingPlatform;

  APIRequest({
    required this.path,
    required this.method,
    this.baseUrl,
    this.additionalHeaders,
    this.query,
    this.body,
    this.bodyType = BodyType.data,
    this.requestType = RequestType.request,
    this.authorizationOption = AuthorizationOption.authorized,
    this.fileUrl,
    this.isSendingVersion = false,
    this.isSendingPlatform = false,
    this.savePath,
  }) {
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders!);
    }

    try {
      headers['Accept-Language'] =
          SettingsLocalRepository.loadLanguage().languageCode;
    } catch (e) {
      headers['Accept-Language'] = 'en';
    }

    switch (bodyType) {
      case BodyType.formData:
        body = FormData.fromMap(body);
        break;
      case BodyType.data:
        break;
    }

    query ??= {};

    switch (requestType) {
      case RequestType.download:
        assert(
          fileUrl != null && fileUrl!.isNotEmpty,
          "File URL must be provided for download requests",
        );
        assert(
          savePath != null && savePath!.isNotEmpty,
          "Save path must be provided for download requests",
        );
        break;
      case RequestType.request:
        break;
    }
  }

  Future<dynamic> send({CancelToken? cancelToken}) async {
    if (authorizationOption == AuthorizationOption.authorized) {
      final tokenValue = await token;
      if (tokenValue.isNotEmpty) {
        headers['Authorization'] = "Bearer $tokenValue";
      } else {
        headers.remove('Authorization');
      }
    } else {
      headers.remove('Authorization');
    }

    if (requestType == RequestType.request) {
      return DioProvider.instance.request(this, cancelToken: cancelToken);
    } else if (requestType == RequestType.download) {
      return DioProvider.instance.downloadFile(
        fileUrl!,
        savePath!,
        cancelToken: cancelToken,
      );
    } else {
      throw Exception("Invalid request type");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'path': path,
      'method': method.string,
      'headers': headers,
      'additionalHeaders': additionalHeaders,
      'query': query,
      'body': body,
      'bodyType': bodyType.name,
      'requestType': requestType.name,
      'authorizationOption': authorizationOption.name,
      'fileUrl': fileUrl,
      'savePath': savePath,
      'isSendingVersion': isSendingVersion,
      'isSendingPlatform': isSendingPlatform,
    };
  }

  factory APIRequest.fromJson(Map<String, dynamic> json) {
    return APIRequest(
      path: json['path'] as String,
      method: HTTPMethod.values.firstWhere(
        (e) => e.string == json['method'],
        orElse: () => HTTPMethod.get,
      ),
      baseUrl: json['baseUrl'] as String?,
      additionalHeaders: json['additionalHeaders'] != null
          ? Map<String, String>.from(json['additionalHeaders'] as Map)
          : null,
      query: json['query'] != null
          ? Map<String, String>.from(json['query'] as Map)
          : null,
      body: json['body'],
      bodyType: BodyType.values.firstWhere(
        (e) => e.name == json['bodyType'],
        orElse: () => BodyType.data,
      ),
      requestType: RequestType.values.firstWhere(
        (e) => e.name == json['requestType'],
        orElse: () => RequestType.request,
      ),
      authorizationOption: AuthorizationOption.values.firstWhere(
        (e) => e.name == json['authorizationOption'],
        orElse: () => AuthorizationOption.authorized,
      ),
      fileUrl: json['fileUrl'] as String?,
      savePath: json['savePath'] as String?,
      isSendingVersion: json['isSendingVersion'] as bool? ?? false,
      isSendingPlatform: json['isSendingPlatform'] as bool? ?? false,
    );
  }
}
