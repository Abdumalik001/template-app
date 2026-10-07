import 'package:material_ui/material_ui.dart';
import 'package:template_app/core/localization/generated/strings.dart';

class AppLocale {
  AppLocale._();

  static late Strings _strings;

  /// Returns true if [AppLocale] has been loaded at least once.
  static bool get isInitialized => true;

  /// Global synchronous accessor for [Strings] without requiring [BuildContext].
  static Strings get strings => _strings;

  /// Loads and caches the [Strings] instance for the given [locale].
  static Future<void> setLocale(Locale locale) async {
    _strings = await Strings.delegate.load(locale);
  }
}

/// Global shorthand to read localized strings without [BuildContext].
Strings get appStrings => AppLocale.strings;
