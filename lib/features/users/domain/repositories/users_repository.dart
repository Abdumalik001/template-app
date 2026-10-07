import 'package:dartz/dartz.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/users/users.dart';

abstract class UsersRepository {
  Future<Either<Failure, Users>> users(UsersParams usersParams);

  Future<Either<Failure, User>> user();
}
