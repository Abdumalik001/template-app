import 'package:cactus_hr/core/core.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Class to handle when useCase don't need params
class NoParams {
  const NoParams();
}
