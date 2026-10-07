import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

enum ActiveTheme {
  light(ThemeMode.light),
  dark(ThemeMode.dark),
  system(ThemeMode.system);

  final ThemeMode mode;

  const ActiveTheme(this.mode);
}

enum PrefKey { theme, locale, isFirstInstall, isLogin }

enum SecureKey { token, refreshToken, fcm }

abstract interface class AppStorageContract {
  Future<void> init(String prefix);

  T? getPref<T>(PrefKey key);

  Future<void> setPref<T>(PrefKey key, T value);

  Future<void> removePref(PrefKey key);

  String? get token;

  Future<String?> get refreshToken;

  String? get fcm;

  Stream<String> get listenerStream;

  Stream<bool> get isLoggedInStream;

  bool get isLoggedIn;

  Future<void> saveTokens({required String access, required String refresh});

  Future<void> saveFcmToken(String fcmToken);

  Future<void> clearSession();
}

class AppStorage implements AppStorageContract {
  AppStorage([FlutterSecureStorage? secure])
    : _secure = secure ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;
  late final Box<dynamic> _box;
  final StreamController<String> _listener =
      StreamController<String>.broadcast();

  String? _tokenCache;
  String? _fcmCache;

  Box<dynamic> get box => _box;

  @override
  Stream<String> get listenerStream => _listener.stream;

  @override
  Stream<bool> get isLoggedInStream => _listener.stream
      .where((key) => key == PrefKey.isLogin.name)
      .map((_) => isLoggedIn);

  @override
  bool get isLoggedIn => getPref<bool>(PrefKey.isLogin) ?? false;

  @override
  Future<void> init(String prefix) async {
    await Hive.initFlutter();
    _box = await Hive.openBox('${prefix}template_app');

    // 1. iOS reinstall va yangi o'rnatilish holati
    if (_box.get(PrefKey.isFirstInstall.name) == null) {
      try {
        await _secure.deleteAll();
      } on PlatformException {
        // PlatformException sodir bo'lsa xavfsiz o'tib ketiladi
      } catch (_) {}
      await _box.put(PrefKey.isFirstInstall.name, false);
    }

    // 2. Tokenlarni xotiraga yuklash (Android Keystore corruptiondan himoya)
    try {
      _tokenCache = await _secure.read(key: SecureKey.token.name);
      _fcmCache = await _secure.read(key: SecureKey.fcm.name);
    } on PlatformException {
      try {
        await _secure.deleteAll();
      } catch (_) {}
      _tokenCache = null;
      _fcmCache = null;
    } catch (_) {
      _tokenCache = null;
      _fcmCache = null;
    }
  }

  // --- Preferences (Hive) ---

  @override
  T? getPref<T>(PrefKey key) {
    try {
      final value = _box.get(key.name);
      return value is T ? value : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setPref<T>(PrefKey key, T value) async {
    await _box.put(key.name, value);
    _listener.add(key.name);
  }

  @override
  Future<void> removePref(PrefKey key) async {
    await _box.delete(key.name);
    _listener.add(key.name);
  }

  // --- Secure Storage (Keystore / Keychain) ---

  @override
  String? get token => _tokenCache;

  @override
  Future<String?> get refreshToken async {
    try {
      return await _secure.read(key: SecureKey.refreshToken.name);
    } on PlatformException {
      try {
        await _secure.deleteAll();
      } catch (_) {}
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  String? get fcm => _fcmCache;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _tokenCache = access;
    try {
      await Future.wait([
        _secure.write(key: SecureKey.token.name, value: access),
        _secure.write(key: SecureKey.refreshToken.name, value: refresh),
        setPref(PrefKey.isLogin, true),
      ]);
    } on PlatformException {
      try {
        await _secure.deleteAll();
      } catch (_) {}
      _tokenCache = null;
    } catch (_) {}
  }

  @override
  Future<void> saveFcmToken(String fcmToken) async {
    _fcmCache = fcmToken;
    try {
      await _secure.write(key: SecureKey.fcm.name, value: fcmToken);
    } on PlatformException {
      try {
        await _secure.deleteAll();
      } catch (_) {}
    } catch (_) {}
  }

  @override
  Future<void> clearSession() async {
    _tokenCache = null;
    try {
      await Future.wait([
        _secure.delete(key: SecureKey.token.name),
        _secure.delete(key: SecureKey.refreshToken.name),
        removePref(PrefKey.isLogin),
      ]);
    } on PlatformException {
      try {
        await _secure.deleteAll();
      } catch (_) {}
      await removePref(PrefKey.isLogin);
    } catch (_) {
      await removePref(PrefKey.isLogin);
    }
  }
}
