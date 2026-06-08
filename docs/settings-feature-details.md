# توثيق فيتشرات إعدادات تطبيق Mosques

## نظرة عامة
قسم الإعدادات في التطبيق هو المكان المركزي لإدارة المسجد، شاشة العرض، وسلوك التطبيق. الواجهة تستخدم `ZoomDrawer` للتنقل بين أقسام متعددة، وكل قسم يعتمد على BLoC وواجهات المستودعات لقراءة/حفظ البيانات.

الصفحة الأساسية هي `SettingsScreen` في `lib/features/settings/presentation/settings_screen.dart`.

### ما يتم تحميله أولاً
- `IMosqueRepository.streamActiveMosque` لجلب بيانات المسجد النشطة.
- `IAppSettingsRepository.streamAppSettings` لجلب الإعدادات العامة التي لا تتعلق بمسجد واحد.

---

## أقسام إعدادات التطبيق

### 1. General (عام)

الموقع: `lib/features/settings/general/presentation/general_section.dart`

#### الميزات
- تحرير اسم المسجد (`name`).
- تحرير المدينة (`city`).
- اختيار لغة التطبيق (`AppLanguage`).
- تعديل الإحداثيات (`latitude`, `longitude`) باستخدام زر "استخدام الموقع الحالي".
- عرض شريط إعلانات إعدادات منفصل من `platform_announcements`.
- حفظ التغييرات في بيانات المسجد.

#### كيف يعمل
- يستخدم `GeneralBloc` الذي يتفاعل مع `IMosqueRepository`.
- عند تغيير الاسم أو المدينة أو الإحداثيات، يرسل حدث `GeneralSettingChanged`.
- الحفظ يُرسل حدث `SaveGeneralRequested()`.

### 2. Prayer & Iqama (الصلاة والإقامة)

الموقع: `lib/features/settings/iqama/presentation/prayer_iqama_section.dart`

#### الميزات
- تغير طريقة حساب أوقات الصلاة (`calculation_method`).
- ضبط إزاحات الصلاة (`prayer_offsets`) لكل صلاة يدويًا.
- ضبط إزاحات الإقامة (`iqama_offsets`) لكل صلاة.
- تعديل وقت العد التنازلي قبل الأذان (`pre_adhan_minutes`).
- تعديل مدة شاشة لحظة الأذان (`adhan_moment_duration_seconds`).
- حفظ التعديلات عبر زر واحد يشمل التغييرات العامة، إعدادات الإقامة، وإعدادات العرض.

#### كيف يعمل
- يستخدم `GeneralBloc` لقراءة وتعديل طريقة الحساب وإزاحات الصلاة.
- يستخدم `IqamaBloc` لإدارة تغييرات الإقامة.
- يستخدم `DesignBloc` لحفظ قيم التوقيت العرضية مثل `preAdhanMinutes` و`adhanMomentDurationSeconds`.

### 3. Religious Content (المحتوى الديني)

الموقع: `lib/features/settings/religious_content/presentation/religious_content_section.dart`

#### الميزات
- عرض وإدارة أربع قوائم محتوى ديني:
  - `hadiths` (أحاديث)
  - `verses` (آيات)
  - `duas` (أدعية)
  - `adhkar` (أذكار)
- إضافة عناصر جديدة عبر `MosqueTextEditorSheet`.
- عرض محتوى نشط/غير نشط مع ترتيب العرض.
- تعديل زمن الانتظار قبل عرض المحتوى الديني.
- تعديل مدة عرض كل عنصر من المحتوى الديني.
- حفظ الكل دفعة واحدة.

#### كيف يعمل
- `ReligiousContentBloc` يدير قراءة مسجد واحد، إضافة أو تحديث قوائم النصوص، وحفظها إلى `IMosqueRepository`.
- الحفظ عبر `SaveAllReligiousContentRequested()`.

### 4. Design (التصميم)

الموقع: `lib/features/settings/design/presentation/design_section.dart`

#### الميزات
- اختيار نوع الخلفية:
  - صورة
  - لون
  - ألبوم صور
