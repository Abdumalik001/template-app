# Production-Ready Flutter Template & Boilerplate Reorganization Plan

Ushbu reja **Cactus HR** loyihasini kelajakda istalgan yangi loyiha uchun kuchli, xavfsiz va toza arxitekturaga ega **baza (boilerplate/starter kit)** darajasiga olib chiqish bo'yicha bosqichma-bosqich qo'llanma hisoblanadi.

---

## 1. Network qatlami & DioClient optimizatsiyasi

### 1.1. Muammo va Joriy holat
- `dio_client.dart` ichida `get dio` har safar yangi `Dio` nusxasini yaratadi (`_createDio()`) va interceptorlarni qayta ulaydi.
- Bu HTTP keep-alive va connection pooling xususiyatlarini buzadi, ortiqcha xotira va socket resurslarini sarflaydi.

### 1.2. Qilinadigan ishlar
- [ ] **Bitta Singleton Dio instansiyasi**: `Dio`ni faqat bir marta initsializatsiya qilinadigan qilib o'zgartirish.
- [ ] **Dinamik AuthInterceptor**: Tokenni har bir so'rov oldidan (`onRequest`) to'g'ridan-to'g'ri storage'dan olib `Authorization: Bearer <token>` sifatida qo'shish.
- [ ] **Token Refresh / 401 Handler**: JWT access token eskirganida `QueuedInterceptor` orqali refresh token so'rovini yuborish va kutib turgan boshqa so'rovlarni yangi token bilan qayta jo'natish (retry) mexanizmi.

---

## 2. Xatoliklarni boshqarish (Centralized Error & Failure Handling)

### 2.1. Muammo va Joriy holat
- Faqat `ServerFailure`, `NoDataFailure`, `CacheFailure` mavjud.
- Internet yo'qligi (`SocketException`), server timeout (`ConnectionTimeout`) yoki sessiya tugashi (`Unauthorized`) uchun alohida semantik xatolar va ularga mos foydalanuvchi xabarlari yo'q.

### 2.2. Qilinadigan ishlar
- [x] **Kengaytirilgan Failure turlari**:
  - `NetworkFailure` — Internet aloqasi yo'q bo'lganda.
  - `TimeoutFailure` — Server javob berish vaqti tugaganda.
  - `UnauthorizedFailure` — Sessiya eskirganda / ruxsat berilmaganda.
  - `ServerFailure` — Serverdan kelgan xatolik xabari bilan.
  - `UnknownFailure` — Kutilmagan tizim xatoliklari uchun.
- [x] **DioErrorConverter / ErrorHandler**: DioException'larni avtomatik tegishli `Failure`ga o'girib beruvchi yordamchi utility yaratish (`DioErrorHandler`).

---

## 3. Xotira va Cubit Lifecycle boshqaruvi (DI & Memory Management)

### 2.1. Muammo va Joriy holat
- Hamma Cubitlarni `registerLazySingleton` qilish xotira oqishiga (memory leak) olib kelishi mumkin. Sahifadan chiqib ketilganda resurslar bo'shamaydi.

### 3.2. Qilinadigan ishlar
- [ ] **Cubitlarni ajratish**:
  - **Global / App-level Cubitlar**: `AuthCubit`, `SettingsCubit`, `ProfileCubit` -> `registerLazySingleton`.
  - **Page-level / Feature Cubitlar**: Forma va ro'yxat cubitlari (`UsersCubit`, `DetailCubit`) -> `registerFactory` (sahifa yopilganda avtomatik dispose bo'lishi uchun).
- [ ] **Keshni Repository qatlamiga ko'chirish**: Sahifaga qaytganda ma'lumotlar qayta yuklanmasligi uchun keshni Cubitda emas, Repository / Local DataSource (Hive yoki Memory Cache) darajasida saqlash.

---

## 4. Xavfsiz saqlash (Secure Storage Integratsiyasi)

