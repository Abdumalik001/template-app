import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/features.dart';

part 'users_cubit.freezed.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._getUser) : super(const UsersStateLoading());

  int currentPage = 1;
  int lastPage = 1;
  final List<User> users = [];

  final GetUsers _getUser;

  void clearCache() {
    users.clear();
    currentPage = 1;
    lastPage = 1;
    if (!isClosed) {
      emit(const UsersStateLoading());
    }
  }

  Future<void> refresh() async {
    /// reset data
    users.clear();

    /// reset page
    currentPage = 1;
    lastPage = 1;

    /// fetch data
    await fetchUsers(UsersParams(page: currentPage), force: true);
  }

  Future<void> nextPage() async {
    if (currentPage < lastPage) {
      currentPage++;
      await fetchUsers(UsersParams(page: currentPage));
    }
  }

  Future<void> fetchUsers(UsersParams usersParams, {bool force = false}) async {
    if (isClosed) {
      return;
    }
    if (currentPage == 1 && users.isEmpty) {
      emit(const UsersStateLoading());
    } else if (users.isNotEmpty && !force) {
      // If already loaded and not forced, ensure current state is success
      if (!isClosed) {
        emit(
          UsersStateSuccess(
            Users(currentPage: currentPage, lastPage: lastPage, users: users),
          ),
        );
      }
      return;
    }

    final data = await _getUser.call(usersParams);
    if (isClosed) {
      return;
    }
    data.fold(
      (l) {
        if (isClosed) {
          return;
        }
        if (l is NoDataFailure) {
          emit(const UsersStateEmpty());
        } else {
          emit(UsersStateFailure(l.displayMessage));
        }
      },
      (r) {
        if (isClosed) {
          return;
        }
        users.addAll(r.users ?? []);
        currentPage = r.currentPage ?? 1;
        lastPage = r.lastPage ?? 1;

        final updatedUsers = Users(
          currentPage: currentPage,
          lastPage: lastPage,
          users: users,
        );

        if (currentPage != 1) {
          emit(const UsersStateInitial());
        }
        if (!isClosed) {
          emit(UsersStateSuccess(updatedUsers));
        }
      },
    );
  }
}

@freezed
sealed class UsersState with _$UsersState {
  const factory UsersState.loading() = UsersStateLoading;

  const factory UsersState.initial() = UsersStateInitial;

  const factory UsersState.success(Users data) = UsersStateSuccess;

  const factory UsersState.failure(String message) = UsersStateFailure;

  const factory UsersState.empty() = UsersStateEmpty;
}