- تعديل قيمة الخلفية (`background_value`).
- إدارة روابط صور المكتبة العامة من `app_settings/global.background_library_urls`.
- إضافة روابط ألبوم جديدة.
- حذف روابط ألبوم موجودة.
- تعديل ألوان العرض الرئيسية:
  - اللون الرئيسي
  - اللون الثانوي
  - لون البطاقة النشطة
  - لون نص البطاقة النشطة
  - لون نص البطاقة غير النشطة
  - لون تراكب الصلاة
  - لون خلفية العد التنازلي
  - لون نص العد التنازلي
  - لون خلفية التنبيه والنص.
- تعديل أحجام النصوص لعدة مكونات:
  - الساعة
  - اسم المسجد والمعلومات
  - جدول الصلوات
  - الإعلانات
  - المحتوى الديني
  - التنبيهات
  - العد التنازلي
- تعديل حجم رسم بطاقة الصلاة.
- تغيير الخط المستخدم في الشاشة (`font_family`).
- تغيير صيغة الأرقام (`numeral_format`) بين `en` و`ar`.
- التحكم بسرعة الشريط السفلي (`ticker_speed`).
- التحكم بسرعة شريط الإعلانات أو الشريط المتحرك (`strip_speed`).

#### كيف يعمل
- `DesignBloc` يحمل `mosque.designSettings` ثم يتعامل مع أحداث تغيير القيم.
- يتم عرض زر حفظ مخصص `DesignSaveBar` عند وجود تغييرات غير محفوظة.
- يعتمد القسم أيضاً على `IAppSettingsRepository` لتوفير مكتبة روابط الخلفيات المدمجة.

### 5. Announcements (الإعلانات)

الموقع: `lib/features/settings/announcements/presentation/announcement_section.dart`

#### الميزات
- عرض قائمة إعلانات المسجد الحالية.
- إنشاء إعلان جديد عبر شاشة التحرير.
- تعديل إعلان موجود.
- حذف إعلان.
- تفعيل/إلغاء تفعيل الإعلان.
- حفظ التغييرات.
- يعرض حالة الإعلان: قادم، نشط، أو منتهي.

#### كيف يعمل
- `AnnouncementsBloc` يدير قائمة `mosque.announcements`.
- كل عنصر `AnnouncementModel` يحتوي على خصائص توقيت ونشر.
- الحفظ يتم عبر حدث `SaveAnnouncementsRequested()`.

### 6. Album (الألبوم)

الموقع: `lib/features/settings/album/widgets/album_section_body.dart`

#### الميزات
- عرض شبكة روابط الصور المخزنة في `mosque.albumImageUrls`.
- إضافة رابط صورة جديد.
- تحديد صورة كمنشور مباشر (live) للعرض الكامل.
- إلغاء نشر الصورة المنشورة.
- حذف رابط صورة.
- عرض حالة الصورة المنشورة الحالية ومدى صلاحيتها الزمنية.

#### كيف يعمل
- تسمح النافذة المنبثقة `AlbumPublishBottomSheet` بتعيين مدة العرض وطريقة التوافق.
- حالة الصورة المنشورة تحدد من خلال مقارنة `publishedAlbumImageAt` مع مدة العرض.
- الحفظ يتم عبر أحداث `AlbumImageAdded`, `AlbumImagePublished`, `AlbumImageRemoved`, `AlbumImageUnpublished`.

### 7. Alerts (التنبيهات)

الموقع: `lib/features/settings/alerts/widgets/alerts_section_body.dart`

#### الميزات
- إنشاء تنبيه جديد.
- تعديل تنبيه موجود.
- حذف تنبيه واحد.
- حذف جميع التنبيهات.
- نشر التنبيه لمدة محددة.
- إلغاء نشر التنبيه.
- عرض حالة التنبيه الحالية (مباشرة/منشور).

#### كيف يعمل
- التنبيهات تستخدم نموذج `AnnouncementModel` نفسه، لكن تُعامل كتنبيهات ذات أولوية عالية.
- الحفظ يتم عبر `SaveAlertsRequested()`.

### 8. Profile (الملف الشخصي)

الموقع: `lib/features/settings/profile/presentation/profile_section.dart`

