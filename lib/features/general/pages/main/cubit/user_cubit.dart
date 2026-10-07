import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_cubit.freezed.dart';

class UserCubit extends Cubit<UserState> {
  final GetUser _getUser;
  User? cachedUser;

  UserCubit(this._getUser) : super(const UserStateLoading());

  Future<void> getUser({bool force = false}) async {
    if (cachedUser != null && !force) {
      emit(UserStateSuccess(cachedUser));
      return;
    }
    emit(const UserStateLoading());
    final data = await _getUser.call(const NoParams());
    data.fold(
      (l) => emit(UserStateFailure(l is ServerFailure ? l.message ?? '' : '')),
      (r) {
        cachedUser = r;
        emit(UserStateSuccess(r));
      },
    );
  }
}

@freezed
sealed class UserState with _$UserState {
  const factory UserState.loading() = UserStateLoading;
  const factory UserState.failure(String message) = UserStateFailure;
  const factory UserState.success(User? data) = UserStateSuccess;
}
