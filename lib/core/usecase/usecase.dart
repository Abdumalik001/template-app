import 'package:dartz/dartz.dart';
import 'package:template_app/core/core.dart';

abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Class to handle when useCase don't need params
class NoParams {
  const NoParams();
}
