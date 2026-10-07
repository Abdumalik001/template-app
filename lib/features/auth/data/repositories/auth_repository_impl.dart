import 'package:dartz/dartz.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/auth/auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  /// Data Source
  final AuthRemoteDatasource authRemoteDatasource;
  const AuthRepositoryImpl(this.authRemoteDatasource);

  @override
  Future<Either<Failure, Login>> login(LoginParams params) async {
    final response = await authRemoteDatasource.login(params);

    return response.fold<Either<Failure, Login>>((failure) => Left(failure), (
      loginResponse,
    ) {
      if (loginResponse.data == null) {
        return const Left(NoDataFailure());
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
  Future<Either<Failure, String>> logout() async {
    final response = await authRemoteDatasource.logout();

    return response.fold<Either<Failure, String>>(
      (failure) => Left(failure),
      (loginResponse) => Right(loginResponse.diagnostic?.message ?? ''),
    );
  }
}
