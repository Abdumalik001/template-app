import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/utils/utils.dart';

enum AppStatus { authenticated, unauthenticated }

class MainCubit extends Cubit<AppStatus> {
  final AppStorageContract _storage;
  StreamSubscription<bool>? _subscription;

  MainCubit({AppStorageContract? storage})
    : _storage = storage ?? sl<AppStorageContract>(),
      super(
        (storage ?? sl<AppStorageContract>()).isLoggedIn
            ? AppStatus.authenticated
            : AppStatus.unauthenticated,
      ) {
    _subscription = _storage.isLoggedInStream.listen((isLoggedIn) {
      if (isLoggedIn) {
        emit(AppStatus.authenticated);
      } else {
        emit(AppStatus.unauthenticated);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.logout();
        });
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
