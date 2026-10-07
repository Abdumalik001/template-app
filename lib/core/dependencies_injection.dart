import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/api/api.dart';
import 'package:template_app/core/bloc/main_cubit.dart';
import 'package:template_app/core/localization/localization.dart';
import 'package:template_app/features/features.dart';
import 'package:template_app/utils/utils.dart';

final GetIt sl = GetIt.instance;

Future<void> serviceLocator({
  bool isUnitTest = false,
  bool isHiveEnable = true,
  bool useFakeData = true,
  String prefixBox = '',
}) async {
  if (isUnitTest) {
    await sl.reset();
  }

  if (isHiveEnable) {
    await _initAppStorage(prefixBox: prefixBox);
    final savedLang =
        sl<AppStorageContract>().getPref<String>(PrefKey.locale) ?? 'en';
    await AppLocale.setLocale(Locale(savedLang));
  } else {
    await AppLocale.setLocale(const Locale('en'));
  }

  _useCases();
  _cubits();

  sl
    ..registerSingleton<DioClient>(
      DioClient(
        isUnitTest: isUnitTest,
        onLogout: () async {
          if (sl.isRegistered<AuthCubit>()) {
            await sl<AuthCubit>().expireSession();
          }
        },
      ),
    )
    ..registerSingleton<DioClientDummyJson>(
      DioClientDummyJson(
        isUnitTest: isUnitTest,
        onLogout: () async {
          if (sl.isRegistered<AuthCubit>()) {
            await sl<AuthCubit>().expireSession();
          }
        },
      ),
    );
  _dataSources(useFakeData: useFakeData);
  _repositories();
}

Future<void> _initAppStorage({String prefixBox = ''}) async {
  final appStorage = AppStorage();
  await appStorage.init(prefixBox);
  sl.registerSingleton<AppStorageContract>(appStorage);
}

void _repositories() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(sl()));
}

void _dataSources({bool useFakeData = true}) {
  if (useFakeData) {
    sl.registerLazySingleton<AuthRemoteDatasource>(AuthFakeDatasource.new);
    sl.registerLazySingleton<UsersRemoteDatasource>(UsersFakeDatasource.new);
  } else {
    sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(sl()),
    );
    sl.registerLazySingleton<UsersRemoteDatasource>(
      () => UsersRemoteDatasourceImpl(sl(), sl()),
    );
  }
}

void _useCases() {
  sl
    ..registerLazySingleton(() => PostLogin(sl()))
    ..registerLazySingleton(() => PostLogout(sl()))
    ..registerLazySingleton(() => PostRegister(sl()))
    ..registerLazySingleton(() => GetUsers(sl()))
    ..registerLazySingleton(() => GetUser(sl()));
}

void _cubits() {
  sl
    ..registerLazySingleton(MainCubit.new)
    ..registerFactory(() => RegisterCubit(sl()))
    ..registerLazySingleton(() => AuthCubit(sl(), sl()))
    ..registerFactory(() => LogoutCubit(sl()))
    ..registerLazySingleton(() => UserCubit(sl()))
    ..registerFactory(() => UsersCubit(sl()))
    ..registerFactory(SettingsCubit.new);
}
