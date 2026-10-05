# Cactus HR — Arxitektura va Xavfsizlik Auditi Hisoboti
> **Sana:** 2026-10-05  
> **Auditor roli:** Senior Mobile Architect & Security Auditor  
> **Loyiha:** `cactus_hr` (Flutter + Clean Architecture + Cubit + Dio + Freezed + Hive)  
> **Holati:** Tahlil yakunlangan

---

## MUNDARIJA
1. [Ijrochi Xulosasi (Executive Summary)](#1-ijrochi-xulosasi-executive-summary)
2. [Xavfsizlik va Ma'lumotlar Maxfiyligi (Security & Secrets)](#2-xavfsizlik-va-malumotlar-maxfiyligi-security--secrets)
3. [Arxitektura va Clean Architecture Buzilishlari (Architecture Flaws)](#3-arxitektura-va-clean-architecture-buzilishlari-architecture-flaws)
4. [Xotira Sizishi (Memory Leaks) va Flutter Anti-patternlari](#4-xotira-sizishi-memory-leaks-va-flutter-anti-patternlari)
5. [Holat Boshqaruvi va Reaktivlik Muammolari (State Management)](#5-holat-boshqaruvi-va-reaktivlik-muammolari-state-management)
6. [Tarmoq va Barqarorlik (Resilience & Networking)](#6-tarmoq-va-barqarorlik-resilience--networking)
7. [Foydalanilmagan O'lik Kodlar (Dead Code)](#7-foydalanilmagan-olik-kodlar-dead-code)
8. [Tavsiya Etilgan Harakatlar Rejasi (Action Plan)](#8-tavsiya-etilgan-harakatlar-rejasi-action-plan)

---

## 1. IJROCHI XULOSASI (EXECUTIVE SUMMARY)

Loyiha bazasi zamonaviy texnologik stekda (Clean Architecture, Cubit, Freezed, GetIt, Dio) qurilgan bo'lib, test qamrovi yaxshi (179 ta test mavjud). Biroq, kod bazasini chuqur tahlil qilish natijasida quyidagi asosiy xavflar aniqlandi:

- **Xavfsizlik bo'yicha:** Sezgir JWT tokenlarining UI'da ochiq ko'rsatilishi, logcat'ga barcha auth header'lar va parollar sizishi, Hive bazasining shifrlanmaganligi hamda `.env` fayllar Git'da ochiq saqlanayotgani.
- **Arxitektura bo'yicha:** Clean Architecture qoidalarining buzilishi — Domain UseCase'larning to'g'ridan-to'g'ri Hive storage'iga qaram bo'lib qolgani (`MainBoxMixin`), "God Object" model (`DataHelper`) va Response modellarning barrel fayllar orqali tashqariga sizishi.
- **Ishlash va barqarorlik bo'yicha:** `static late BuildContext` orqali xotira sizishi (memory leak), har bir tarmoq so'rovida yangi `Dio` yaratilishi va cheksiz oq ekranga olib keluvchi yutilgan xatolar.

---

## 2. XAVFSIZLIK VA MA'LUMOTLAR MAXFIYLIGI (SECURITY & SECRETS)

### 2.1. [Severity: High] Sezgir Tokenlar va Parollarning Tizim Loglariga Ochiq Yozilishi
- **Fayl joylashuvi:**
  - `lib/core/api/dio_interceptor.dart:24-44`
  - `lib/core/api/dio_interceptor.dart:212-223`
  - `lib/utils/helper/common.dart:6-9`
- **Tavsif:** `DioInterceptor` har bir HTTP so'rov va javobning barcha header'larini (jumladan `Authorization: Bearer <token>`) va request body'sini (Login/Register paytidagi parollar, shaxsiy ma'lumotlar) `log.d()` orqali chiqaradi. `common.dart` dagi `Logger` esa `kReleaseMode` filtrisiz ishlaydi. Natijada foydalanuvchilarning login, parol va sessiya tokenlari Android `logcat` va iOS system console oqimiga tushadi.
- **Muammoli kod:**
```dart
// lib/core/api/dio_interceptor.dart
String headerMessage = '';
options.headers.forEach((k, v) => headerMessage += '► $k: $v\n');

final String prettyJson = encoder.convert(options.data);
log.d(
  "REQUEST ► ︎ ${options.method.toUpperCase()} ${"${options.baseUrl}${options.path}"}\n\n"
  'Headers:\n$headerMessage\n'
  '❖ QueryParameters : \n'
  'Body: $prettyJson',
);
```
- **Tavsiya etilgan to'g'rilash:**
Release muhitida loglarni butunlay o'chirish (`Level.off`), sezgir header'larni (`Authorization`, `client_secret`) va parollarni maskalash:
```dart
// lib/utils/helper/common.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final log = Logger(
  printer: PrettyPrinter(methodCount: 1, lineLength: 110),
  output: MyConsoleOutput(),
  level: kReleaseMode ? Level.off : Level.debug,
);

// lib/core/api/dio_interceptor.dart
final sanitizedHeaders = Map<String, dynamic>.from(options.headers)
  ..update('Authorization', (_) => 'Bearer [REDACTED]', ifAbsent: () => null);
```

---

### 2.2. [Severity: High] Auth va Refresh Tokenlarning Shifrlanmagan Storage'da Saqlanishi
- **Fayl joylashuvi:** `lib/utils/services/hive/main_box.dart:30-34`
- **Tavsif:** `Hive.openBox('$prefixBox$_boxName')` shifrlash kalitisiz (plain-text fayl ko'rinishida) ochiladi. Unda esa `authToken`, `refreshToken`, `apiClientId` kabi eng muhim avtorizatsiya ma'lumotlari saqlanadi. Root qilingan Android yoki Jailbreak qilingan iOS qurilmalarda, shuningdek ADB zahira nusxasi (backup) olinganda tajovuzkor bu tokenlarni to'g'ridan-to'g'ri o'qib olishi mumkin.
- **Muammoli kod:**
```dart
static Future<void> initHive(String prefixBox) async {
  await Hive.initFlutter();
  mainBox = await Hive.openBox('$prefixBox$_boxName');
}
```
- **Tavsiya etilgan to'g'rilash:**
Tokenlarni `flutter_secure_storage` (iOS Keychain / Android Keystore) ichida saqlash yoki Hive uchun 256-bitli kalit yaratib, `HiveAesCipher` bilan shifrlangan box ochish:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

static Future<void> initHive(String prefixBox) async {
  await Hive.initFlutter();
  const secureStorage = FlutterSecureStorage();
  final keyString = await secureStorage.read(key: 'hive_enc_key');
  final List<int> encryptionKey;
  if (keyString == null) {
    encryptionKey = Hive.generateSecureKey();
    await secureStorage.write(key: 'hive_enc_key', value: base64UrlEncode(encryptionKey));
  } else {
    encryptionKey = base64Url.decode(keyString);
  }

  mainBox = await Hive.openBox(
    '$prefixBox$_boxName',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

---

### 2.3. [Severity: High] Muvaffaqiyatli Login Bo'lganda Raw Tokenlarning Ekranda Toast Orqali Chiqishi
- **Fayl joylashuvi:** `lib/features/auth/pages/login/login_page.dart:51`
- **Tavsif:** Login muvaffaqiyatli yakunlanganda `data.toString().toToastSuccess(context);` chaqiriladi. `data` bu `Login(token: ..., refreshToken: ...)` obyekti bo'lib, uning string ko'rinishi foydalanuvchining butun JWT tokeni va refresh tokenini ekran tepasida 3 soniya ko'rsatib turadi ("shoulder surfing", screen recorder orqali token sizishi).
- **Muammoli kod:**
```dart
AuthStateSuccess(:final data) => (() {
  context.dismiss();
  data.toString().toToastSuccess(context); // ⚠️ BUTUN TOKEN EKRANDA CHIQMOQDA

  TextInput.finishAutofillContext();
  context.goNamed(Routes.root.name);
})(),
```
- **Tavsiya etilgan to'g'rilash:**
```dart
AuthStateSuccess() => (() {
  context.dismiss();
  Strings.of(context)!.loginSuccess.toToastSuccess(context);

  TextInput.finishAutofillContext();
  context.goNamed(Routes.root.name);
})(),
```

---

### 2.4. [Severity: High] `.env` Fayllar va Credentiallarning Repozitoriyda Ochiq Saqlanishi
- **Fayl joylashuvi:**
  - `.env.prd.json:3-17`
  - `.env.stg.json:3-17`
  - `.gitignore`
- **Tavsif:** `.env.prd.json` va `.env.stg.json` fayllari repozitoriyga ochiq kiritilgan va `.gitignore` faylida e'lon qilinmagan. Ularda `CLIENT_SECRET: "base_auth_secret_789"`, Firebase API kalitlari, App ID va Client ID lar mavjud.
- **Tavsiya etilgan to'g'rilash:**
`.gitignore` fayliga `.env*.json` ni qo'shish va namuna sifatida `.env.example.json` yaratish:
```gitignore
# .gitignore
.env*.json
!.env.example.json
```

---

### 2.5. [Severity: Medium] Android Manifest'da `allowBackup="false"` Yo'qligi
- **Fayl joylashuvi:** `android/app/src/main/AndroidManifest.xml:3`
- **Tavsif:** `<application>` tegida `android:allowBackup="false"` ko'rsatilmagan (Android sukut bo'yicha `true` qiladi). Har qanday shaxs USB kabel orqali `adb backup` qilib ilovaning shifrlanmagan tokenlari va Hive fayllarini kompyuteriga ko'chirib olishi mumkin.
- **Tavsiya etilgan to'g'rilash:**
```xml
<application
    android:label="@string/app_name"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false"
    android:fullBackupContent="false">
```

---

## 3. ARXITEKTURA VA CLEAN ARCHITECTURE BUZILISHLARI (ARCHITECTURE FLAWS)

### 3.1. [Severity: High] Domain Qatlamining Local Storage'ga (Hive) Bog'lanib Qolishi
- **Fayl joylashuvi:**
  - `lib/features/auth/domain/usecases/post_login.dart:10`
  - `lib/features/auth/domain/usecases/post_logout.dart:6`
  - `lib/features/auth/domain/usecases/post_general_token.dart:10`
- **Tavsif:** Clean Architecture qoidasiga ko'ra, **Domain qatlami (UseCase, Entity) hech qanday freymvork, platforma yoki ma'lumotlar bazasiga (Hive) to'g'ridan-to'g'ri bog'lanmasligi shart**. Ushbu loyihada esa UseCaselar `with MainBoxMixin` qilib, to'g'ridan-to'g'ri Hive ga yozmoqda va o'chirmoqda (`addData(MainBoxKeys.authToken, ...)`).
- **Oqibati:**
  1. UseCase'ni Unit test qilishda doim Hive mock qilishga majbur bo'linadi.
  2. Kelajakda Hive o'rniga boshqa storage'ga o'tilsa, Domain qatlamini o'zgartirishga to'g'ri keladi.
- **Tavsiya etilgan to'g'rilash:**
Kesh bilan ishlash mas'uliyati **Repository**ga tegishli bo'lishi kerak (`AuthRepositoryImpl` o'z ichida `AuthRemoteDatasource` va `AuthLocalDatasource`ni birlashtiradi):
```dart
// domain/usecases/post_login.dart
class PostLogin extends UseCase<Login, LoginParams> {
  final AuthRepository _repo;
  PostLogin(this._repo);

  @override
  Future<Either<Failure, Login>> call(LoginParams params) => _repo.login(params);
}

// data/repositories/auth_repository_impl.dart ichida kesh saqlanadi:
final response = await authRemoteDatasource.login(params);
return response.fold((l) => Left(l), (r) async {
  await authLocalDatasource.saveTokens(token: r.token, refreshToken: r.refreshToken);
  return Right(r);
});
```

---

### 3.2. [Severity: Medium] "God Object / Junk Drawer" Modeli (`DataHelper`)
- **Fayl joylashuvi:** `lib/utils/helper/data_helper.dart`
- **Tavsif:** Bitta `DataHelper` klassida `title`, `desc`, `icon`, `url`, `type`, `id`, `isSelected`, `activeTheme` kabi bir-biriga aloqador bo'lmagan maydonlar to'plangan. Bu model Settings holatida (`SettingsState`), Drawer menyusida (`MenuDrawer`) va til tanlashda ishlatilgan.
- **Oqibati:** Single Responsibility (SRP) va Type Safety buziladi.
- **Tavsiya etilgan to'g'rilash:**
Har bir soha uchun aniq entity'lar yaratish:
```dart
// Settings uchun
class SettingsEntity {
  final ActiveTheme theme;
  final String languageCode;
  const SettingsEntity({required this.theme, required this.languageCode});
}

// Menyu uchun
class MenuItemEntity {
  final String title;
  final IconData icon;
  final bool isSelected;
  const MenuItemEntity({required this.title, required this.icon, this.isSelected = false});
}
```

---

### 3.3. [Severity: Medium] API Response Modellarning Barrel Orqali Tashqariga Sizishi
- **Fayl joylashuvi:** `lib/features/general/general.dart:1`
- **Tavsif:** `general.dart` barrel faylida `export 'data/data.dart';` mavjud. Natijada `DiagnosticResponse`, `PageResponse` kabi API modellari UI va Domain qatlamiga sizib chiqadi (`AGENTS.md` 1-qoidasi buzilgan).
- **Tavsiya etilgan to'g'rilash:**
`general.dart` dan `export 'data/data.dart';` qatorini olib tashlash va faqat domain entity'lar hamda sahifalarni eksport qilish.

---

## 4. XOTIRA SIZISHI (MEMORY LEAKS) VA FLUTTER ANTI-PATTERNLARI

### 4.1. [Severity: High] `static late BuildContext` — Xotira Sizishi va Crash Xavfi
- **Fayl joylashuvi:**
  - `lib/utils/ext/context.dart:18, 48`
  - `lib/core/app_route.dart:27, 31`
- **Tavsif:**
  ```dart
  // lib/utils/ext/context.dart
  static late BuildContext ctx;

  // lib/core/app_route.dart
  static late BuildContext context;
  ```
  `BuildContext`ni static o'zgaruvchilarda saqlash quyidagi xatarlarni keltirib chiqaradi:
  1. **Memory Leak:** Eski widget elementlari axlat yig'uvchi (GC) tomonidan tozalanmay, xotirada qolib ketadi.
  2. **Crash xavfi:** Agar `dismiss()` metodi `show()` dan oldin chaqirilsa, `LateInitializationError: Field 'ctx' has not been initialized` xatoligi bilan ilova qulaydi.
  3. `ScreenUtilInit` har safar qayta chizilganda `AppRoute.setStream(context)` orqali statik context qayta-qayta yoziladi.
- **Tavsiya etilgan to'g'rilash:**
Loading dialogini boshqarish uchun `Navigator.of(this, rootNavigator: true)` ishlatish:
```dart
void dismiss() {
  if (Navigator.of(this, rootNavigator: true).canPop()) {
    Navigator.of(this, rootNavigator: true).pop();
  }
}
```

---

### 4.2. [Severity: Medium] Har Bir So'rovda Yangi `Dio` Instansiyasi Yaratilishi
- **Fayl joylashuvi:** `lib/core/api/dio_client.dart:32-50`
- **Tavsif:** `dio` getter'i chaqirilganda har gal `_createDio()` va `dio.interceptors.add(...)` chaqirilib yangi `Dio` obyekti yasaladi. Bu HTTP connection pool (keep-alive) mexanizmini bekor qiladi va har bir so'rovda yangi TLS handshake qilishga majbur etadi.
- **Tavsiya etilgan to'g'rilash:**
Bitta `Dio` instansiyasini saqlab, tokenni `DioInterceptor.onRequest` ichida dinamik biriktirish:
```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  final authToken = token();
  if (authToken != null) {
    options.headers['Authorization'] = authToken;
  }
  super.onRequest(options, handler);
}
```

---

### 4.3. [Severity: Low] `MyAppBar` — Widget Bo'lmagan Sun'iy Klass
- **Fayl joylashuvi:** `lib/core/widgets/my_appbar.dart:3-10`
- **Tavsif:** `MyAppBar` Widget emas, callable class. `register_page.dart` da `appBar: const MyAppBar().call()` qilib ishlatilgan.
- **Tavsiya etilgan to'g'rilash:** Standart `StatelessWidget implements PreferredSizeWidget` ga aylantirish.

---

## 5. HOLAT BOSHQARUVI VA REAKTIVLIK MUAMMOLARI (STATE MANAGEMENT)

### 5.1. [Severity: Medium] Cubit Ichidagi Mutable O'zgaruvchilar
- **Fayl joylashuvi:** `lib/features/general/pages/main/cubit/main_cubit.dart:10-21`
- **Tavsif:** `_currentIndex` va `dataMenus` maydonlari `State` dan tashqarida mutable o'zgaruvchi sifatida saqlanmoqda. `MainPage` da esa `context.read<MainCubit>().dataMenus` qilib state'ga bog'lanmagan holda Cubit o'zgaruvchisi o'qilmoqda.
- **Tavsiya etilgan to'g'rilash:** Barcha holatni `MainState` (immutable) ichiga ko'chirish:
```dart
@freezed
sealed class MainState with _$MainState {
  const factory MainState.loading() = MainStateLoading;
  const factory MainState.success({
    required int currentIndex,
    required List<MenuItemEntity> menus,
  }) = MainStateSuccess;
}
```

---

### 5.2. [Severity: Medium] Paginatsiyadagi Race Condition va Ma'lumot Yo'qolishi (Data Loss)
- **Fayl joylashuvi:** `lib/features/users/pages/dashboard/cubit/users_cubit.dart:29-34`
- **Tavsif:**
  1. `nextPage()` da so'rov bajarilayotganini tekshiruvchi guard (`isLoadingMore`) yo'q. Tez aylantirilganda bir vaqtning o'zida bir nechta sahifa so'rovi ketadi.
  2. Agar keyingi sahifani yuklashda xatolik yuz bersa, `emit(UsersStateFailure(...))` chaqiriladi va oldingi sahifalardagi barcha yuklangan ma'lumotlar ekrandan yo'qolib ketadi.
- **Tavsiya etilgan to'g'rilash:** Xatolik yuz berganda oldingi ro'yxatni saqlab qolish va faqat pastda "Qayta urinish" xabarini chiqarish:
```dart
Future<void> nextPage() async {
  if (_isFetchingMore || currentPage >= lastPage) return;
  _isFetchingMore = true;
  currentPage++;
  final res = await _getUser(UsersParams(page: currentPage));
  res.fold(
    (l) {
      currentPage--; // Sahifani orqaga qaytarish, oldingi ro'yxat saqlanadi
      emit(UsersStatePaginationFailure(message: l.message, currentUsers: users));
    },
    (r) {
      users.addAll(r.users ?? []);
      emit(UsersStateSuccess(data: ...));
    },
  );
  _isFetchingMore = false;
}
```

---

### 5.3. [Severity: Low] `MainPage.didChangeDependencies` dagi Nojo'ya Ta'sir
- **Fayl joylashuvi:** `lib/features/general/pages/main/main_page.dart:23-39`
- **Tavsif:** Har safar til yoki tema o'zgarganda `didChangeDependencies` ishlaydi va `context.read<MainCubit>().initMenu([...])` chaqiriladi. Natijada foydalanuvchi qaysi tabda bo'lishidan qat'i nazar menyu yana boshiga (`0` - Dashboard) otib yuboradi.

---

### 5.4. [Severity: Low] `SettingsPage` dagi Ikki Yoqlama Holat (Duplicated State)
- **Fayl joylashuvi:** `lib/features/general/pages/settings/settings_page.dart:14-36`
- **Tavsif:** `SettingsPage` Cubit mavjud bo'lsa-da `StatefulWidget` qilingan va `BlocBuilder` ishlatmagan. U sozlamalarni `didChangeDependencies` da bir marta o'qib, lokal o'zgaruvchilarda ushlab turadi.

---

## 6. TARMOQ VA BARQARORLIK (RESILIENCE & NETWORKING)

### 6.1. [Severity: Medium] Tarmoq Timeoutlarining 1 Daqiqa Qilib Belgilangani
- **Fayl joylashuvi:** `lib/core/api/dio_client.dart:60-61`
- **Tavsif:** `connectTimeout: Duration(minutes: 1)` va `receiveTimeout: Duration(minutes: 1)`. Mobil foydalanuvchilar internet sekinlashganda 60 soniya qotib turgan ekranga qarab o'tirishga majbur bo'ladi. Mobil ilovalarda optimal timeout: **15–20 soniya**.

---

### 6.2. [Severity: Medium] Splash Screendagi Yutilgan Xatolik (Abadiy Oq Ekran)
- **Fayl joylashuvi:** `lib/features/general/pages/splashscreen/splash_screen_page.dart:19-21`
- **Tavsif:** `GeneralTokenStateFailure` holatida shunchaki `break;` qilingan. Agar server ishlamasa yoki internet bo'lmasa, foydalanuvchi splash ekranda hech qanday xabarsiz abadiy qolib ketadi.
- **Tavsiya etilgan to'g'rilash:** Xatolik yuz berganda xabar chiqarish va "Qayta urinish" tugmasini ko'rsatish.

---

### 6.3. [Severity: Low] `validateStatus` Mantiqiy Xatosi
- **Fayl joylashuvi:** `lib/core/api/dio_client.dart:62, 79`
- **Tavsif:** `validateStatus: (status) => status! > 0` barcha kodlarni qabul qiladi, so'ng `statusCode < 200 || statusCode > 201` bo'lsa `DioException` tashlanadi. REST standartidagi `204 No Content` ham xato deb hisoblanadi.

---

## 7. FOYDALANILMAGAN O'LIK KODLAR (DEAD CODE)

Loyiha bazasida e'lon qilingan, ammo hech qayerda chaqirilmayotgan kodlar:

| Fayl | O'lik kod | Izoh |
|---|---|---|
| `lib/utils/ext/map.dart:1-13` | `MapExtension.validate()` | Hech qayerda chaqirilmagan. |
| `lib/core/error/exceptions.dart:1-8` | `ServerException`, `CacheException` | Hech qachon throw yoki catch qilinmaydi. |
| `lib/utils/ext/string.dart:67-90` | `toToastLoading()` | Ilovada dialog ishlatilgani sabab chaqirilmaydi. |
| `lib/core/dependencies_injection.dart:34` | `sl.registerSingleton<MainBoxMixin>` | Hech kim `sl<MainBoxMixin>()` chaqirmaydi. |

---

## 8. TAVSIYA ETILGAN HARAKATLAR REJASI (ACTION PLAN)

### 🔴 1-bosqich: Tezkor va Kritik (1-2 kun)
1. `login_page.dart:51` dan ekranda token chiqaruvchi `toToastSuccess` ni olib tashlash.
2. `.env*.json` fayllarini `.gitignore` ga kiritish va `.env.example.json` yaratish.
3. `DioInterceptor` dagi header/body loglarini maskalash va `common.dart` dagi loggerni release rejimida o'chirish (`level: Level.off`).
4. `context.dart` va `app_route.dart` dagi `static late BuildContext` xotira sizishlarini tuzatish.

### 🟡 2-bosqich: Arxitekturaviy Refaktoring (3-5 kun)
1. UseCaselardan `MainBoxMixin` ni chiqarib tashlab, kesh mantiqini `Repository` qatlamiga ko'chirish.
2. `DioClient` ni Singleton qilish va har bir so'rovda yangi `Dio` yaratishni to'xtatish.
3. `DataHelper` o'rniga alohida domain entity'lar (`SettingsEntity`, `MenuItemEntity`) joriy qilish.
4. `general.dart` barrel faylidan `data.dart` eksportini olib tashlash.

### 🟢 3-bosqich: Chidamlilik va UX (2-3 kun)
1. `UsersCubit` dagi paginatsiya poygasini (race condition) to'g'rilash va xatolikda ma'lumot yo'qolishining oldini olish.
2. Splash Screenda xatolik yuz berganda "Qayta urinish" (Retry) tugmasini qo'shish.
3. Tarmoq timeoutlarini 15 soniyaga tushirish va offline holatni tekshiruvchi interceptor ulash.
4. O'lik kodlarni (`map.dart`, `exceptions.dart`, `toToastLoading`) o'chirib tashlash.
