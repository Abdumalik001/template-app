import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/utils/utils.dart';

typedef ResponseConverter<T> = T Function(dynamic response);

class DioClient with FirebaseCrashLogger {
  final String baseUrl;

  final bool isUnitTest;
  final Future<void> Function()? onLogout;
  late final Dio _dio;

  DioClient({this.isUnitTest = false, String? baseUrl, this.onLogout})
    : baseUrl = baseUrl ?? const String.fromEnvironment('BASE_URL') {
    _dio = Dio(
      BaseOptions(
        baseUrl: this.baseUrl,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        receiveTimeout: const Duration(minutes: 1),
        connectTimeout: const Duration(minutes: 1),
        validateStatus: (int? status) => status != null && status > 0,
      ),
    );

    if (!isUnitTest) {
      _dio.interceptors.add(
        DioInterceptor(dioFactory: () => _dio, onLogout: onLogout),
      );
    }
  }

  /// Returns the underlying [Dio] instance with connection pooling enabled.
  Dio get dio => _dio;

  Future<Either<Failure, T>> getRequest<T>(
    String url, {
    required ResponseConverter<T> converter,
    Map<String, dynamic>? queryParameters,
    bool isIsolate = true,
    bool includeAuthorization = true,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          extra: {DioInterceptor.requireAuthKey: includeAuthorization},
        ),
      );
      if ((response.statusCode ?? 0) < 200 ||
          (response.statusCode ?? 0) > 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }

      if (!isIsolate) {
        return Right(converter(response.data));
      }
      final isolateParse = IsolateParser<T>(
        response.data as Map<String, dynamic>,
        converter,
      );
      final result = await isolateParse.parseInBackground();
      return Right(result);
    } on DioException catch (e, stackTrace) {
      if (!isUnitTest) {
        nonFatalError(error: e, stackTrace: stackTrace);
      }
      return Left(DioErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, T>> postRequest<T>(
    String url, {
    required ResponseConverter<T> converter,
    Map<String, dynamic>? data,
    bool isIsolate = true,
    bool includeAuthorization = true,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          extra: {DioInterceptor.requireAuthKey: includeAuthorization},
        ),
      );
      if ((response.statusCode ?? 0) < 200 ||
          (response.statusCode ?? 0) > 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }

      if (!isIsolate) {
        return Right(converter(response.data));
      }
      final isolateParse = IsolateParser<T>(
        response.data as Map<String, dynamic>,
        converter,
      );
      final result = await isolateParse.parseInBackground();
      return Right(result);
    } on DioException catch (e, stackTrace) {
      if (!isUnitTest) {
        nonFatalError(error: e, stackTrace: stackTrace);
      }
      return Left(DioErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
