import 'package:material_ui/material_ui.dart';

class L10n {
  L10n._(); //coverage:ignore-line

  static final all = [
    const Locale('en'),
    const Locale('uz'),
    const Locale('ru'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'uz':
        return "O'zbekcha";
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English';
    }
  }
}
