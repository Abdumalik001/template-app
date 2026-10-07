import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/resources/resources.dart';
import 'package:template_app/core/widgets/spacer_v.dart';
import 'package:template_app/utils/utils.dart';

class TextF extends StatefulWidget {
  const TextF({
    required this.label,
    super.key,
    this.formFieldKey,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText,
    this.isPassword = false,
    this.textInputType,
    this.inputFormatters,
    this.enabled = true,
    this.textInputAction,
    this.onTap,
    this.autoFillHints,
    this.description,
    this.labelTextStyle,
    this.noErrorSpace = false,
    this.focusNode,
    this.backgroundColor,
    this.hint,
    this.height,
    this.textStyle,
    this.maxLines = 1,
    this.semantic,
    this.onChange,
    this.onSaved,
    this.validator,
  });

  final TextEditingController? controller;
  final GlobalKey<FormFieldState<String>>? formFieldKey;
  final String label;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;

  /// Automatically shows eye toggle button for passwords
  final bool isPassword;
  final bool enabled;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final List<String>? autoFillHints;
  final String? description;
  final TextStyle? labelTextStyle;
  final TextStyle? textStyle;
  final bool noErrorSpace;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final String? hint;
  final double? height;
  final int maxLines;
  final String? semantic;
  final Function(String?)? onChange;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;

  @override
  TextFState createState() => TextFState();
}

class TextFState extends State<TextF> {
  final _debouncer = Debouncer();
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword || (widget.obscureText ?? false);
  }

  @override
  void didUpdateWidget(covariant TextF oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText ||
        oldWidget.isPassword != widget.isPassword) {
      _obscure = widget.isPassword || (widget.obscureText ?? false);
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimens.space8,
      children: [
        Text(
          widget.label,
          style:
              widget.labelTextStyle ??
              TextTheme.of(context).labelMedium?.copyWith(
                color: ColorScheme.of(context).onSurfaceVariant,
              ),
        ),
        _textFormField,
        if (widget.description != null)
          Text(
            widget.description!,
            style: TextTheme.of(context).bodySmall?.copyWith(
              color: ColorScheme.of(context).onSurfaceVariant,
            ),
          ),
        SpacerV(value: Dimens.space4),
      ],
    ),
  );

  Widget get _textFormField {
    Widget? effectiveSuffix = widget.suffixIcon;

    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: Dimens.space20,
          color: ColorScheme.of(context).onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      );
    }

    return Semantics(
      label: widget.semantic,
      child: TextFormField(
        key: widget.formFieldKey,
        autofillHints: widget.autoFillHints,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        enabled: widget.enabled,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.isPassword
            ? TextInputType.visiblePassword
            : widget.textInputType,
        controller: widget.controller,
        obscureText: _obscure,
        focusNode: widget.focusNode,
        maxLines: widget.maxLines,
        onTap: widget.onTap,
        textAlignVertical: TextAlignVertical.center,
        style: widget.textStyle ?? TextTheme.of(context).bodyLarge,
        decoration: InputDecoration(
          fillColor: widget.backgroundColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Dimens.space16,
            vertical: Dimens.space16,
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: effectiveSuffix == null
              ? null
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.space12),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: effectiveSuffix,
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(),
          hintText: widget.hint,
          floatingLabelBehavior: widget.hint != null
              ? FloatingLabelBehavior.always
              : null,
        ),
        validator: widget.validator,
        onChanged: (String value) =>
            _debouncer.run(() => widget.onChange?.call(value)),
        onSaved: widget.onSaved,
      ),
    );
  }
}
