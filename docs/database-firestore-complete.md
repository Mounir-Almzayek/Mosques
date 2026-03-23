# قاعدة البيانات — وثيقة كاملة ومفصّلة

## نظرة عامة

قاعدة البيانات مركزية على **Firebase Firestore**. التطبيق الواحد الذكي يقرأ بيانات المسجد (بما فيها `calculation_method`) ويحسب أوقات الصلاة **محلياً** باستخدام مكتبة **adhan_dart** (إحداثيات + طريقة الحساب)، ولا يخزّن جداول أوقات يومية في Firebase إلا إذا رُغب بذلك لتحسين الأداء. الإعلانات تحتوي على **محتوى QR داخل كل إعلان** (`qr_content`) ويتم توليد رمز الـ QR في التطبيق من هذا المحتوى.

---

## 1. هيكل Firestore (مبسّط)

```
Firebase
├── users/                          (ربط الحسابات بالمساجد)
│   └── {uid}
│       └── mosques/                 (مجموعة فرعية أو مرجعية)
│           └── {mosque_id} + role?
│
├── mosques/                        (المجموعة الرئيسية)
│   └── {mosque_id}                 ← مستند واحد لكل مسجد (كل البيانات أدناه داخله)
│       ├── name, logo_url, city, latitude, longitude
│       ├── calculation_method     ← ديناميكي (يُتحكم به من حساب المسجد)
│       ├── iqama_offsets
│       ├── design_settings
│       ├── hadiths[]               (مصفوفة)
│       ├── mosque_ads[]            (مصفوفة — كل إعلان فيه qr_content)
│       ├── updated_at, last_seen
│       └── (اختياري) owner_uid / allowed_uids
│
└── logs/                           (اختياري — سجل النشاط)
    └── {log_id}
```

**ملاحظة:** أوقات الصلاة **لا تُخزَّن** في مجموعة منفصلة؛ تُحسب في التطبيق من `latitude`، `longitude`، و`calculation_method` باستخدام مكتبة adhan_dart.

---

## 2. مجموعة `mosques` — مستند المسجد (تفصيل كامل)

كل مسجد = مستند واحد في `mosques/{mosque_id}`. إعدادات التصميم والأحاديث والإعلانات مخزنة **داخل** نفس المستند (حقول مضمّنة أو مصفوفات) لتبسيط القراءة والتحديث الفوري.

---

### 2.1 الحقول الأساسية

| الحقل | النوع | مطلوب | الوصف |
|-------|------|--------|--------|
| `name` | string | نعم | اسم المسجد |
| `logo_url` | string | لا | رابط شعار المسجد |
| `city` | string | لا | المدينة (للعرض أو الفلترة لاحقاً) |
| `latitude` | number | نعم | خط العرض (لحساب أوقات الصلاة) |
| `longitude` | number | نعم | خط الطول (لحساب أوقات الصلاة) |
| `calculation_method` | string | نعم | طريقة حساب أوقات الصلاة — **ديناميكي** يتحكم فيه المسجد من لوحة التحكم. القيم المدعومة (حسب adhan_dart): انظر الجدول أدناه |
| `updated_at` | string (ISO 8601) | يُفضّل | آخر تحديث لبيانات المسجد |
| `last_seen` | string (ISO 8601) | لا | آخر نشاط/اتصال (أي جهاز سحب أو حدّث بيانات المسجد) |

#### قيم `calculation_method` المدعومة (مكتبة adhan_dart)

| القيمة في Firebase | الطريقة في المكتبة |
|--------------------|---------------------|
| `muslim_world_league` | CalculationMethod.muslim_world_league |
| `egyptian` | CalculationMethod.egyptian |
| `umm_al_qura` | CalculationMethod.umm_al_qura |
| `karachi` | CalculationMethod.karachi |
| `kuwait` | CalculationMethod.kuwait |
| `qatar` | CalculationMethod.qatar |
| `tehran` | CalculationMethod.tehran |
| (أي قيمة أخرى) | افتراضي: muslim_world_league |

