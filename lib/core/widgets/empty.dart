import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/localization/localization.dart';
import 'package:template_app/core/resources/resources.dart';
import 'package:template_app/core/widgets/fade_slide_in.dart';
import 'package:template_app/core/widgets/spacer_v.dart';

/// Reusable empty view featuring a centered icon, title, optional subtitle, and optional action.
class Empty extends StatelessWidget {
  final String? errorMessage;
  final String? description;
  final IconData icon;
  final Widget? action;

  const Empty({
    super.key,
    this.errorMessage,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
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
                color: ColorScheme.of(context).primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(Dimens.space20),
                child: Icon(
                  icon,
                  size: Dimens.space36,
                  color: ColorScheme.of(context).onPrimaryContainer,
                ),
              ),
            ),
            SpacerV(value: Dimens.space16),
            Text(
              errorMessage?.isNotEmpty ?? false
                  ? errorMessage!
                  : Strings.of(context)!.errorNoData,
              style: TextTheme.of(context).titleMedium?.copyWith(
                color: ColorScheme.of(context).onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SpacerV(value: Dimens.space8),
              Text(
                description!,
                style: TextTheme.of(context).bodyMedium?.copyWith(
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[SpacerV(value: Dimens.space20), action!],
          ],
        ),
      ),
    ),
  );
}
