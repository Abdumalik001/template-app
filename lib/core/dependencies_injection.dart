import 'package:cactus_hr/core/api/api.dart';
import 'package:cactus_hr/core/localization/localization.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';

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
    final savedLang = sl<AppStorageContract>().getPref<String>(PrefKey.locale) ?? 'en';
    await AppLocale.setLocale(Locale(savedLang));
  } else {
    await AppLocale.setLocale(const Locale('en'));
  }

  sl
    ..registerSingleton<DioClient>(DioClient(isUnitTest: isUnitTest))
    ..registerSingleton<DioClientDummyJson>(DioClientDummyJson(isUnitTest: isUnitTest));
  _dataSources(useFakeData: useFakeData);
  _repositories();
  _useCases();
  _cubits();
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
    sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(sl()));
    sl.registerLazySingleton<UsersRemoteDatasource>(() => UsersRemoteDatasourceImpl(sl(), sl()));
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
    ..registerFactory(() => RegisterCubit(sl()))
    ..registerFactory(() => AuthCubit(sl()))
    ..registerFactory(() => LogoutCubit(sl()))
    ..registerFactory(() => UserCubit(sl()))
    ..registerFactory(() => UsersCubit(sl()))
    ..registerFactory(SettingsCubit.new);
}
