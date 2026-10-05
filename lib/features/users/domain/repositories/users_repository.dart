import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/users/users.dart';
import 'package:dartz/dartz.dart';

abstract class UsersRepository {
  Future<Either<Failure, Users>> users(UsersParams usersParams);

  Future<Either<Failure, User>> user();
}
