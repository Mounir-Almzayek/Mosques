# تصميم: طبقة كاش أوفلاين موحّدة + بنية صور موحّدة

**التاريخ:** 2026-05-29
**المشروع:** Tebyan (تطبيق إدارة عرض المساجد) — Flutter / BLoC / Firestore / Hive

---

## 1. الهدف والدافع

عند فتح أي واجهة، التطبيق حالياً ينتظر استجابة Firestore قبل أن يعرض جزءاً من البيانات
(`getActiveMosque()` و `getAppSettings()` يستخدمان `.get()` الذي ينتظر الشبكة قبل العرض، ويرجعان
الكاش فقط عند الفشل). المطلوب:

1. **Cache-first دائماً:** عرض الكاش فوراً بدون أي انتظار للشبكة، مع تحديث بالخلفية.
2. **طبقة كاش موحّدة (generic):** إزالة التكرار الموجود في الـ `*LocalRepository` الثلاثة
   (منطق `_sanitizeForHive` و `toMap/fromMap` مكرّر في كل واحد).
3. **بنية صور موحّدة:** نقطة دخول واحدة لعرض الصور، مع **تخزين أوفلاين دائم** للصور المرتبطة
   بالبيانات (لا يُمسح تلقائياً)، بحيث يعمل لاونش أوفلاين كامل يعرض كل شيء بما فيه الصور.

### مبادئ التصميم
- OOP نظيف يطابق أعراف المشروع: واجهات `I*` + تنفيذ، تسجيل عبر `get_it`، نماذج `Equatable` بـ `toMap/fromMap`.
- بقاء التسلسل (serialization) عبر `toMap/fromMap` كـ Map/JSON (بلا Hive TypeAdapters، بلا codegen).
- وحدات صغيرة محدّدة المسؤولية، قابلة للاختبار باستقلالية.

---

## 2. طبقة الكاش الموحّدة للبيانات

موقع جديد: `lib/core/cache/`

### 2.1 `ICacheStore` (واجهة) — `lib/core/cache/i_cache_store.dart`
عقد تخزين منخفض المستوى لا يعرف شيئاً عن النماذج:
```dart
abstract class ICacheStore {
  Future<void> write(String key, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> read(String key);
  Future<void> delete(String key);
  Future<List<String>> keys();
}
```

### 2.2 `HiveCacheStore` (تنفيذ) — `lib/core/cache/hive_cache_store.dart`
- يلفّ `HiveService` الموجود.
- يحوي منطق **`_sanitizeForHive` (Timestamp → millisecondsSinceEpoch)** في **مكان وحيد**، يُحذف
  من الـ `*LocalRepository` الثلاثة.
- يخزّن "ظرف" (envelope) حول البيانات:
  ```json
  { "_cachedAt": 1730000000000, "_schemaVersion": 1, "data": { ... } }
  ```
  `read` يفك الظرف ويرجّع `data` فقط (مع تمرير `_cachedAt` عبر `CacheEntry`).

### 2.3 `CacheEntry<T>` — `lib/core/cache/cache_entry.dart`
قيمة غير قابلة للتغيير: `final T value; final DateTime cachedAt;`. تسمح للمستهلكين بمعرفة عمر الكاش.

### 2.4 `CachePolicy` — `lib/core/cache/cache_policy.dart`
value object: `final Duration? maxAge; final int schemaVersion;`
- `bool isStale(DateTime cachedAt)` — لتقرير إطلاق refresh بالخلفية (الكاش يُعرض دائماً بغض النظر).
- `bool isCompatible(int storedVersion)` — كاش بنسخة schema قديمة غير متوافقة يُتجاهل (يُعامل كأنه غير موجود).

### 2.5 `JsonCache<T>` (generic، بالتركيب) — `lib/core/cache/json_cache.dart`
```dart
class JsonCache<T> {
  JsonCache({
    required ICacheStore store,
    required String cacheKey,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    CachePolicy policy = const CachePolicy(),
  });

  Future<void> save(T value);
  Future<CacheEntry<T>?> read();   // يرجّع null عند عدم التوافق أو غياب الكاش أو فشل الـ decode
  Future<void> clear();
}
```
- يتولّى الظرف + `toJson/fromJson` + التعامل مع نسخة الـ schema.
- صفر تكرار: كل local repo يصير سطر إنشاء `JsonCache` واحد بدل صف static methods.

