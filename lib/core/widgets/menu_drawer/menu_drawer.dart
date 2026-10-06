import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/features.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'menu_drawer_header.dart';
part 'menu_drawer_item.dart';

enum AppMenuItem {
  dashboard(
    route: Routes.dashboard,
    icon: Icons.space_dashboard_outlined,
  ),
  settings(
    route: Routes.settings,
    icon: Icons.tune_rounded,
  ),
  logout(
    route: null,
    icon: Icons.logout_rounded,
  );

  const AppMenuItem({required this.route, required this.icon});

  final Routes? route;
  final IconData icon;

  String localizedTitle(BuildContext context) => switch (this) {
    AppMenuItem.dashboard => Strings.of(context)!.dashboard,
    AppMenuItem.settings => Strings.of(context)!.settings,
    AppMenuItem.logout => Strings.of(context)!.logout,
  };
}

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dimens.space24),
              child: BlocProvider(
                create: (_) => sl<UserCubit>()..getUser(),
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (_, state) => AnimatedSwitcher(
                    duration: Motion.medium,
                    child: switch (state) {
                      UserStateLoading() => const Skeletonizer(
                        child: _MenuDrawerHeader(
                          user: User(
                            name: 'Placeholder Name',
                            email: 'placeholder@mail.com',
                          ),
                        ),
                      ),
                      UserStateFailure(:final message) => Text(
                        message,
                        style: TextTheme.of(context).bodyMedium?.copyWith(
                          color: ColorScheme.of(context).error,
                        ),
                      ),
                      UserStateSuccess(:final data) => _MenuDrawerHeader(
                        user: data,
                      ),
                    },
                  ),
                ),
              ),
            ),
            Divider(indent: Dimens.space24, endIndent: Dimens.space24),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(Dimens.space12),
                children: [
                  for (final (index, item) in AppMenuItem.values.indexed)
                    FadeSlideIn(
                      delay: Motion.stagger * index,
                      offset: Dimens.space12,
                      child: _MenuDrawerItem(
                        item: item,
                        isSelected: item.route != null &&
                            currentRoute == item.route!.path,
                        onTap: () => _handleItemTap(context, item),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(BuildContext context, AppMenuItem item) {
    Navigator.of(context).pop(); // Close drawer

    if (item.route != null) {
      if (item.route == Routes.dashboard) {
        context.goNamed(item.route!.name);
      } else {
        context.pushNamed(item.route!.name);
      }
    } else if (item == AppMenuItem.logout) {
      _showLogoutDialog(context);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(
          Icons.logout_rounded,
          color: ColorScheme.of(dialogCtx).error,
        ),
        title: Text(Strings.of(dialogCtx)!.logout),
        content: Text(Strings.of(dialogCtx)!.logoutDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              Strings.of(dialogCtx)!.cancel,
              style: TextTheme.of(dialogCtx).bodyMedium600?.copyWith(
                color: ColorScheme.of(dialogCtx).onSurfaceVariant,
              ),
            ),
          ),
          BlocListener<LogoutCubit, LogoutState>(
            listener: (listenerCtx, state) => switch (state) {
              LogoutStateLoading() => listenerCtx.show(),
              LogoutStateFailure(:final message) => (() {
                listenerCtx.dismiss();
                message.toToastError();
              })(),
              LogoutStateSuccess(:final message) => (() {
                listenerCtx.dismiss();
                message.toToastSuccess();
                context.goNamed(Routes.root.name);
              })(),
            },
            child: TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<LogoutCubit>().postLogout();
              },
              child: Text(
                Strings.of(dialogCtx)!.yes,
                style: TextTheme.of(dialogCtx).bodyMedium600?.copyWith(
                  color: ColorScheme.of(dialogCtx).error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
