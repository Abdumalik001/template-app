import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/users/users.dart';
import 'package:dartz/dartz.dart';

class GetUser extends UseCase<User, NoParams> {
  final UsersRepository _repo;

  // coverage:ignore-start
  GetUser(this._repo);

  @override
  Future<Either<Failure, User>> call(NoParams _) => _repo.user();
  // coverage:ignore-end
}