#### الميزات
- عرض معلومات المستخدم الحالية من Firebase Authentication.
- تغيير كلمة المرور.
- تغيير رقم الهاتف.
- اختيار ما إذا كان سيتم إنهاء الجلسات الأخرى (`terminate other sessions`).
- عرض نتائج الحفظ أو الأخطاء.

#### كيف يعمل
- `ProfileBloc` يتعامل مع `IAuthRepository`.
- يدعم الأحداث: `LoadProfileRequested`, تحديث كلمة المرور، تحديث الهاتف.
- يعرض الأخطاء المترجمة مثل "كلمة المرور قصيرة" أو "رقم الهاتف فارغ".

### 9. About (حول)

الموقع: `lib/features/settings/about/presentation/about_section.dart`

#### الميزات
- يعرض محتوى "حول" المقروء من `app_settings/global.about_categories`.
- يحتوي على فئات وأقسام نصية من النموذج.
- هو قسم عرض فقط لا يحوّل بيانات المسجد.

#### كيف يعمل
- يستخدم `AppSettingsRepository.streamAppSettings` لقراءة البيانات.
- يتم بناء عناصر UI من `AboutCategoryModel` و`AboutSectionModel`.

### 10. Update (التحديث)

الموقع: `lib/features/settings/update/presentation/update_section.dart`

#### الميزات
- يعرض النسخة الحالية للتطبيق.
- يقارنها بأحدث نسخة في `app_settings/global.update.latest_version`.
- يعرض الرابط المناسب للتحميل حسب المنصة.
- يعرض ملاحظات الإصدار إذا كانت متوفرة.
- يعرض حالة "محدث" أو "تحديث متاح".

#### كيف يعمل
- يستخدم `VersionHelper.getCurrentVersion()` لقراءة إصدار التطبيق الحالي.
- يستخدم `AppSettingsRepository.streamAppSettings` لجلب بيانات التحديث العامة.
- يجري مقارنة بين النسخ لتحديد حالة التحديث.

---

## البنية التقنية لواجهة الإعدادات

### التنقل والعرض
- `SettingsPage` هو الغلاف الأساسي.
- `SettingsScreen` يستخدم `ZoomDrawer` مع قائمة جانبية (`SettingsZoomDrawerContent`).
- كل قسم يعرض داخل `IndexedStack` للحفاظ على الحالة عند التبديل.

### الاعتمادية بين الأقسام
- `GeneralSection` و`PrayerIqamaSection` يعتمدون على نفس بيانات المسجد.
- قسم `Design` يعتمد على بيانات مسجد إضافية بالإضافة إلى إعدادات التطبيق العامة.
- قسم `About` و`Update` يعتمدان على إعدادات التطبيق العامة فقط.

### ما هو محفوظ في مسجد واحد؟
- `name`, `city`, `latitude`, `longitude`, `calculation_method`
- `prayer_offsets`
- `iqama_offsets`
- `design_settings`
- `hadiths`, `verses`, `duas`, `adhkar`
- `mosque_ads`, `active_alerts`
- `album_image_urls`, `published_album_url`, `published_album_at`, `published_album_duration`, `published_album_fit`

### ما هو محفوظ في الإعدادات العامة؟
- `support_phone`
- `background_folder_url`
- `background_library_urls`
- `about_categories`
- `update.latest_version`
- `update.android_link`, `update.windows_link`, `update.ios_link`, `update.macos_link`, `update.linux_link`
- `update.release_notes`

---

## نقاط مهمة للتطوير

- قيم التصميم والإعلانات والتنبيهات تُعد قابلة للتعديل مباشرة من لوحة الإعدادات.
- بعض الحقول في `mosque_model` تحمل ترحيلًا لحقول قديمة، مثل `photo_studio_urls` و`background_album_urls`.
- `app_settings/global` يخدم المحتوى المشترك بين كل المساجد والشاشات، بينما `mosque` يخدم المسجد الفردي.
- حفظ الإعدادات يتم عادة عبر المكتبة `IMosqueRepository` أو `IAppSettingsRepository`، حسب القسم.
