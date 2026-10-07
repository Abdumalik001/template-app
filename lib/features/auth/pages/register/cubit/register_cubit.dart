import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template_app/features/features.dart';

part 'register_cubit.freezed.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final PostRegister _postRegister;

  RegisterCubit(this._postRegister) : super(const RegisterStateLoading());

  Future<void> register(RegisterParams params) async {
    emit(const RegisterStateLoading());
    final data = await _postRegister.call(params);
    data.fold(
      (l) => emit(RegisterStateFailure(l.displayMessage)),
      (r) => emit(RegisterStateSuccess(r)),
    );
  }
}

@freezed
sealed class RegisterState with _$RegisterState {
  const factory RegisterState.loading() = RegisterStateLoading;
  const factory RegisterState.success(Register? data) = RegisterStateSuccess;
  const factory RegisterState.failure(String message) = RegisterStateFailure;
}
