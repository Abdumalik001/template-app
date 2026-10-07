import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/core.dart';

/// App logo tinted with the primary colour so it follows light/dark theme.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) => Image.asset(
    Images.icLogo,
    width: width ?? Dimens.logo,
    color: ColorScheme.of(context).primary,
    colorBlendMode: BlendMode.srcIn,
  );
}
