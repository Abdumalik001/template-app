import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/localization/localization.dart';
import 'package:template_app/core/resources/resources.dart';
import 'package:template_app/core/widgets/button.dart';
import 'package:template_app/core/widgets/fade_slide_in.dart';
import 'package:template_app/core/widgets/spacer_v.dart';
import 'package:template_app/utils/ext/text_theme.dart';

/// Reusable full-screen or boxed error view featuring an error icon,
/// clear localized error explanation, and an optional retry button.
class AppErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) => FadeSlideIn(
    child: Padding(
      padding: EdgeInsets.all(Dimens.space24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ColorScheme.of(context).errorContainer,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(Dimens.space20),
                child: Icon(
                  icon,
                  size: Dimens.space36,
                  color: ColorScheme.of(context).onErrorContainer,
                ),
              ),
            ),
            SpacerV(value: Dimens.space16),
            Text(
              message?.isNotEmpty ?? false
                  ? message!
                  : Strings.of(context)!.errorUnknown,
              style: TextTheme.of(context).bodyMedium500?.copyWith(
                color: ColorScheme.of(context).onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SpacerV(value: Dimens.space20),
              Button.outlined(
                title: Strings.of(context)!.retry,
                onPressed: onRetry,
                leadingIcon: Icon(
                  Icons.refresh_rounded,
                  size: Dimens.space18,
                  color: ColorScheme.of(context).primary,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
