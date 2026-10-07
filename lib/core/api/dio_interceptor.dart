import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/auth/auth.dart';
import 'package:template_app/utils/utils.dart';

// coverage:ignore-start
class DioInterceptor extends Interceptor with FirebaseCrashLogger {
  static const _skipRefreshKey = 'skipAuthRefresh';
  static Future<bool>? _activeRefresh;

  final Dio Function() _dioFactory;
  final Future<void> Function()? _onLogout;
  final String Function() _deviceInfo;
  final AppStorageContract _storage;

  DioInterceptor({
    Dio Function()? dioFactory,
    this._onLogout,
    String Function()? deviceInfo,
    AppStorageContract? storage,
  }) : _dioFactory = dioFactory ?? (() => DioClient().dio),
       _deviceInfo = deviceInfo ?? (() => Platform.localHostname),
       _storage = storage ?? sl<AppStorageContract>();

  static const requireAuthKey = 'requireAuth';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requireAuth = options.extra[requireAuthKey] as bool? ?? true;
    if (requireAuth) {
      final token = _storage.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = token;
      }
    } else {
      options.headers.remove('Authorization');
    }

    String headerMessage = '';
    options.headers.forEach((k, v) => headerMessage += '► $k: $v\n');

    try {
      options.queryParameters.forEach((k, v) => debugPrint('► $k: $v'));
    } catch (_) {}
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(options.data);
      log.d(
        "REQUEST ► ︎ ${options.method.toUpperCase()} ${"${options.baseUrl}${options.path}"}\n\n"
        'Headers:\n'
        '$headerMessage\n'
        '❖ QueryParameters : \n'
        'Body: $prettyJson',
      );
    } catch (e, stackTrace) {
      log.e('Failed to extract json request $e');
      nonFatalError(error: e, stackTrace: stackTrace);
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException dioException,
    ErrorInterceptorHandler handler,
  ) async {
    log.e(
      "<-- ${dioException.message} ${dioException.response?.requestOptions != null ? (dioException.response!.requestOptions.baseUrl + dioException.response!.requestOptions.path) : 'URL'}\n\n"
      "${dioException.response != null ? dioException.response!.data : 'Unknown Error'}",
    );

    nonFatalError(error: dioException, stackTrace: dioException.stackTrace);
    if (dioException.response?.statusCode == 401) {
      final retryResponse = await _refreshAndRetry(dioException.requestOptions);
      if (retryResponse != null) {
        return handler.resolve(retryResponse);
      }
    }
    return handler.next(dioException);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final authToken = _storage.token;
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'authorization');
    if (authToken != null) {
      headers['Authorization'] = authToken;
    }

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      extra: {...requestOptions.extra, _skipRefreshKey: true},
    );

    final dio = _dioFactory()..options.baseUrl = requestOptions.baseUrl;
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
    );
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.refreshToken;
    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await _dioFactory().post<dynamic>(
        ListAPI.refreshToken,
        data: {
          'refreshToken': refreshToken,
          'deviceInfo': _deviceInfo(),
          'fcmToken': _storage.fcm ?? 'GeneratedFCMToken',
        },
        options: Options(extra: const {_skipRefreshKey: true}),
      );

      if ((response.statusCode ?? 0) < 200 ||
          (response.statusCode ?? 0) > 201 ||
          response.data is! Map<String, dynamic>) {
        return false;
      }

      final data = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      ).data;
      if (data?.token == null ||
          data?.refreshToken == null ||
          data?.tokenType == null) {
        return false;
      }

      await _storage.saveTokens(
        access: '${data!.tokenType} ${data.token}',
        refresh: '${data.tokenType} ${data.refreshToken}',
      );
      return true;
    } catch (error, stackTrace) {
      nonFatalError(error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<Response<dynamic>?> _refreshAndRetry(
    RequestOptions requestOptions,
  ) async {
    if (!_canRefresh(requestOptions)) {
      return null;
    }

    final didRefresh = await _refreshOnce();
    if (!didRefresh) {
      await _logout();
      return null;
    }

    try {
      return await _retry(requestOptions);
    } catch (error, stackTrace) {
      nonFatalError(error: error, stackTrace: stackTrace);
      return null;
    }
  }

  bool _canRefresh(RequestOptions requestOptions) {
    if (requestOptions.extra[_skipRefreshKey] == true ||
        requestOptions.path.startsWith('/api/auth/')) {
      return false;
    }
    final authorization = requestOptions.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'authorization')
        .firstOrNull
        ?.value
        .toString();
    return authorization != null && (_storage.token?.isNotEmpty ?? false);
  }

  Future<bool> _refreshOnce() async {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) {
      return await activeRefresh;
    }

    final refresh = refreshToken();
    _activeRefresh = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_activeRefresh, refresh)) {
        _activeRefresh = null;
      }
    }
  }

  Future<void> _logout() => _onLogout?.call() ?? _storage.clearSession();

  Future<void> _handleUnauthorizedResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final retryResponse = await _refreshAndRetry(response.requestOptions);
    if (retryResponse != null) {
      handler.resolve(retryResponse);
      return;
    }
    handler.next(response);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String headerMessage = '';
    response.headers.forEach((k, v) => headerMessage += '► $k: $v\n');

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(response.data);
    log.d(
      '◀ ︎RESPONSE ${response.statusCode} ${response.requestOptions.baseUrl + response.requestOptions.path}\n\n'
      'Headers:\n'
      '$headerMessage\n'
      '❖ Results : \n'
      'Response: $prettyJson',
    );
    if (response.statusCode == 401) {
      _handleUnauthorizedResponse(response, handler);
      return;
    }
    super.onResponse(response, handler);
  }
}

// coverage:ignore-end
