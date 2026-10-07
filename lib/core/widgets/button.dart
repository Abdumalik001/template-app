import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/resources/resources.dart';
import 'package:template_app/utils/ext/text_theme.dart';

enum ButtonVariant { filled, outlined, text }

/// Production-ready Button supporting [isLoading], variants (filled, outlined, text),
/// icons (leading/trailing), and gentle pressing scale animations.
class Button extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final Color? color;
  final Color? titleColor;
  final Color? borderColor;
  final double? fontSize;
  final Color? splashColor;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;

  const Button({
    required this.title,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.variant = ButtonVariant.filled,
    this.width,
    this.height,
    this.color,
    this.titleColor,
    this.borderColor,
    this.fontSize,
    this.splashColor,
    this.leadingIcon,
    this.trailingIcon,
    this.padding,
  });

  const Button.outlined({
    required this.title,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.titleColor,
    this.borderColor,
    this.fontSize,
    this.splashColor,
    this.leadingIcon,
    this.trailingIcon,
    this.padding,
  }) : variant = ButtonVariant.outlined;

  const Button.text({
    required this.title,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.titleColor,
    this.fontSize,
    this.splashColor,
    this.leadingIcon,
    this.trailingIcon,
    this.padding,
  }) : variant = ButtonVariant.text,
       borderColor = null;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  final _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final Color effectiveBackground = switch (widget.variant) {
      ButtonVariant.filled => widget.color ?? ColorScheme.of(context).primary,
      ButtonVariant.outlined ||
      ButtonVariant.text => widget.color ?? Colors.transparent,
    };

    final Color effectiveForeground = switch (widget.variant) {
      ButtonVariant.filled =>
        widget.titleColor ?? ColorScheme.of(context).onPrimary,
      ButtonVariant.outlined || ButtonVariant.text =>
        widget.titleColor ?? ColorScheme.of(context).primary,
    };

    final BorderSide? border = widget.variant == ButtonVariant.outlined
        ? BorderSide(
            color:
                widget.borderColor ??
                widget.titleColor ??
                ColorScheme.of(context).primary,
            width: 1.5,
          )
        : null;

    return ValueListenableBuilder<bool>(
      valueListenable: _isPressed,
      builder: (_, isPressed, child) => AnimatedScale(
        scale: isPressed ? 0.97 : 1,
        duration: Motion.fast,
        curve: Motion.standard,
        child: child,
      ),
      child: Listener(
        onPointerDown: (_) {
          if (isEnabled) {
            _isPressed.value = true;
          }
        },
        onPointerUp: (_) => _isPressed.value = false,
        onPointerCancel: (_) => _isPressed.value = false,
        child: SizedBox(
          width: widget.width,
          height: widget.height ?? Dimens.space50,
          child: AnimatedOpacity(
            opacity: isEnabled ? 1 : 0.4,
            duration: Motion.medium,
            curve: Motion.standard,
            child: TextButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: TextButton.styleFrom(
                backgroundColor: effectiveBackground,
                foregroundColor: effectiveForeground,
                disabledBackgroundColor: effectiveBackground,
                disabledForegroundColor: effectiveForeground,
                overlayColor: widget.splashColor ?? effectiveForeground,
                minimumSize: Size(
                  Dimens.space64,
                  widget.height ?? Dimens.space50,
                ),
                padding:
                    widget.padding ??
                    EdgeInsets.symmetric(
                      horizontal: Dimens.space24,
                      vertical: Dimens.space12,
                    ),
                side: border,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(Dimens.cornerRadius),
                  ),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: Dimens.space24,
                      height: Dimens.space24,
                      child: CupertinoActivityIndicator(
                        color: effectiveForeground,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.leadingIcon != null) ...[
                          widget.leadingIcon!,
                          SizedBox(width: Dimens.space8),
                        ],
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextTheme.of(context).bodyMedium600
                                ?.copyWith(
                                  color: effectiveForeground,
                                  fontSize: widget.fontSize,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          SizedBox(width: Dimens.space8),
                          widget.trailingIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
