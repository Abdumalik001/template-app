import 'package:template_app/core/localization/app_locale.dart';

abstract class Failure {
  final String? message;

  const Failure([this.message]);

  /// Returns user-friendly message for UI display.
  String get displayMessage => message ?? appStrings.errorUnknown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          other.message == message;

  @override
  int get hashCode => message.hashCode;
}

/// Server returned an error (4xx, 5xx) with an explicit message.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  String get displayMessage => message ?? appStrings.errorServer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerFailure &&
          other.message == message &&
          other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}

/// Internet connection unavailable (SocketException, DNS resolution failure).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);

  @override
  String get displayMessage => message ?? appStrings.errorNetwork;
}

/// Request timed out (connection timeout, receive timeout, send timeout).
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message]);

  @override
  String get displayMessage => message ?? appStrings.errorTimeout;
}

/// Unauthorized / Session expired (401).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message]);

  @override
  String get displayMessage => message ?? appStrings.errorUnauthorized;
}

/// Data payload is empty or not found.
class NoDataFailure extends Failure {
  const NoDataFailure([super.message]);

  @override
  String get displayMessage => message ?? appStrings.errorNoData;
}

/// Local storage / Hive / SecureStorage read-write failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

/// Unknown / unexpected system error.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);

  @override
  String get displayMessage => message ?? appStrings.errorUnknown;
}
