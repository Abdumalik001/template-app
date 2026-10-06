import 'package:cactus_hr/core/core.dart';
import 'package:material_ui/material_ui.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecorations(context).card,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.cornerRadius),
        child: child,
      ),
    ),
  );
}
