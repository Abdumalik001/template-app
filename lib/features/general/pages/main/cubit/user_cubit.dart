import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/features.dart';

part 'user_cubit.freezed.dart';

class UserCubit extends Cubit<UserState> {
  final GetUser _getUser;
  User? cachedUser;

  UserCubit(this._getUser) : super(const UserStateLoading());

  void clearCache() {
    cachedUser = null;
    if (!isClosed) {
      emit(const UserStateLoading());
    }
  }

  Future<void> getUser({bool force = false}) async {
    if (isClosed) {
      return;
    }
    if (cachedUser != null && !force) {
      emit(UserStateSuccess(cachedUser));
      return;
    }
    emit(const UserStateLoading());
    final data = await _getUser.call(const NoParams());
    if (isClosed) {
      return;
    }
    data.fold(
      (l) {
        if (!isClosed) {
          emit(UserStateFailure(l.displayMessage));
        }
      },
      (r) {
        cachedUser = r;
        if (!isClosed) {
          emit(UserStateSuccess(r));
        }
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
