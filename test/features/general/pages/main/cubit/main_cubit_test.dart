import 'package:bloc_test/bloc_test.dart';
import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../../helpers/fake_path_provider_platform.dart';

void main() {
  late MainCubit mainCubit;
  late List<DataHelper> menus;

  /// Initialize data
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = FakePathProvider();
    await serviceLocator(isUnitTest: true, prefixBox: 'main_cubit_test_');
    mainCubit = MainCubit();
    menus = const [
      DataHelper(title: 'Dashboard', isSelected: true),
      DataHelper(title: 'Settings'),
      DataHelper(title: 'Logout'),
    ];
  });

  /// Dispose bloc
  tearDown(() => mainCubit.close());

  ///  Initial data should be loading
  test('Initial data should be MainStatus.loading', () {
    expect(mainCubit.state, const MainState.loading());
  });

  blocTest<MainCubit, MainState>(
    'When initMenu success get data should be return MainState',
    build: () => mainCubit,
    act: (cubit) => cubit.initMenu(menus),
    wait: const Duration(milliseconds: 300),
    expect: () => [const MainState.loading(), MainState.success(menus.first)],
  );

  test('updateIndex selects the requested menu', () {
    mainCubit
      ..initMenu(menus)
      ..updateIndex(1);

    expect(mainCubit.currentIndex, 1);
    expect(mainCubit.dataMenus.map((menu) => menu.isSelected), [
      false,
      true,
      false,
    ]);
  });
}
