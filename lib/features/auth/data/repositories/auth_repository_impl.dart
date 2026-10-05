import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/auth/auth.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  /// Data Source
  final AuthRemoteDatasource authRemoteDatasource;
  const AuthRepositoryImpl(this.authRemoteDatasource);

  @override
  Future<Either<Failure, Login>> login(LoginParams params) async {
    final response = await authRemoteDatasource.login(params);

    return response.fold<Either<Failure, Login>>((failure) => Left(failure),
        (loginResponse) {
      if (loginResponse.data == null) {
        return Left(NoDataFailure());
      }
      return Right(
        Login(
          token:
              '${loginResponse.data?.tokenType} ${loginResponse.data?.token}',
          refreshToken:
              '${loginResponse.data?.tokenType} ${loginResponse.data?.refreshToken}',
        ),
      );
    });
  }

  @override
  Future<Either<Failure, Register>> register(RegisterParams params) async {
    final response = await authRemoteDatasource.register(params);

    return response.fold<Either<Failure, Register>>(
      (failure) => Left(failure),
      (registerResponse) =>
          Right(Register(message: registerResponse.diagnostic?.message ?? '')),
    );
  }

  @override
  Future<Either<Failure, GeneralToken>> generalToken(
    GeneralTokenParams params,
  ) async {
    final response = await authRemoteDatasource.generalToken(params);

    return response.fold<Either<Failure, GeneralToken>>((failure) => Left(failure),
        (tokenResponse) {
      if (tokenResponse.data == null) {
        return Left(NoDataFailure());
      }
      return Right(
        GeneralToken(
          token:
              '${tokenResponse.data?.tokenType} ${tokenResponse.data?.token}',
        ),
      );
    });
  }

  @override
  Future<Either<Failure, String>> logout() async {
    final response = await authRemoteDatasource.logout();

    return response.fold<Either<Failure, String>>(
      (failure) => Left(failure),
      (loginResponse) => Right(loginResponse.diagnostic?.message ?? ''),
    );
  }
}