التطبيق يقرأ `calculation_method` من المستند ويحوّلها إلى `CalculationParameters` المناسب ثم يستدعي `PrayerTimes.today(coordinates, params)`.

---

### 2.2 إعدادات الإقامة — `iqama_offsets`

وقت الإقامة = وقت الأذان + عدد الدقائق (offset). لا نخزن أوقات إقامة ثابتة.

| الحقل | النوع | الوصف |
|-------|------|--------|
| `iqama_offsets.fajr` | number | دقائق بعد أذان الفجر |
| `iqama_offsets.dhuhr` | number | دقائق بعد أذان الظهر |
| `iqama_offsets.asr` | number | دقائق بعد أذان العصر |
| `iqama_offsets.maghrib` | number | دقائق بعد أذان المغرب |
| `iqama_offsets.isha` | number | دقائق بعد أذان العشاء |

---

### 2.3 إعدادات التصميم — `design_settings`

| الحقل | النوع | الوصف |
|-------|------|--------|
| `background_type` | string | `"image"` \| `"color"` \| `"gradient"` |
| `background_value` | string | رابط صورة، أو لون (مثل `#1E3A8A`)، أو قيمة التدرج |
| `primary_color` | string | اللون الرئيسي (مثل `#1E3A8A`) |
| `secondary_color` | string | اللون الثانوي |
| `font_family` | string | اسم الخط (مثل `Amiri`) |
| `font_size` | number | حجم الخط |
| `updated_at` | string (ISO 8601) | آخر تحديث للإعدادات |
| `decorative_elements` | array (اختياري) | عناصر زخرفية، مثلاً: `{ "type": "pattern", "image_url": "...", "speed": 1.0 }` |

---

### 2.4 الأحاديث — `hadiths` (مصفوفة)

كل عنصر في المصفوفة:

| الحقل | النوع | الوصف |
|-------|------|--------|
| `narrator` | string | الراوي |
| `text` | string | نص الحديث |
| `source` | string | المصدر (مثل: صحيح البخاري) |
| `display_order` | number (اختياري) | ترتيب العرض (1، 2، 3...) |
| `duration_seconds` | number (اختياري) | مدة عرض الحديث بالثواني |
| `updated_at` | string (ISO 8601) | آخر تحديث |

---

### 2.5 إعلانات المسجد — `mosque_ads` (مصفوفة)

كل إعلان يعرض على الشاشة ويمكن أن يحتوي **رمز QR**؛ محتوى الـ QR مخزَن داخل الإعلان في الحقل `qr_content`. التطبيق يولد رمز الـ QR من هذا المحتوى (مكتبة مثل `qr_flutter`).

| الحقل | النوع | الوصف |
|-------|------|--------|
| `title` | string | عنوان الإعلان |
| `start_date` | string (YYYY-MM-DD) | تاريخ بداية العرض |
| `end_date` | string (YYYY-MM-DD) | تاريخ نهاية العرض |
| `qr_content` | string | **محتوى رمز QR** — رابط أو نص يُعرض داخل الإعلان كـ QR؛ التطبيق يولد الـ QR من هذا الحقل |
| `image_url` | string (اختياري) | صورة مصاحبة للإعلان |
| `updated_at` | string (ISO 8601) | آخر تحديث |

**عرض الإعلان:** يظهر الإعلان عندما يكون التاريخ الحالي بين `start_date` و`end_date`. يُعرض العنوان + QR Code (المولَّد من `qr_content`).

---

## 3. حساب أوقات الصلاة (مكتبة adhan_dart)

أوقات الصلاة **لا تُخزَّن** في Firestore بشكل يومي. التطبيق يحسبها محلياً عند الحاجة.

### 3.1 المصدر

- **الإحداثيات:** من مستند المسجد (`latitude`, `longitude`).
- **طريقة الحساب:** من مستند المسجد (`calculation_method`) — **ديناميكي** يتحكم فيه المسجد من لوحة التحكم.
- **التاريخ:** اليوم المحلي (أو الغد عند الحاجة).

