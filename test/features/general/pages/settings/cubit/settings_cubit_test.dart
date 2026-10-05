import 'package:bloc_test/bloc_test.dart';
import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../../helpers/fake_path_provider_platform.dart';

void main() {
  late SettingsCubit settingsCubit;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = FakePathProvider();
    await serviceLocator(isUnitTest: true, prefixBox: 'settings_cubit_test_');
    settingsCubit = SettingsCubit();
  });

  blocTest(
    'The theme should be system',
    build: () => settingsCubit,
    act: (SettingsCubit settingsCubit) =>
        settingsCubit.updateTheme(ActiveTheme.system),
    expect: () => [isA<SettingsStateSuccess>()],
  );

  blocTest(
    'The language should be updated',
    build: () => settingsCubit,
    act: (SettingsCubit settingsCubit) => settingsCubit.updateLanguage('en'),
    expect: () => [isA<SettingsStateSuccess>()],
  );

  blocTest<SettingsCubit, SettingsState>(
    'loadSettings emits the current settings',
    build: () => settingsCubit,
    act: (cubit) => cubit.loadSettings(),
    expect: () => [isA<SettingsStateSuccess>()],
    verify: (cubit) => expect(cubit.settings, isA<DataHelper>()),
  );
}
