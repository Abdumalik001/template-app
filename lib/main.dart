import 'dart:async';

import 'package:cactus_hr/app.dart';
import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runZonedGuarded(
    /// Lock device orientation to portrait
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      /// Register Service locator
      await serviceLocator();
      await FirebaseServices.init();

      return await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then((_) => runApp(const App()));
    },
    (error, stackTrace) => FirebaseCrashlytics.instance.recordError(error, stackTrace),
  );
}