### 3.2 آلية الحساب في التطبيق

1. جلب مستند المسجد من Firebase (أو من الكاش).
2. إنشاء `Coordinates(mosque.latitude, mosque.longitude)`.
3. تحويل `mosque.calculation_method` (string) إلى `CalculationParameters`:
   - مقارنة القيمة مع القائمة المدعومة (muslim_world_league, umm_al_qura, egyptian, karachi, kuwait, qatar, tehran) واستدعاء `CalculationMethod.xxx.getParameters()`.
   - في حالة غير معروفة: استخدام افتراضي (مثل muslim_world_league).
4. استدعاء `PrayerTimes.today(coordinates, params)` (أو `PrayerTimes.tomorrow(...)` عند الحاجة).
5. قراءة الأوقات: `fajr`, `sunrise`, `dhuhr`, `asr`, `maghrib`, `isha`.

### 3.3 العد التنازلي والصلاة القادمة

- **الصلاة القادمة:** `prayerTimes.nextPrayer()`.
- **الوقت المتبقي حتى الصلاة القادمة:** `prayerTimes.timeUntilNextPrayer()`.
- **وقت الإقامة:** وقت الأذان + `iqama_offsets[صلاة]` (بالدقائق).
- يُحدَّث العد التنازلي دورياً (مثلاً كل دقيقة) في واجهة العرض.

### 3.4 المنطقة الزمنية

المكتبة تعتمد على الوقت المحلي للجهاز. للتحديد الدقيق يمكن استخدام `params.timeZone` (مثل `Asia/Damascus`) إن دعمته النسخة المستخدمة من adhan_dart.

---

## 4. الحسابات وربط المسجد (تسجيل الدخول)

- **Firebase Authentication:** تسجيل الدخول على الجوال والشاشة؛ لا تُخزَن كلمات المرور في Firestore.
- **ربط المستخدم بالمسجد:** إما:
  - مجموعة فرعية `users/{uid}/mosques` تحتوي مراجع للمساجد المسموح للمستخدم بها، أو
  - حقل في مستند المسجد: `owner_uid` أو `allowed_uids` (قائمة).
- عند فتح التطبيق: تحديد مسجد المستخدم ثم قراءة/كتابة `mosques/{mosque_id}` فقط.

---

## 5. مجموعة `logs` (اختياري)

لتسجيل النشاط أو المراقبة:

| الحقل | النوع | الوصف |
|-------|------|--------|
| `mosque_id` | string | معرف المسجد |
| `action` | string | مثلاً: `fetch_ads`, `settings_updated` |
| `timestamp` | string (ISO 8601) | وقت الحدث |

يمكن استخدام `last_seen` في مستند المسجد بدلاً من أو بالإضافة إلى logs.

---

## 6. ملخص التكامل مع التطبيق

| العنصر | المصدر | الاستخدام |
|--------|--------|-----------|
| إحداثيات المسجد | `mosques/{id}.latitude/longitude` | إدخال لمكتبة adhan_dart |
| طريقة الحساب | `mosques/{id}.calculation_method` | تحويلها إلى CalculationParameters واستخدامها مع adhan_dart |
| أوقات الصلاة | **محسوبة في التطبيق** | adhan_dart — لا تخزين يومي في Firebase |
| الإقامة | `iqama_offsets` + أوقات الأذان المحسوبة | وقت الإقامة = أذان + offset |
| الإعلانات + QR | `mosque_ads[].qr_content` | عرض الإعلان وتوليد QR من `qr_content` (مثل qr_flutter) |
| الأحاديث | `hadiths[]` | عرض بالتناوب مع مراعاة `display_order` و`duration_seconds` |
| التصميم | `design_settings` | تطبيق الألوان والخط والخلفية على واجهة العرض |

---

## 7. نموذج JSON كامل لمستند مسجد واحد

انظر الملف: `schema-mosque-example.json` (يمكن توسيعه بحقول `display_order`, `duration_seconds`, `image_url` في الأحاديث والإعلانات، و`decorative_elements` في التصميم حسب الحاجة).
