import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/features.dart';
import 'package:template_app/utils/utils.dart';

part 'post_login.freezed.dart';
part 'post_login.g.dart';

class PostLogin extends UseCase<Login, LoginParams> {
  final AuthRepository _repo;
  final AppStorageContract _storage;

  PostLogin(this._repo, [AppStorageContract? storage])
    : _storage = storage ?? sl<AppStorageContract>();

  @override
  Future<Either<Failure, Login>> call(LoginParams params) async {
    final result = await _repo.login(params);
    return await result.fold<Future<Either<Failure, Login>>>(
      (failure) async => Left(failure),
      (login) async {
        await _storage.saveTokens(
          access: login.token ?? '',
          refresh: login.refreshToken ?? '',
        );
        return Right(login);
      },
    );
  }
}

@freezed
sealed class LoginParams with _$LoginParams {
  const factory LoginParams({
    @Default('') String email,
    @Default('') String password,
    String? osInfo,
    String? deviceInfo,
    @Default('GeneratedFCMToken') String fcmToken,
    @Default('email') String loginType,
  }) = _LoginParams;

  factory LoginParams.fromJson(Map<String, dynamic> json) =>
      _$LoginParamsFromJson(json);
}