### 4.1. Muammo va Joriy holat
- Loyihada `flutter_secure_storage` bor, lekin tokenlar va maxfiy ma'lumotlar oddiy Hive qutisiga yozilmoqda.

### 4.2. Qilinadigan ishlar
- [ ] **Gibrid Storage arxitekturasi**:
  - Token, Refresh token va foydalanuvchi pin/parollarini `FlutterSecureStorage`da saqlash.
  - Til, tema, kesh ma'lumotlarni Hive'da saqlash.
  - Barchasini bitta `AppStorageContract` orqali shaffof boshqarish.

---

## 5. Universal UI Kit & Reusable Widgets

### 5.1. Qilinadigan ishlar
- [x] **Universal Input (`TextF`)**: Validatsiya, avtomatik `isPassword` obscure (ko'zcha) tugmasi, xatolik ko'rsatish, prefix/suffix tayyorlangan vidjet.
- [x] **Universal Button (`Button`)**: `filled`, `outlined`, `text`, `isLoading` (ichida loading aylanadigan), leading/trailing icon va disabled holatlari bilan.
- [x] **Status Vidjetlari**:
  - `Empty` — Ma'lumot yo'q bo'lganda chiroyli rasm/ikonka, izoh va harakat (action) tugmasi bilan.
  - `AppErrorView` — Xatolik yuz berganda xato ikonkasi, matni va "Qayta urinish" (Retry) tugmasi bilan.
- [x] **Universal PaginatedListView**: Scroll pagination (`maxScroll - currentScroll <= 150`), pull-to-refresh (`onRefresh`) va pagination loader mantiqini o'z ichiga olgan qulay vidjet.

---

## 6. Loyiha nomini o'zgartirish (Project Renamer Script)

### 6.1. Qilinadigan ishlar
- [x] Ushbu loyihani klon qilib yangi nom bilan boshlash uchun `scripts/rename_project.py` skripti yaratildi va avtomatlashtirildi:
  - `pubspec.yaml` dagi paket nomi va tavsifini o'zgartirish;
  - Android package name (`applicationId`, `namespace`, manifestlar, `strings.xml`, Kotlin `MainActivity.kt` papkasi);
  - iOS bundle identifier (`project.pbxproj`), `Info.plist`dagi `CFBundleDisplayName` va `APP_DISPLAY_NAME`;
  - Barcha Dart importlarini (`package:cactus_hr/...` -> `package:yangi_nom/...`) yangilash;
  - `--dry-run` rejimida oldindan xavfsiz tekshirib olish imkoniyati.

---

## 7. Testlar va Sifat nazorati (Test Stubs & CI)

### 7.1. Qilinadigan ishlar
- [ ] `test/` papkasini qayta tiklash:
  - Repository / UseCase uchun 1 ta namunaviy Unit test (Mocktail yoki Mockito orqali).
  - Cubit uchun 1 ta `bloc_test` namunasi.
- [ ] GitHub Actions CI workflow faylini `.github/workflows/ci.yml` ga tekshirib qo'yish (`analyze` va `test` avtomat tekshiruvi uchun).

---

## Amalga oshirish tartibi (Roadmap)

| Bosqich | Qism | Maqsad |
|---|---|---|
| **1-bosqich** | `DioClient` & `AuthInterceptor` | Network connection pooling va toza token boshqaruvi |
| **2-bosqich** | Error Handling & Failures | Barcha xatoliklarni semantik `Failure`larga o'girish |
| **3-bosqich** | Secure Storage Integratsiyasi | Maxfiy ma'lumotlarni xavfsiz shifrlab saqlash |
| **4-bosqich** | UI Kit (Input, Button, States) | Universal komponentlarni standartlashtirish |
| **5-bosqich** | DI & Repository Caching | To'g'ri lifecycle va RAM optimizatsiyasi |
| **6-bosqich** | Project Renamer & Test namunalari | Yangi loyiha ochishni 1 daqiqaga tushirish |
