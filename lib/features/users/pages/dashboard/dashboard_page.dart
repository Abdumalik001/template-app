import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/users/users.dart';
import 'package:template_app/utils/utils.dart';

part 'dashboard_empty.dart';
part 'dashboard_loading.dart';
part 'dashboard_user_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Parent(
    scaffoldKey: _scaffoldKey,
    appBar: AppBar(
      centerTitle: true,
      title: Text(Strings.of(context)!.dashboard),
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          size: Dimens.space24,
          semanticLabel: Strings.of(context)!.menu,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: const [ButtonNotification()],
    ),
    drawer: SizedBox(
      width: context.widthInPercent(78),
      child: const MenuDrawer(),
    ),
    child: BlocBuilder<UsersCubit, UsersState>(
      builder: (_, state) => AnimatedSwitcher(
        duration: Motion.medium,
        switchInCurve: Motion.emphasized,
        switchOutCurve: Motion.standard,
        child: KeyedSubtree(
          key: ValueKey(state is UsersStateLoading),
          child: switch (state) {
            UsersStateLoading() => const _DashboardLoading(),
            UsersStateInitial() => const SizedBox.shrink(),
            UsersStateSuccess(:final data) => PaginatedListView<User>(
              items: data.users ?? [],
              hasMore: data.currentPage != data.lastPage,
              onRefresh: () => context.read<UsersCubit>().refresh(),
              onLoadMore: () => context.read<UsersCubit>().nextPage(),
              emptyWidget: const _DashboardEmpty(),
              itemBuilder: (_, user, _) => _DashboardUserItem(user: user),
            ),
            UsersStateFailure(:final message) => AppErrorView(
              message: message,
              onRetry: () => context.read<UsersCubit>().refresh(),
            ),
            UsersStateEmpty() => const _DashboardEmpty(),
          },
        ),
      ),
    ),
  );
}
