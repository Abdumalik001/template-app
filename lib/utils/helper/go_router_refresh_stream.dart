import 'dart:async';

import 'package:material_ui/material_ui.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    for (final stream in streams) {
      _subscriptions.add(stream.listen((dynamic _) => notifyListeners()));
    }
  }

  @override
  void dispose() {
    try {
      for (final subscription in _subscriptions) {
        subscription.cancel(); //coverage:ignore-line
      }
    } catch (_) {}
    super.dispose();
  }
}
