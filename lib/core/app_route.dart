import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:template_app/core/dependencies_injection.dart';
import 'package:template_app/features/features.dart';

enum Routes {
  root('/'),
  splashScreen('/splashscreen'),

  /// Home Page
  dashboard('/dashboard'),
  settings('/settings'),

  // Auth Page
  login('/auth/login'),
  register('/auth/register');

  const Routes(this.path);

  final String path;
}

class AppRouter {
  static late BuildContext context;
  static late bool isUnitTest;

  AppRouter.setStream(BuildContext ctx, {bool isTest = false}) {
    context = ctx;
    isUnitTest = isTest;
  }

  static final GoRouter router = GoRouter(
    routes: [
      AppRoute(
        path: Routes.splashScreen.path,
        name: Routes.splashScreen.name,
        useFade: true,
        builder: (_, _) => const SplashScreenPage(),
      ),
      GoRoute(
        path: Routes.root.path,
        name: Routes.root.name,
        redirect: (_, _) => Routes.dashboard.path,
      ),
      AppRoute(
        path: Routes.login.path,
        name: Routes.login.name,
        useFade: true,
        builder: (_, _) => const LoginPage(),
      ),
      AppRoute(
        path: Routes.register.path,
        name: Routes.register.name,
        builder: (_, _) => MultiBlocProvider(
          providers: [BlocProvider(create: (_) => sl<RegisterCubit>())],
          child: const RegisterPage(),
        ),
      ),
      AppRoute(
        path: Routes.dashboard.path,
        name: Routes.dashboard.name,
        useFade: true,
        builder: (_, _) {
          sl<UserCubit>().getUser();
          return BlocProvider(
            create: (_) => sl<UsersCubit>()..fetchUsers(const UsersParams()),
            child: const DashboardPage(),
          );
        },
      ),
      AppRoute(
        path: Routes.settings.path,
        name: Routes.settings.name,
        builder: (_, _) => const SettingsPage(),
      ),
    ],
    initialLocation: Routes.splashScreen.path,
    routerNeglect: true,
    debugLogDiagnostics: kDebugMode,
  );

  static void logout() {
    router.goNamed(Routes.splashScreen.name);
  }
}

/// Custom [GoRoute] that supports smooth transitions (e.g. fade) or standard iOS/Cupertino style.
class AppRoute extends GoRoute {
  final bool useFade;

  AppRoute({
    required super.path,
    required super.name,
    required Widget Function(BuildContext context, GoRouterState s) builder,
    List<GoRoute> routes = const [],
    this.useFade = false,
    super.redirect,
  }) : super(
         routes: routes,
         pageBuilder: (context, state) {
           final pageContent = builder(context, state);
           if (useFade) {
             return CustomTransitionPage<void>(
               key: state.pageKey,
               child: pageContent,
               transitionsBuilder:
                   (context, animation, secondaryAnimation, child) =>
                       FadeTransition(opacity: animation, child: child),
             );
           }
           return CupertinoPage<void>(key: state.pageKey, child: pageContent);
         },
       );
}