### 2.6 `CacheFirstLoader<T>` — قلب الـ cache-first — `lib/core/cache/cache_first_loader.dart`
```dart
class CacheFirstLoader<T> {
  CacheFirstLoader(this._cache, {ImageSyncService? imageSync});

  /// للشاشات الحيّة (شاشة العرض):
  /// 1) يُطلق قيمة الكاش فوراً إن وُجدت  2) يمرّر ستريم Firestore الحي
  /// 3) يحفظ كل تحديث في الكاش  4) يزامن صور البيانات (إن مُرّر imageSync)
  Stream<T?> stream({required Stream<T?> Function() remote});

  /// لقراءة لمرة واحدة: يرجّع الكاش فوراً، يحدّث ويحفظ بالخلفية.
  Stream<T?> once({required Future<T?> Function() remote});
}
```
- الفرق الجوهري عن السلوك الحالي: السلوك الحالي ينتظر `.get()` ثم يرجّع الكاش عند الفشل فقط.
  الجديد يُطلق الكاش **قبل** أن يبدأ انتظار الشبكة أصلاً.

### 2.7 دمج الريبوزات
- `MosqueRepository`, `AppSettingsRepository`, `PlatformAnnouncementsRepository` تأخذ
  `JsonCache<T>` المناسب (تُحقن عبر `service_locator.dart`).
- `getActiveMosque()` / `getAppSettings()` تتحوّل إلى cache-first (ترجّع تيار يبدأ بالكاش)، أو
  تبقى الواجهة `Future` لكن ترجّع الكاش فوراً وتُطلق refresh بالخلفية — حسب ما يناسب كل مستهلك.
  الستريمات (`streamActiveMosque`, `streamAppSettings`, `watch*`) تُغلّف بـ `CacheFirstLoader.stream`.
- يُحذف التكرار من `mosque_local_repository.dart` و `app_settings_local_repository.dart` و
  `platform_announcements_local_repository.dart`؛ تُستبدل بـ `JsonCache` instances (مع الإبقاء على
  منطق "الكاش يطابق المسجد الفعّال" في `MosqueRepository`/`JsonCache` key).

### 2.8 التسجيل (`service_locator.dart`)
```dart
sl.registerLazySingleton<ICacheStore>(() => HiveCacheStore());
// JsonCache<MosqueModel>, JsonCache<AppSettingsModel>, ... تُنشأ داخل الريبوزات أو تُحقن.
```

---

## 3. بنية الصور الموحّدة + التخزين الأوفلاين الدائم

موقع: `lib/core/cache/` (الخدمات) و `lib/core/widgets/media/` (الـ widget).

### 3.1 `OfflineImageStore` (service) — `lib/core/cache/offline_image_store.dart`
- مجلد دائم عبر `path_provider`: `<appDocumentsDirectory>/offline_images/`.
- اسم الملف = `sha1(url)` (+ امتداد مستنتج). لا يُمسح تلقائياً (عكس كاش `cached_network_image`).
```dart
class OfflineImageStore {
  Future<void> init();                          // ينشئ المجلد
  Future<File?> fileFor(String url);            // الملف المحلي إن وُجد، بلا شبكة
  Future<File> fetchAndStore(String url);       // ينزّل ويحفظ بشكل دائم
  Future<void> prune(Set<String> keepUrls);     // يحذف الصور غير الموجودة في keepUrls
  Future<void> clear();
}
```

### 3.2 `ImageSyncService` — `lib/core/cache/image_sync_service.dart`
- يستخرج كل URLات الصور من البيانات الواصلة ويضمن حفظها دائماً + يحذف اليتيمة:
  - من `MosqueModel`: `albumImageUrls`, `publishedAlbumImageUrl`, `designSettings.backgroundValue` (إن كان http).
  - من `AppSettingsModel`: `backgroundLibraryUrls`.
```dart
class ImageSyncService {
  ImageSyncService(this._store);
  Future<void> syncMosque(MosqueModel mosque);
  Future<void> syncAppSettings(AppSettingsModel settings);
}
```
- يُستدعى من `CacheFirstLoader` بعد كل حفظ ناجح، أو من الريبوزات عند نجاح التحديث. بدون انتظار
  يحجب الواجهة (fire-and-forget مع التقاط الأخطاء بصمت).

