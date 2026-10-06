import 'package:material_ui/material_ui.dart';

/// Cactus HR - Emerald / Teal Design System Palette.
/// Fresh, clean, modern corporate theme tailored for HR & employee management.
class Palette {
  Palette._();

  // --- Neutrals (Light Mode) ---
  /// Clean, crisp off-white background with zero pink tint.
  static const Color background = Color(0xffF8FAFC); // Slate 50
  static const Color surface = Color(0xffFFFFFF);    // Pure White
  static const Color surfaceContainer = Color(0xffF1F5F9); // Slate 100
  static const Color surfaceContainerHigh = Color(0xffE2E8F0); // Slate 200
  static const Color surfaceVariant = Color(0xffEDF2F7);
  static const Color onSurface = Color(0xff0F172A); // Slate 900 (High contrast dark)
  static const Color onSurfaceVariant = Color(0xff64748B); // Slate 500 (Muted gray)
  static const Color outline = Color(0xffE2E8F0); // Slate 200 border
  static const Color shadow = Color(0xff0F172A);

  // --- Neutrals (Dark Mode) ---
  /// Deep slate-tinted dark background (not flat pitch black, easier on eyes).
  static const Color backgroundDark = Color(0xff0B111E); // Deep Slate Navy
  static const Color surfaceDark = Color(0xff151E2E);    // Slate Dark Card
  static const Color surfaceContainerDark = Color(0xff1E293B); // Slate 800
  static const Color surfaceContainerHighDark = Color(0xff334155); // Slate 700
  static const Color surfaceVariantDark = Color(0xff1E293B);
  static const Color onSurfaceDark = Color(0xffF8FAFC); // Slate 50 (Crisp text)
  static const Color onSurfaceVariantDark = Color(0xff94A3B8); // Slate 400
  static const Color outlineDark = Color(0xff26354A);
  static const Color shadowDark = Color(0xff000000);

  // --- Primary Brand (Cactus Emerald / Deep Teal) ---
  /// Light mode primary: Trustworthy, professional deep emerald.
  static const Color primary = Color(0xff0D9488); // Teal 600 / Emerald
  static const Color onPrimary = Color(0xffFFFFFF);
  static const Color primaryContainer = Color(0xffCCFBF1); // Teal 100
  static const Color onPrimaryContainer = Color(0xff115E59); // Teal 800

  /// Dark mode primary: Vibrant, glowing mint-emerald for high visibility.
  static const Color primaryDark = Color(0xff2DD4BF); // Teal 400
  static const Color onPrimaryDark = Color(0xff042F2E); // Teal 950
  static const Color primaryContainerDark = Color(0xff134E4A); // Teal 900
  static const Color onPrimaryContainerDark = Color(0xffCCFBF1);

  // --- Secondary (Forest / Sage accent) ---
  static const Color secondary = Color(0xff334155); // Slate 700
  static const Color onSecondary = Color(0xffFFFFFF);
  static const Color secondaryContainer = Color(0xffE2E8F0); // Slate 200
  static const Color onSecondaryContainer = Color(0xff0F172A);

  static const Color secondaryDark = Color(0xff94A3B8); // Slate 400
  static const Color onSecondaryDark = Color(0xff0F172A);
  static const Color secondaryContainerDark = Color(0xff1E293B);
  static const Color onSecondaryContainerDark = Color(0xffF8FAFC);

  // --- Tertiary (Warm Amber / Accent) ---
  static const Color tertiary = Color(0xffD97706); // Amber 600
  static const Color onTertiary = Color(0xffFFFFFF);
  static const Color tertiaryContainer = Color(0xffFEF3C7);
  static const Color onTertiaryContainer = Color(0xff92400E);

  static const Color tertiaryDark = Color(0xffFBBF24); // Amber 400
  static const Color onTertiaryDark = Color(0xff451A03);
  static const Color tertiaryContainerDark = Color(0xff78350F);
  static const Color onTertiaryContainerDark = Color(0xffFEF3C7);

  // --- Semantic: Error ---
  static const Color error = Color(0xffEF4444); // Red 500
  static const Color onError = Color(0xffFFFFFF);
  static const Color errorContainer = Color(0xffFEE2E2);
  static const Color onErrorContainer = Color(0xff991B1B);

  static const Color errorDark = Color(0xffF87171); // Red 400
  static const Color onErrorDark = Color(0xff450A0A);
  static const Color errorContainerDark = Color(0xff7F1D1D);
  static const Color onErrorContainerDark = Color(0xffFEE2E2);

  // --- Semantic: Success ---
  static const Color success = Color(0xff10B981); // Emerald 500
  static const Color onSuccess = Color(0xffFFFFFF);
  static const Color successContainer = Color(0xffD1FAE5);
  static const Color onSuccessContainer = Color(0xff065F46);

  static const Color successDark = Color(0xff34D399); // Emerald 400
  static const Color onSuccessDark = Color(0xff064E3B);
  static const Color successContainerDark = Color(0xff065F46);
  static const Color onSuccessContainerDark = Color(0xffD1FAE5);

  // --- Semantic: Warning ---
  static const Color warning = Color(0xffF59E0B); // Amber 500
  static const Color onWarning = Color(0xffFFFFFF);
  static const Color warningContainer = Color(0xffFEF3C7);
  static const Color onWarningContainer = Color(0xff92400E);

  static const Color warningDark = Color(0xffFBBF24);
  static const Color onWarningDark = Color(0xff451A03);
  static const Color warningContainerDark = Color(0xff78350F);
  static const Color onWarningContainerDark = Color(0xffFEF3C7);

  // --- Semantic: Info ---
  static const Color info = Color(0xff3B82F6); // Blue 500
  static const Color onInfo = Color(0xffFFFFFF);
  static const Color infoContainer = Color(0xffDBEAFE);
  static const Color onInfoContainer = Color(0xff1E40AF);

  static const Color infoDark = Color(0xff60A5FA); // Blue 400
  static const Color onInfoDark = Color(0xff172554);
  static const Color infoContainerDark = Color(0xff1E3A8A);
  static const Color onInfoContainerDark = Color(0xffDBEAFE);
}
