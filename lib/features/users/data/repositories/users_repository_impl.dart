import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/users/users.dart';
import 'package:dartz/dartz.dart';

class UsersRepositoryImpl implements UsersRepository {
  /// Data Source
  final UsersRemoteDatasource usersRemoteDatasource;

  const UsersRepositoryImpl(this.usersRemoteDatasource);

  @override
  Future<Either<Failure, Users>> users(UsersParams usersParams) async {
    final response = await usersRemoteDatasource.users(usersParams);

    return response.fold<Either<Failure, Users>>((failure) => Left(failure),
        (usersResponse) {
      if (usersResponse.data?.isEmpty ?? true) {
        return Left(NoDataFailure()); //coverage:ignore-line
      }
      return Right(
        Users(
          users: usersResponse.data
              ?.map(
                (data) => User(
                  name: data.name,
                  email: data.email,
                  avatar: data.photo,
                  isVerified: data.verified,
                  updatedAt: data.updatedAt,
                ),
              )
              .toList(),
          currentPage: usersResponse.page?.currentPage,
          lastPage: usersResponse.page?.lastPage,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, User>> user() async {
    final response = await usersRemoteDatasource.user();

    return response.fold<Either<Failure, User>>((failure) => Left(failure),
        (userResponse) {
      if (userResponse.data == null) {
        return Left(NoDataFailure());
      }
      return Right(
        User(
          name: userResponse.data?.name,
          email: userResponse.data?.email,
          avatar: userResponse.data?.photo,
          isVerified: userResponse.data?.verified,
          updatedAt: userResponse.data?.updatedAt,
        ),
      );
    });
  }
}
