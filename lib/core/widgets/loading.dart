import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/core.dart';

/// Blocking progress indicator used by the loading dialog. Content areas
/// use skeletons (`Skeletonizer`) instead.
class Loading extends StatelessWidget {
  const Loading({this.showMessage = true, this.color});

  final bool showMessage;
  final Color? color;

  @override
  Widget build(BuildContext context) => FittedBox(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Dimens.space16,
      children: [
        SizedBox.square(
          dimension: Dimens.space36,
          child: CircularProgressIndicator(color: color, strokeWidth: 3),
        ),
        Visibility(
          visible: showMessage,
          child: Text(
            Strings.of(context)!.pleaseWait,
            style: TextTheme.of(context).bodyMedium?.copyWith(
              color: color ?? ColorScheme.of(context).onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
