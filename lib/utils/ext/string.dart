import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oktoast/oktoast.dart';

extension StringExtension on String {
  bool isValidEmail() => RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(this);

  //https://github.com/ponnamkarthik/FlutterToast/issues/262
  //coverage:ignore-start
  void toToastError({bool isUnitTest = false}) {
    try {
      final message = isEmpty ? 'error' : this;

      //dismiss before show toast
      dismissAllToast(showAnim: true);

      showToastWidget(
        Toast(
          bgColor: Palette.error,
          icon: Icons.error,
          message: message,
          textColor: Palette.onError,
        ),
        dismissOtherToast: true,
        position: ToastPosition.top,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      if (!isUnitTest) {
        FirebaseCrashLogger().nonFatalError(error: e, stackTrace: stackTrace);
      }
      log.e('error $e');
    }
  }

  void toToastSuccess({bool isUnitTest = false}) {
    try {
      final message = isEmpty ? 'success' : this;

      //dismiss before show toast
      dismissAllToast(showAnim: true);

      showToastWidget(
        Toast(
          bgColor: Palette.primary,
          icon: Icons.check_circle,
          message: message,
          textColor: Palette.onPrimary,
        ),
        dismissOtherToast: true,
        position: ToastPosition.top,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      if (!isUnitTest) {
        FirebaseCrashLogger().nonFatalError(error: e, stackTrace: stackTrace);
      }
      log.e('$e');
    }
  }

  void toToastLoading({bool isUnitTest = false}) {
    try {
      final message = isEmpty ? 'loading' : this;
      //dismiss before show toast
      dismissAllToast(showAnim: true);

      showToastWidget(
        Toast(
          bgColor: Palette.tertiary,
          icon: Icons.info,
          message: message,
          textColor: Palette.onTertiary,
        ),
        dismissOtherToast: true,
        position: ToastPosition.top,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      if (!isUnitTest) {
        FirebaseCrashLogger().nonFatalError(error: e, stackTrace: stackTrace);
      }
      log.e('$e');
    }
  }

  //coverage:ignore-end

  String toStringDateAlt({bool isShort = false, bool isToLocal = true}) {
    try {
      DateTime object;
      if (isToLocal) {
        object = DateTime.parse(this).toLocal();
      } else {
        object = DateTime.parse(this);
      }

      return DateFormat(
        "dd ${isShort ? "MMM" : "MMMM"} yyyy HH:mm",
        'id',
      ).format(object);
    } catch (_) {
      return '-';
    }
  }
}
