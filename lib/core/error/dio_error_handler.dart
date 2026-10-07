import 'dart:io';

import 'package:dio/dio.dart';
import 'package:template_app/core/error/failure.dart';
import 'package:template_app/core/localization/app_locale.dart';

class DioErrorHandler {
  DioErrorHandler._();

  /// Converts any [DioException] into a domain [Failure].
  static Failure handle(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutFailure(appStrings.errorTimeout);

      case DioExceptionType.connectionError:
        return NetworkFailure(appStrings.errorNetwork);

      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final responseData = exception.response?.data;

        if (statusCode == 401) {
          return UnauthorizedFailure(
            _extractMessage(responseData) ?? appStrings.errorUnauthorized,
          );
        }

        final serverMsg = _extractMessage(responseData) ?? exception.message;
        return ServerFailure(serverMsg, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled');

      case DioExceptionType.badCertificate:
        return const ServerFailure('Bad SSL certificate');

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return NetworkFailure(appStrings.errorNetwork);
        }
        return UnknownFailure(exception.message ?? appStrings.errorUnknown);
    }
  }

  /// Extracts readable error message from common backend response structures:
  /// - { "diagnostic": { "message": "..." } }
  /// - { "message": "..." }
  /// - { "error": "..." }
  /// - { "detail": "..." }
  static String? _extractMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      if (data['diagnostic'] is Map && data['diagnostic']['message'] != null) {
        return data['diagnostic']['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }
}
