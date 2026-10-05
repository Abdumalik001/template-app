import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/auth/auth.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, Login>> login(LoginParams params);

  Future<Either<Failure, Register>> register(RegisterParams params);

  Future<Either<Failure, GeneralToken>> generalToken(GeneralTokenParams params);

  Future<Either<Failure, String>> logout();
}
