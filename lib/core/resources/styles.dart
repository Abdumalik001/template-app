import 'package:cactus_hr/core/core.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

const String _fontFamily = 'InstrumentSans';

/// Light theme
// ignore: avoid_unused_parameters
ThemeData themeLight(BuildContext context) => _buildTheme(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light().copyWith(
    primary: Palette.primary,
    onPrimary: Palette.onPrimary,
    primaryContainer: Palette.primaryContainer,
    onPrimaryContainer: Palette.onPrimaryContainer,
    secondary: Palette.secondary,
    onSecondary: Palette.onSecondary,
    secondaryContainer: Palette.secondaryContainer,
    onSecondaryContainer: Palette.onSecondaryContainer,
    tertiary: Palette.tertiary,
    onTertiary: Palette.onTertiary,
    tertiaryContainer: Palette.tertiaryContainer,
    onTertiaryContainer: Palette.onTertiaryContainer,
    error: Palette.error,
    onError: Palette.onError,
    errorContainer: Palette.errorContainer,
    onErrorContainer: Palette.onErrorContainer,
    surface: Palette.background,
    onSurface: Palette.onSurface,
    surfaceContainerLowest: Palette.surface,
    surfaceContainerLow: Palette.surface,
    surfaceContainer: Palette.surfaceContainer,
    surfaceContainerHigh: Palette.surfaceContainerHigh,
    surfaceContainerHighest: Palette.surfaceVariant,
    onSurfaceVariant: Palette.onSurfaceVariant,
    outline: Palette.outline,
    outlineVariant: Palette.outline,
    shadow: Palette.shadow,
  ),
  colors: const AppColors(
    success: Palette.success,
    onSuccess: Palette.onSuccess,
    successContainer: Palette.successContainer,
    onSuccessContainer: Palette.onSuccessContainer,
    warning: Palette.warning,
    onWarning: Palette.onWarning,
    warningContainer: Palette.warningContainer,
    onWarningContainer: Palette.onWarningContainer,
    info: Palette.info,
    onInfo: Palette.onInfo,
    infoContainer: Palette.infoContainer,
    onInfoContainer: Palette.onInfoContainer,
  ),
  cardColor: Palette.surface,
  overlayStyle: SystemUiOverlayStyle.dark,
);

/// Dark theme
// ignore: avoid_unused_parameters
ThemeData themeDark(BuildContext context) => _buildTheme(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark().copyWith(
    primary: Palette.primaryDark,
    onPrimary: Palette.onPrimaryDark,
    primaryContainer: Palette.primaryContainerDark,
    onPrimaryContainer: Palette.onPrimaryContainerDark,
    secondary: Palette.secondaryDark,
    onSecondary: Palette.onSecondaryDark,
    secondaryContainer: Palette.secondaryContainerDark,
    onSecondaryContainer: Palette.onSecondaryContainerDark,
    tertiary: Palette.tertiaryDark,
    onTertiary: Palette.onTertiaryDark,
    tertiaryContainer: Palette.tertiaryContainerDark,
    onTertiaryContainer: Palette.onTertiaryContainerDark,
    error: Palette.errorDark,
    onError: Palette.onErrorDark,
    errorContainer: Palette.errorContainerDark,
    onErrorContainer: Palette.onErrorContainerDark,
    surface: Palette.backgroundDark,
    onSurface: Palette.onSurfaceDark,
    surfaceContainerLowest: Palette.surfaceDark,
    surfaceContainerLow: Palette.surfaceDark,
    surfaceContainer: Palette.surfaceContainerDark,
    surfaceContainerHigh: Palette.surfaceContainerHighDark,
    surfaceContainerHighest: Palette.surfaceVariantDark,
    onSurfaceVariant: Palette.onSurfaceVariantDark,
    outline: Palette.outlineDark,
    outlineVariant: Palette.outlineDark,
    shadow: Palette.shadowDark,
  ),
  colors: const AppColors(
    success: Palette.successDark,
    onSuccess: Palette.onSuccessDark,
    successContainer: Palette.successContainerDark,
    onSuccessContainer: Palette.onSuccessContainerDark,
    warning: Palette.warningDark,
    onWarning: Palette.onWarningDark,
    warningContainer: Palette.warningContainerDark,
    onWarningContainer: Palette.onWarningContainerDark,
    info: Palette.infoDark,
    onInfo: Palette.onInfoDark,
    infoContainer: Palette.infoContainerDark,
    onInfoContainer: Palette.onInfoContainerDark,
  ),
  cardColor: Palette.surfaceDark,
  overlayStyle: SystemUiOverlayStyle.light,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required AppColors colors,
  required Color cardColor,
  required SystemUiOverlayStyle overlayStyle,
}) {
  final textTheme = _textTheme(colorScheme.onSurface);
  const fieldRadius = BorderRadius.all(Radius.circular(Dimens.cornerRadius));
  const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(Dimens.cornerRadius)),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: _fontFamily,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryColor: colorScheme.primary,
    disabledColor: colorScheme.outline,
    hintColor: colorScheme.onSurfaceVariant,
    cardColor: cardColor,
    dividerColor: colorScheme.outline,
    scaffoldBackgroundColor: colorScheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    iconTheme: IconThemeData(color: colorScheme.onSurface),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: Dimens.zero,
      scrolledUnderElevation: Dimens.zero,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      systemOverlayStyle: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      isDense: true,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
      suffixIconColor: colorScheme.onSurfaceVariant,
      border: const OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: colorScheme.surfaceContainer),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        shape: shape,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: Dimens.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimens.cornerRadiusLg)),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    drawerTheme: DrawerThemeData(
      elevation: Dimens.zero,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(Dimens.cornerRadiusLg),
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: Dimens.zero,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      circularTrackColor: colorScheme.primaryContainer,
      strokeCap: StrokeCap.round,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outline,
      thickness: 1,
      space: 1,
    ),
    extensions: <ThemeExtension<dynamic>>[colors],
  );
}

