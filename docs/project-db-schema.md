# هيكل قاعدة البيانات في مشروع Mosques

## نظرة عامة
هذا المشروع يعتمد على Firebase Firestore كمصطلح البيانات الأساسي. يتم تخزين بيانات المسجد وتنظيمها في المستند `mosques/{mosqueId}`، بينما تستخدم الإعدادات العامة الوثيقة `app_settings/global`.

هناك أيضاً مفاتيح ثابتة تم تعريفها في `lib/core/constants/firestore_schema.dart` للحقول والمجموعات، مما يقلل الاعتماد على سلاسل نصية صريحة.

---

## المجموعات الرئيسية

### 1. `mosques`

كل مسجد يتم تمثيله بمستند منفصل داخل هذه المجموعة. المستند يحتوي على جميع بيانات العرض والإعدادات مثل:
- الاسم والموقع
- طريقة حساب الصلاة
- إعدادات التصميم
- قوائم المحتوى الديني
- الإعلانات والتنبيهات
- ألبوم الصور

### 2. `app_settings`

مجموعة ذات مستند واحد معروف: `app_settings/global`.
هذا المستند يخزن إعدادات التطبيق العامة التي ليست مرتبطة بمسجد معين، مثل:
- أرقام دعم الخدمة
- رابط مكتبة الخلفيات
- معلومات قسم "حول"
- معلومات تحديث التطبيق

### 3. `users`

المجموعة موجودة في الثوابت ويمكن استخدامها لتخزين بيانات المستخدم المرتبطة بـ Firebase Authentication. الحقول المحتملة في `users/{uid}` تشمل:
- `email`
- `phone`
- `active_mosque_id`
- `fcm_token` و`fcm_tokens`
- `fcm_token_updated_at`

هذه الحقول موجودة في `FirestoreSchema` لكن تنفيذ القراءة/الكتابة الفعلي يعتمد على مستودع المصادقة.

### 4. `platform_announcements`

مجموعة إعلانات النظام العامة التي تُستخدم لعرض شرائح أو رسائل إعدادات داخل التطبيق. هذا يقرأ عبر مستودع `IPlatformAnnouncementsRepository`.

---

## مستند المسجد: `mosques/{mosqueId}`

### الحقول الأساسية

| الحقل | النوع | الوصف |
|---|---|---|
| `name` | string | اسم المسجد المعروض. |
| `city` | string | المدينة/الموقع. |
| `latitude` | number | خط العرض لحساب أوقات الصلاة. |
| `longitude` | number | خط الطول لحساب أوقات الصلاة. |
| `calculation_method` | string | طريقة حساب أوقات الصلاة (مثال: `MuslimWorldLeague`, `Egyptian`). |
| `language_code` | string? | لغة الواجهة للمسجد، إذا تم تعيينها. |
| `app_language_code` | string? | اسم حقل قديم يُستخدم كنسخة احتياطية. |
| `last_seen` | Timestamp / string / int | آخر توقيت تواصل. |
| `updated_at` | Timestamp / string / int | آخر تحديث للمستند. |

### إعدادات الإزاحات: `prayer_offsets`

وحدة تخزين القيم المستخدمة لضبط الأوقات المشتقة من مكتبة `adhan_dart`.

| المفتاح | النوع | الافتراضي | الوصف |
|---|---|---|---|
| `fajr` | int | `0` | تحويل وقت الفجر. |
| `sunrise` | int | `0` | تحويل وقت الشروق. |
| `dhuhr` | int | `0` | تحويل وقت الظهر. |
| `asr` | int | `0` | تحويل وقت العصر. |
| `maghrib` | int | `0` | تحويل وقت المغرب. |
| `isha` | int | `0` | تحويل وقت العشاء. |

### إعدادات الإقامة: `iqama_offsets`

تُستخدم لحساب وقت الإقامة لكل صلاة بناءً على وقت الأذان.

| المفتاح | النوع | الافتراضي | الوصف |
|---|---|---|---|
| `fajr` | int | `20` | دقائق بعد أذان الفجر. |
| `dhuhr` | int | `15` | دقائق بعد أذان الظهر. |
| `asr` | int | `15` | دقائق بعد أذان العصر. |
| `maghrib` | int | `10` | دقائق بعد أذان المغرب. |
| `isha` | int | `15` | دقائق بعد أذان العشاء. |
| `jummah` | int | `30` | دقائق بعد أذان الجمعة (إذا تم استخدامه). |

### إعدادات التصميم: `design_settings`

تُخزن ضمن كائن واحد، وتُفكك عبر `DesignSettingsModel.fromMap()`.

