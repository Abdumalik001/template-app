import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/core.dart';
import 'package:template_app/utils/utils.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) => Parent(
    child: ColoredBox(
      color: ColorScheme.of(context).surface,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: Motion.slow,
          curve: Motion.emphasized,
          onEnd: () {
            final isLoggedIn =
                sl.isRegistered<AppStorageContract>() &&
                sl<AppStorageContract>().isLoggedIn;
            if (isLoggedIn) {
              context.goNamed(Routes.dashboard.name);
            } else {
              context.goNamed(Routes.login.name);
            }
          },
          builder: (_, scale, child) => Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.85) / 0.15).clamp(0, 1),
              child: child,
            ),
          ),
          child: BrandLogo(width: context.widthInPercent(32)),
        ),
      ),
    ),
  );
}