### 3.3 `AppImage` (widget موحّد) — `lib/core/widgets/media/app_image.dart`
نقطة الدخول الوحيدة لكل الصور؛ يستبدل الاستخدام المباشر لـ `CachedNetworkImage` و `CachedImage`:
```dart
AppImage.network(url, ...)              // يحلّ: ملف المخزن الدائم → شبكة (مع كاش) → placeholder/error
AppImage.asset(path, ...)              // يستخدم منطق OptimizedImage داخلياً
AppImage.network.background(url)        // ملء الشاشة
AppImage.network.thumbnail(url, size)   // مربّع صغير بحواف دائرية
```
- **آلية الحلّ للصور الشبكية:** يفحص `OfflineImageStore.fileFor(url)` أولاً → إن وُجد يعرض
  `Image.file` (decode بحجم مناسب، أوفلاين بحت). إن لم يوجد، يعرض عبر `CachedNetworkImage`
  (شبكة + كاش انتقالي) ويُطلق `fetchAndStore` بالخلفية لتثبيتها للمرّة القادمة.
- placeholder / error styling موحّد في مكان واحد (نفس ألوان `CachedImage` الحالية:
  `0xFFE8EDED` / `0xFFA8BFBE`).

### 3.4 العلاقة بـ `OptimizedImage` و `CachedImage`
- `OptimizedImage` يبقى كـ helper داخلي لفك ضغط الـ assets بحجم مناسب (`AppImage.asset` يستخدمه).
- `CachedImage` يُدمج في `AppImage` ثم يُحذف بعد ترحيل كل المستهلكين.

### 3.5 مواقع الترحيل (migration)
| الملف | الحالي | بعد |
|------|--------|-----|
| `display_background_image.dart` | `CachedNetworkImage` مباشر | `AppImage.network.background` |
| `layers/photo_studio_layer.dart` | `CachedNetworkImage` مباشر | `AppImage.network.background` |
| `settings/album/widgets/album_grid_cell.dart` | `CachedImage` | `AppImage.network` |
| `settings/album/widgets/album_publish_bottom_sheet.dart` | `CachedImage`/`CachedNetworkImage` | `AppImage.network` |
| `settings/design/widgets/album_url_image_card.dart` | `CachedImage` | `AppImage.network` |
| `settings/design/widgets/display_background_picker.dart` | `CachedImage` | `AppImage.network.thumbnail` |
| `core/widgets/forms/profile_image_picker.dart` | `Image.file` | يبقى (ملف محلي مؤقت من المعرض) |
| الـ logos / login / splash (assets) | `Image.asset` | `AppImage.asset` (اختياري، توحيد) |

> ملاحظة: `SvgPicture.asset` في `prayer_card_background.dart` خارج النطاق (SVG ملوّن، ليس صورة شبكية).

---

## 4. التهيئة والتسجيل

- `OfflineImageStore.init()` و `HiveCacheStore` يُهيّآن في bootstrap (بجانب `HiveService.init()` في `main`).
- تسجيل `ICacheStore`, `OfflineImageStore`, `ImageSyncService` في `service_locator.dart`.
- `AppImage` يصل لـ `OfflineImageStore` عبر `sl<OfflineImageStore>()`.

---

## 5. التعامل مع الأخطاء

- قراءة كاش فاشلة (decode/توافق نسخة) ⇒ تُعامل كغياب كاش (تُرجِع null)، ولا ترمي استثناء.
- فشل تنزيل صورة ⇒ يُلتقط بصمت؛ تبقى الصورة تُعرض عبر الشبكة عند توفرها لاحقاً.
- `prune`/`fetchAndStore` لا يحجبان الواجهة أبداً (fire-and-forget مع try/catch).
- منطق الـ fallback عند خطأ الستريم (الموجود حالياً) يُحفظ ضمن `CacheFirstLoader`.

---

## 6. الاختبارات

- `JsonCache`: round-trip كامل بما فيه sanitize للـ `Timestamp`؛ تجاهل كاش بنسخة schema غير متوافقة؛ إرجاع null عند decode فاشل.
- `CachePolicy`: `isStale` / `isCompatible`.
- `OfflineImageStore`: save/get/prune/clear على مجلد مؤقت (بدون شبكة فعلية — يُحقن downloader قابل للـ mock).
- `ImageSyncService`: استخراج URLات صحيح + prune يحذف اليتيمة فقط.
- `CacheFirstLoader`: يُطلق الكاش أولاً ثم قيمة الشبكة (باستخدام fakes للـ cache والـ remote stream).

---

## 7. خارج النطاق (YAGNI)

- لا Hive TypeAdapters / codegen.
- لا تغيير لمنطق Firestore الكتابي (`update*`).
- لا تغيير لـ SVG / الأيقونات.
- لا طبقة decorator منفصلة للريبوزات (اخترنا الطبقة العامة المباشرة).
