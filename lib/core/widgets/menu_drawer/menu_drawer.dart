import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/features/features.dart';
import 'package:template_app/utils/utils.dart';

part 'menu_drawer_header.dart';
part 'menu_drawer_item.dart';

enum AppMenuItem {
  dashboard(route: Routes.dashboard, icon: Icons.space_dashboard_outlined),
  settings(route: Routes.settings, icon: Icons.tune_rounded),
  logout(route: null, icon: Icons.logout_rounded);

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
                        isSelected:
                            item.route != null &&
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
      builder: (dialogCtx) => BlocProvider(
        create: (_) => sl<LogoutCubit>(),
        child: BlocConsumer<LogoutCubit, LogoutState>(
          listener: (ctx, state) => switch (state) {
            LogoutStateInitial() => null,
            LogoutStateLoading() => null,
            LogoutStateFailure(:final message) => (() {
              message.toToastError();
            })(),
            LogoutStateSuccess() => (() async {
              Navigator.of(dialogCtx).pop();
              sl<UserCubit>().clearCache();
              await sl<AppStorageContract>().clearSession();
              AppRouter.logout();
            })(),
          },
          builder: (ctx, state) => AlertDialog(
            icon: Icon(Icons.logout_rounded, color: ColorScheme.of(ctx).error),
            title: Text(Strings.of(ctx)!.logout),
            content: Text(Strings.of(ctx)!.logoutDesc),
            actions: [
              TextButton(
                onPressed: state is LogoutStateLoading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  Strings.of(ctx)!.cancel,
                  style: TextTheme.of(ctx).bodyMedium600?.copyWith(
                    color: ColorScheme.of(ctx).onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: state is LogoutStateLoading
                    ? null
                    : () => ctx.read<LogoutCubit>().postLogout(),
                child: state is LogoutStateLoading
                    ? SizedBox(
                        width: Dimens.space16,
                        height: Dimens.space16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorScheme.of(ctx).error,
                        ),
                      )
                    : Text(
                        Strings.of(ctx)!.yes,
                        style: TextTheme.of(ctx).bodyMedium600?.copyWith(
                          color: ColorScheme.of(ctx).error,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
