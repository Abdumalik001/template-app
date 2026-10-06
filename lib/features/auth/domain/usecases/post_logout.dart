import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:dartz/dartz.dart';

class PostLogout extends UseCase<String, NoParams> {
  final AuthRepository _repo;
  final AppStorageContract _storage;

  // coverage:ignore-start
  PostLogout(this._repo, [AppStorageContract? storage])
      : _storage = storage ?? sl<AppStorageContract>();

  @override
  Future<Either<Failure, String>> call(NoParams _) async {
    final result = await _repo.logout();
    return await result.fold<Future<Either<Failure, String>>>(
      (failure) async => Left(failure),
      (message) async {
        await _storage.clearSession();
        return Right(message);
      },
    );
  }

  // coverage:ignore-end
}
