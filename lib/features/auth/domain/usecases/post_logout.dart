import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:dartz/dartz.dart';

class PostLogout extends UseCase<String, NoParams> with MainBoxMixin {
  final AuthRepository _repo;

  // coverage:ignore-start
  PostLogout(this._repo);

  @override
  Future<Either<Failure, String>> call(NoParams _) async {
    final result = await _repo.logout();
    return await result.fold<Future<Either<Failure, String>>>(
      (failure) async => Left(failure),
      (message) async {
        await logoutBox();
        return Right(message);
      },
    );
  }

  // coverage:ignore-end
}
