import 'package:dartz/dartz.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/users/users.dart';

class GetUser extends UseCase<User, NoParams> {
  final UsersRepository _repo;

  // coverage:ignore-start
  GetUser(this._repo);

  @override
  Future<Either<Failure, User>> call(NoParams _) => _repo.user();
  // coverage:ignore-end
}
