import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/features.dart';
import 'package:template_app/utils/utils.dart';

part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  final PostLogin _postLogin;
  final AppStorageContract _storage;

  AuthCubit(this._postLogin, [AppStorageContract? storage])
    : _storage = storage ?? sl<AppStorageContract>(),
      super(const AuthState.initial());

  Future<void> login(LoginParams params) async {
    emit(const AuthStateLoading());
    final data = await _postLogin.call(params);

    data.fold(
      (l) => emit(AuthStateFailure(l.displayMessage)),
      (r) => emit(AuthStateSuccess(r.token)),
    );
  }

  /// Called when token refresh fails, 401 occurs or manual logout happens.
  Future<void> expireSession() async {
    await _storage.clearSession();
    _clearAppCaches();
    emit(const AuthState.unauthenticated());
  }

  void _clearAppCaches() {
    // Cubits are factory-registered, each navigation creates a fresh instance.
  }
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.success(String? data) = AuthStateSuccess;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.failure(String message) = AuthStateFailure;
}