| الحقل | النوع | الافتراضي | الوصف |
|---|---|---|---|
| `background_type` | string | `image` | نوع الخلفية: `image`, `color`, `album`. |
| `background_value` | string | `default` | قيمة الخلفية أو معرف الخلفية. |
| `ticker_speed` | double | `1.0` | سرعة شريط الأخبار السفلي. |
| `strip_speed` | double | `1.0` | سرعة شريط العنوان/الشريط المتحرك. |
| `numeral_format` | string | `en` | صيغة الأرقام: `en` أو `ar`. |
| `font_family` | string | `Beiruti` | اسم خط العرض. |
| `pre_adhan_minutes` | int | `5` | بداية العد التنازلي قبل الأذان. |
| `adhan_moment_duration_seconds` | int | `60` | مدة عرض شاشة لحظة الأذان. |
| `religious_content_wait_seconds` | int | `120` | وقت الانتظار قبل عرض المحتوى الديني. |
| `religious_content_display_seconds` | int | `30` | مدة عرض كل عنصر ديني. |
| `prayer_card_scale` | double | `1.0` | مقياس حجم بطاقات الصلاة على الشاشة. |

### إعدادات الألوان والشكل

جزء من `DesignSettingsModel` يتكون أيضاً من:
- `DesignBackgroundSettings`
- `FontSizeSettings`
- `DesignColorSettings`

تحتوي هذه الأقسام على حقول تفاصيل أكثر مثل:
- ألوان النصوص النشطة وغير النشطة
- لون خلفية العد التنازلي
- لون الخلفية والتنبيه
- أحجام خطوط الساعة، المسجد، الصلوات، الإعلانات، المحتوى الديني، التنبيه، العد التنازلي.

### المحتوى الديني: `hadiths`, `verses`, `duas`, `adhkar`

كل مجموعة عبارة عن مصفوفة كائنات نصية من نوع `MosqueTextEntryModel`.
كل عنصر يحتوي على:
- `id` (سلسلة)
- `text` (نص المحتوى)
- `source` (مرجع / مصدر)
- `narrator` (الراوي أو العنوان)
- `is_active` (boolean)
- `order` (int)

يتم إنشاء `id` تلقائياً إذا لم يتم تقديم واحد.

### الإعلانات والتنبيهات

#### `mosque_ads`
- مجموعة إعلانات المسجد العادية.
- يتم تحريرها في قسم الإعلانات.

#### `active_alerts`
- تنبيهات عالية الأولوية تُنشر على الفور.
- تستخدم خصائص النشر والمدة.

كل عنصر إعلان يقرأ من `AnnouncementModel.fromMap()` ويحتوي على:
- `id`
- `title`
- `subtitle`
- `start_date`
- `end_date`
- `qr_code_url`
- `is_active`
- `order`
- `is_priority`
- `display_duration_seconds`
- `is_published`
- `published_at`
- `publish_duration_seconds`

### ألبوم الصور والنشر

حقول ألبوم الصور الرئيسية:
- `album_image_urls` (قائمة روابط URL)
- `published_album_url` (الرابط المنشور حالياً)
- `published_album_at` (زمن النشر)
- `published_album_duration` (مدة العرض بالثواني)
- `published_album_fit` (طريقة الملء مثل `contain`, `cover`, `fill`, `fitWidth`, `fitHeight`)

المشروع يدعم أيضاً ترحيل الحقول القديمة:
- `photo_studio_urls`
- `background_album_urls`

لكن الحقل الجديد `album_image_urls` هو الحقل الموثوق عند وجوده.

---

## مستند الإعدادات العامة: `app_settings/global`

هذا المستند يُدار عبر `AppSettingsRepository` ويمثل إعدادات التطبيق التي تنطبق على الواجهة العامّة وفي قسم "حول".

| الحقل | النوع | الوصف |
|---|---|---|
| `support_phone` | string | رقم الهاتف لدعم المسجد/التطبيق. |
| `background_folder_url` | string? | رابط مجلد خلفيات مركزي. |
| `background_library_urls` | array<string> | قائمة روابط الخلفيات المتاحة في لوحة التصميم. |
| `about_categories` | array<object> | تصنيفات محتوى About المعرّفة في التطبيق. |
| `update` | object | معلومات تحديث التطبيق. |

### حقول تحديث التطبيق: `update`

| الحقل | النوع | الوصف |
|---|---|---|
| `latest_version` | string | أحدث نسخة متوفرة. |
| `android_link` | string | رابط التنزيل على أندرويد. |
| `windows_link` | string | رابط التنزيل على ويندوز. |
| `ios_link` | string | رابط التنزيل على iOS. |
| `macos_link` | string | رابط التنزيل على macOS. |
| `linux_link` | string | رابط التنزيل على لينكس. |
| `release_notes` | string | ملاحظات الإصدار. |

### بنية About

كل تصنيف في `about_categories` يحتوي على:
- `title` (عنوان الفئة)
- `sections` (قائمة أقسام)

وكل قسم داخل `sections` يحتوي على:
- `type` (نوع العنصر، كـ `text` أو غيره)
- `content` (المحتوى النصي)
- `font_size` (حجم الخط)
- `font_weight` (وزن الخط)

---

## ملاحظات هامة

- الحقول الموجودة في `lib/core/constants/firestore_schema.dart` تمثل القيم المركزية التي يستخدمها التطبيق.
- `MosqueModel.fromMap()` و`toMap()` هي الطريقة الأساسية لقراءة وكتابة جميع حقول مسجد Firestore.
- حقول التنبيه، الإعلان، النصوص الدينية، والألبوم كلها تُخزن داخل مستند المسجد نفسه، بينما المعلومات العامة للتطبيق تخزن في `app_settings/global`.