/// Skeleton loading look, derived from the active theme so the shimmer
/// follows the in-app theme mode rather than the platform brightness.
SkeletonizerConfigData skeletonConfig(BuildContext context) {
  final colorScheme = ColorScheme.of(context);

  return SkeletonizerConfigData(
    brightness: Theme.brightnessOf(context),
    effectResolver: (_) => ShimmerEffect(
      baseColor: colorScheme.surfaceContainerHigh,
      highlightColor: colorScheme.surfaceContainerLowest,
      duration: const Duration(milliseconds: 1400),
    ),
    justifyMultiLineText: false,
    enableSwitchAnimation: true,
  );
}

TextTheme _textTheme(Color color) {
  TextStyle style(double size, FontWeight weight, {double spacing = 0}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        color: color,
        height: 1.3,
      );

  return TextTheme(
    displayLarge: style(Dimens.displayLarge, FontWeight.w600, spacing: -1.5),
    displayMedium: style(Dimens.displayMedium, FontWeight.w600, spacing: -1),
    displaySmall: style(Dimens.displaySmall, FontWeight.w600, spacing: -0.8),
    headlineLarge: style(Dimens.headlineLarge, FontWeight.w600, spacing: -0.6),
    headlineMedium: style(
      Dimens.headlineMedium,
      FontWeight.w600,
      spacing: -0.6,
    ),
    headlineSmall: style(Dimens.headlineSmall, FontWeight.w600, spacing: -0.4),
    titleLarge: style(Dimens.titleLarge, FontWeight.w600, spacing: -0.2),
    titleMedium: style(Dimens.titleMedium, FontWeight.w500, spacing: -0.1),
    titleSmall: style(Dimens.titleSmall, FontWeight.w500),
    bodyLarge: style(Dimens.bodyLarge, FontWeight.w400),
    bodyMedium: style(Dimens.bodyMedium, FontWeight.w400),
    bodySmall: style(Dimens.bodySmall, FontWeight.w400),
    labelLarge: style(Dimens.labelLarge, FontWeight.w500),
    labelMedium: style(Dimens.labelMedium, FontWeight.w500, spacing: 0.1),
    labelSmall: style(Dimens.labelSmall, FontWeight.w500, spacing: 0.25),
  );
}

class AppColors extends ThemeExtension<AppColors> {
  final Color? success;
  final Color? onSuccess;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warning;
  final Color? onWarning;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? info;
  final Color? onInfo;
  final Color? infoContainer;
  final Color? onInfoContainer;

  const AppColors({
    this.success,
    this.onSuccess,
    this.successContainer,
    this.onSuccessContainer,
    this.warning,
    this.onWarning,
    this.warningContainer,
    this.onWarningContainer,
    this.info,
    this.onInfo,
    this.infoContainer,
    this.onInfoContainer,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
    infoContainer: infoContainer ?? this.infoContainer,
    onInfoContainer: onInfoContainer ?? this.onInfoContainer,
  );

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      success: Color.lerp(success, other.success, t),
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t),
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      warning: Color.lerp(warning, other.warning, t),
      onWarning: Color.lerp(onWarning, other.onWarning, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t),
      info: Color.lerp(info, other.info, t),
      onInfo: Color.lerp(onInfo, other.onInfo, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? const AppColors();
}

class BoxDecorations {
  BoxDecorations(this.context);

  final BuildContext context;

  BoxDecoration get button => BoxDecoration(
    color: ColorScheme.of(context).primary,
    borderRadius: const BorderRadius.all(Radius.circular(Dimens.cornerRadius)),
  );

  /// Flat card: hairline border instead of a drop shadow.
  BoxDecoration get card => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: const BorderRadius.all(Radius.circular(Dimens.cornerRadius)),
    border: Border.all(color: ColorScheme.of(context).outline),
  );

  BoxDecoration get item => BoxDecoration(
    color: ColorScheme.of(context).surfaceContainer,
    borderRadius: const BorderRadius.all(Radius.circular(Dimens.cornerRadius)),
  );

  BoxDecoration get navigation => BoxDecoration(
    color: ColorScheme.of(context).surfaceContainer,
    borderRadius: BorderRadius.all(Radius.circular(Dimens.space16)),
    boxShadow: [BoxShadows(context).navigation],
  );
}

class BoxShadows {
  BoxShadows(this.context);

  final BuildContext context;

  BoxShadow get button => BoxShadow(
    color: ColorScheme.of(context).primary.withValues(alpha: 0.24),
    offset: Offset(0, Dimens.space6),
    blurRadius: Dimens.space16,
    spreadRadius: -Dimens.space4,
  );

  BoxShadow get card => BoxShadow(
    color: ColorScheme.of(context).shadow.withAlpha(10),
    blurRadius: 5.0,
    spreadRadius: 0.5,
  );

  BoxShadow get dialog => BoxShadow(
    color: ColorScheme.of(context).shadow.withAlpha(30),
    offset: const Offset(0, -4),
    blurRadius: 16.0,
  );

  BoxShadow get dialogAlt => BoxShadow(
    color: ColorScheme.of(context).shadow.withAlpha(30),
    offset: const Offset(0, 4),
    blurRadius: 16.0,
  );

  BoxShadow get buttonMenu => BoxShadow(
    color: ColorScheme.of(context).shadow.withAlpha(10),
    blurRadius: 4.0,
  );

  BoxShadow get navigation => BoxShadow(
    color: ColorScheme.of(context).shadow.withAlpha(30),
    blurRadius: Dimens.space6,
    offset: Offset(0, Dimens.space6),
  );
}
