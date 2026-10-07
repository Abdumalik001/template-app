import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/core.dart';

class SpacerH extends StatelessWidget {
  const SpacerH({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) => SizedBox(width: value ?? Dimens.space8);
}
