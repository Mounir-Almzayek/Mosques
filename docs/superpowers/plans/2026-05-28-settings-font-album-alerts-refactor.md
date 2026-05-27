# Settings, Font Controls, Album, Alerts & Display Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand font size controls to 7 independent fields, unify Photo Studio and Album, redesign alerts as saved-list with publish flow, convert religious content from overlay to prayer-area replacement, redesign the settings AppBar, and clean up naming/i18n.

**Architecture:** The refactor modifies data models (FontSizeSettings, AnnouncementModel, MosqueModel), BLoC events/handlers, display layer widgets, and settings UI. All changes follow existing patterns: Equatable models with `fromMap`/`toMap`/`copyWith`, parameterized BLoC events, and the DisplayLayerController state machine.

**Tech Stack:** Flutter 3.x, flutter_bloc, Equatable, GetIt DI, Firestore, CachedNetworkImage, S.of(context) i18n.

---

## File Structure

### New Files
- `lib/features/display/presentation/widgets/content/religious_content_inline.dart` — Inline religious content (replaces prayer area)
- `lib/features/settings/presentation/widgets/common/settings_app_bar.dart` — Beautiful gradient settings AppBar
- `lib/features/settings/presentation/sections/album_section.dart` — Unified album section (replaces photo_studio_section.dart)

### Renamed Files
- `photo_studio_section.dart` → replaced by new `album_section.dart`
- `photo_studio_layer.dart` → rename class to `AlbumImageLayer`

### Modified Files
- `lib/data/models/design/font_size_settings.dart` — Add alerts, countdown; rename content→religiousContent
- `lib/data/models/mosque/mosque_model.dart` — Unify album, add publish fields, rename activeAlerts→savedAlerts
- `lib/data/models/mosque/announcement_model.dart` — Add isPublished, publishedAt, publishDurationSeconds
- `lib/features/settings/bloc/settings/settings_event.dart` — New enum values, rename events
- `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart` — New switch cases, rename methods
- `lib/features/settings/bloc/settings/handlers/announcement_handler.dart` — Publish/unpublish handlers
- `lib/features/settings/presentation/sections/design_section.dart` — Wire new font callbacks
- `lib/features/settings/presentation/widgets/design/font_size_settings_section.dart` — Add 2 sliders
- `lib/features/settings/presentation/sections/alerts_section.dart` — Redesign with publish flow
- `lib/features/settings/presentation/settings_page.dart` — New AppBar, rename album tab
- `lib/features/display/presentation/display_screen.dart` — Pass font sizes, inline content mode
- `lib/features/display/presentation/widgets/content/display_beige_area.dart` — Add content switch
- `lib/features/display/presentation/widgets/layers/alert_layer.dart` — Use font size param, new publish logic
- `lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart` — Use font size param
- `lib/features/display/presentation/widgets/layers/religious_content_layer.dart` — Use font size param
- `lib/features/display/presentation/widgets/layers/photo_studio_layer.dart` — Rename to AlbumImageLayer
- `lib/features/display/controller/display_layer_controller.dart` — Update alert detection, album rename
- `lib/features/display/presentation/widgets/background/display_background_image.dart` — Read albumImageUrls
- `lib/core/l10n/intl_en.arb` — New + renamed keys
- `lib/core/l10n/intl_ar.arb` — New + renamed keys
- Various barrel files

---

### Task 1: Add i18n strings for all new and renamed features

All subsequent tasks depend on i18n keys existing. Add them first.

**Files:**
- Modify: `lib/core/l10n/intl_en.arb`
- Modify: `lib/core/l10n/intl_ar.arb`

- [ ] **Step 1: Add new English i18n keys**

Open `lib/core/l10n/intl_en.arb` and add these keys (insert near the relevant existing groups):

Font sizes (near existing `design_content_font_size`):
```json
"design_religious_content_font_size": "Religious content font size",
"design_alerts_font_size": "Alerts font size",
"design_countdown_font_size": "Countdown font size"
```

Album (replace existing `tab_photo_studio` and `photo_studio_*` keys):
```json
"tab_album": "Album",
"album_empty": "No images added yet",
"album_add_url": "Add Image URL",
"album_publish": "Publish to Display",
"album_publish_duration": "Display duration",
"album_live_badge": "LIVE",
"album_unpublish": "Remove from Display",
"album_seconds_suffix": "seconds"
```

Alerts (add near existing alert keys):
```json
"alert_status_live": "LIVE",
"alert_status_ready": "Ready",
"alert_publish": "Publish to Display",
"alert_unpublish": "Remove from Display",
"alert_publish_duration": "Display duration",
"alert_edit": "Edit Alert",
"alert_delete": "Delete Alert",
"alert_create": "Create Alert",
"alerts_delete_all": "Delete All Alerts",
"alerts_empty_title": "No alerts yet",
"alerts_empty_subtitle": "Create an alert and publish it when needed"
```

Also rename existing key `design_content_font_size` to `design_religious_content_font_size` (keep old key too for the transitional period with the value "Religious content font size").

- [ ] **Step 2: Add matching Arabic i18n keys**

Open `lib/core/l10n/intl_ar.arb` and add matching Arabic keys:

Font sizes:
```json
"design_religious_content_font_size": "حجم خط المحتوى الديني",
"design_alerts_font_size": "حجم خط التنبيهات",
"design_countdown_font_size": "حجم خط العد التنازلي"
```

Album:
```json
"tab_album": "الألبوم",
"album_empty": "لم تتم إضافة صور بعد",
"album_add_url": "إضافة رابط صورة",
"album_publish": "نشر على الشاشة",
"album_publish_duration": "مدة العرض",
"album_live_badge": "مباشر",
"album_unpublish": "إزالة من الشاشة",
"album_seconds_suffix": "ثانية"
```

Alerts:
```json
"alert_status_live": "مباشر",
"alert_status_ready": "جاهز",
"alert_publish": "نشر على الشاشة",
"alert_unpublish": "إزالة من الشاشة",
"alert_publish_duration": "مدة العرض",
"alert_edit": "تعديل التنبيه",
"alert_delete": "حذف التنبيه",
"alert_create": "إنشاء تنبيه",
"alerts_delete_all": "حذف جميع التنبيهات",
"alerts_empty_title": "لا توجد تنبيهات بعد",
"alerts_empty_subtitle": "أنشئ تنبيهاً وانشره عند الحاجة"
```

- [ ] **Step 3: Regenerate l10n**

Run: `flutter gen-l10n` (or `flutter pub run intl_utils:generate` if using intl_utils)
Then run: `flutter analyze`
Expected: No errors related to i18n.

- [ ] **Step 4: Commit**

```
git add lib/core/l10n/
git commit -m "feat(i18n): add strings for album, alerts publish, font sizes"
```

---

### Task 2: Expand FontSizeSettings model with alerts + countdown fields

**Files:**
- Modify: `lib/data/models/design/font_size_settings.dart`

- [ ] **Step 1: Add new fields and rename content→religiousContent**

Replace the entire `FontSizeSettings` class in `lib/data/models/design/font_size_settings.dart` with:

```dart
import 'package:equatable/equatable.dart';

/// Grouped font size settings for all UI components on the display.
class FontSizeSettings extends Equatable {
  final double clock;
  final double mosqueInfo;
  final double prayers;
  final double announcements;
  final double religiousContent;
  final double alerts;
  final double countdown;

  const FontSizeSettings({
    this.clock = 20.0,
    this.mosqueInfo = 20.0,
    this.prayers = 20.0,
    this.announcements = 20.0,
    this.religiousContent = 20.0,
    this.alerts = 20.0,
    this.countdown = 20.0,
  });

  factory FontSizeSettings.fromMap(Map<String, dynamic> map) {
    final base = (map['base_font_size'] ?? 20.0).toDouble();
    return FontSizeSettings(
      clock: (map['clock_font_size'] ?? base).toDouble(),
      mosqueInfo: (map['mosque_info_font_size'] ?? base).toDouble(),
      prayers: (map['prayers_font_size'] ?? base).toDouble(),
      announcements: (map['announcements_font_size'] ?? base).toDouble(),
      religiousContent: (map['religious_content_font_size'] ?? map['content_font_size'] ?? base).toDouble(),
      alerts: (map['alerts_font_size'] ?? base).toDouble(),
      countdown: (map['countdown_font_size'] ?? base).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clock_font_size': clock,
      'mosque_info_font_size': mosqueInfo,
      'prayers_font_size': prayers,
      'announcements_font_size': announcements,
      'religious_content_font_size': religiousContent,
      'alerts_font_size': alerts,
      'countdown_font_size': countdown,
    };
  }

  FontSizeSettings copyWith({
    double? clock,
    double? mosqueInfo,
    double? prayers,
    double? announcements,
    double? religiousContent,
    double? alerts,
    double? countdown,
  }) {
    return FontSizeSettings(
      clock: clock ?? this.clock,
      mosqueInfo: mosqueInfo ?? this.mosqueInfo,
      prayers: prayers ?? this.prayers,
      announcements: announcements ?? this.announcements,
      religiousContent: religiousContent ?? this.religiousContent,
      alerts: alerts ?? this.alerts,
      countdown: countdown ?? this.countdown,
    );
  }

  @override
  List<Object?> get props => [clock, mosqueInfo, prayers, announcements, religiousContent, alerts, countdown];
}
```

Key changes:
- `content` field renamed to `religiousContent`
- Added `alerts` and `countdown` fields (both default 20.0)
- `fromMap` reads `religious_content_font_size` with fallback to legacy `content_font_size`
- `toMap` writes `religious_content_font_size` (no longer writes `content_font_size`)

- [ ] **Step 2: Fix all references to old `content` field**

Search all files for `.fontSizes.content` and `.content` references to `FontSizeSettings`. Update each to `.fontSizes.religiousContent`. Key locations:
- `lib/features/settings/presentation/sections/design_section.dart` — `design.fontSizes.content` → `design.fontSizes.religiousContent`
- `lib/features/settings/presentation/widgets/design/font_size_settings_section.dart` — `fontSizes.content` → `fontSizes.religiousContent`

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: 0 errors. Any remaining references to `.content` on FontSizeSettings will show as compile errors — fix them.

- [ ] **Step 4: Commit**

```
git add lib/data/models/design/font_size_settings.dart
git commit -m "feat(model): expand FontSizeSettings with alerts, countdown, rename content→religiousContent"
```

---

### Task 3: Add publish fields to AnnouncementModel

**Files:**
- Modify: `lib/data/models/mosque/announcement_model.dart`

- [ ] **Step 1: Add isPublished, publishedAt, publishDurationSeconds fields**

In `AnnouncementModel`, add three new fields after `displayDurationSeconds`:

```dart
/// Whether this alert is currently published to the display.
final bool isPublished;

/// When this alert was last published.
final DateTime? publishedAt;

/// Duration in seconds for how long to show when published.
final int publishDurationSeconds;
```

Add to constructor:
```dart
this.isPublished = false,
this.publishedAt,
this.publishDurationSeconds = 30,
```

In `fromMap`, add:
```dart
final isPublished = map['is_published'] ?? false;
final publishedAt = parseFirestoreOrMillis(map['published_at']);
final publishDurationSeconds = map['publish_duration_seconds'] ?? 30;
```

In `toMap`, add:
```dart
'is_published': isPublished,
'published_at': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
'publish_duration_seconds': publishDurationSeconds,
```

In `copyWith`, add params:
```dart
bool? isPublished,
DateTime? publishedAt,
int? publishDurationSeconds,
```
And in the return:
```dart
isPublished: isPublished ?? this.isPublished,
publishedAt: publishedAt ?? this.publishedAt,
publishDurationSeconds: publishDurationSeconds ?? this.publishDurationSeconds,
```

In `props`, add: `isPublished, publishedAt, publishDurationSeconds`

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: 0 errors.

- [ ] **Step 3: Commit**

```
git add lib/data/models/mosque/announcement_model.dart
git commit -m "feat(model): add publish fields to AnnouncementModel"
```

---

### Task 4: Unify album data on MosqueModel

**Files:**
- Modify: `lib/data/models/mosque/mosque_model.dart`

- [ ] **Step 1: Replace photoStudioUrls + backgroundAlbumUrls with albumImageUrls**

In `MosqueModel`:

1. Replace these two fields:
```dart
final List<String> photoStudioUrls;
final List<String> backgroundAlbumUrls;
```
with:
```dart
/// Unified album image URLs — used for both background cycling and fullscreen display.
final List<String> albumImageUrls;

/// Currently published fullscreen image URL.
final String? publishedAlbumImageUrl;
/// When the album image was published.
final DateTime? publishedAlbumImageAt;
/// How long to show the published image (seconds).
final int publishedAlbumImageDuration;
```

Also rename `activeAlerts` → `savedAlerts`:
```dart
/// Saved high-priority alerts (published on demand).
final List<AnnouncementModel> savedAlerts;
```

2. Update constructor — replace:
```dart
this.activeAlerts = const [],
this.photoStudioUrls = const [],
this.backgroundAlbumUrls = const [],
```
with:
```dart
this.savedAlerts = const [],
this.albumImageUrls = const [],
this.publishedAlbumImageUrl,
this.publishedAlbumImageAt,
this.publishedAlbumImageDuration = 30,
```

3. Update `fromMap` — replace the three parsing lines:
```dart
activeAlerts: (map['active_alerts'] as List<dynamic>?)
        ?.map((e) => AnnouncementModel.fromMap(
            e as Map<String, dynamic>, e['id'] ?? ''))
        .toList() ??
    [],
photoStudioUrls: (map['photo_studio_urls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
    [],
backgroundAlbumUrls: (map['background_album_urls'] as List<dynamic>?)
    ?.map((e) => e.toString())
    .toList() ??
    [],
```
with:
```dart
savedAlerts: (map['active_alerts'] as List<dynamic>?)
        ?.map((e) => AnnouncementModel.fromMap(
            e as Map<String, dynamic>, e['id'] ?? ''))
        .toList() ??
    [],
albumImageUrls: _mergeAlbumUrls(map),
publishedAlbumImageUrl: map['published_album_url']?.toString(),
publishedAlbumImageAt: parseFirestoreOrMillis(map['published_album_at']),
publishedAlbumImageDuration: (map['published_album_duration'] ?? 30) as int,
```

Add the static merge helper:
```dart
static List<String> _mergeAlbumUrls(Map<String, dynamic> map) {
  final album = (map['album_image_urls'] as List<dynamic>?)
      ?.map((e) => e.toString())
      .toList();
  if (album != null && album.isNotEmpty) return album;
  // Migration: merge old photo_studio_urls + background_album_urls
  final photo = (map['photo_studio_urls'] as List<dynamic>?)
      ?.map((e) => e.toString())
      .toList() ?? [];
  final bg = (map['background_album_urls'] as List<dynamic>?)
      ?.map((e) => e.toString())
      .toList() ?? [];
  return {...photo, ...bg}.toList();
}
```

4. Update `toMap` — replace:
```dart
'active_alerts': activeAlerts.map((a) => a.toMap()).toList(),
'photo_studio_urls': photoStudioUrls,
'background_album_urls': backgroundAlbumUrls,
```
with:
```dart
'active_alerts': savedAlerts.map((a) => a.toMap()).toList(),
'album_image_urls': albumImageUrls,
'published_album_url': publishedAlbumImageUrl,
'published_album_at': publishedAlbumImageAt != null ? Timestamp.fromDate(publishedAlbumImageAt!) : null,
'published_album_duration': publishedAlbumImageDuration,
```

5. Update `copyWith` — replace the old params with:
```dart
List<AnnouncementModel>? savedAlerts,
List<String>? albumImageUrls,
String? publishedAlbumImageUrl,
DateTime? publishedAlbumImageAt,
int? publishedAlbumImageDuration,
```
And in the return body:
```dart
savedAlerts: savedAlerts ?? this.savedAlerts,
albumImageUrls: albumImageUrls ?? this.albumImageUrls,
publishedAlbumImageUrl: publishedAlbumImageUrl ?? this.publishedAlbumImageUrl,
publishedAlbumImageAt: publishedAlbumImageAt ?? this.publishedAlbumImageAt,
publishedAlbumImageDuration: publishedAlbumImageDuration ?? this.publishedAlbumImageDuration,
```

6. Update `props` — replace `activeAlerts, photoStudioUrls, backgroundAlbumUrls` with `savedAlerts, albumImageUrls, publishedAlbumImageUrl, publishedAlbumImageAt, publishedAlbumImageDuration`.

- [ ] **Step 2: Fix all compilation errors from rename**

Search and fix references across the codebase:
- `mosque.activeAlerts` → `mosque.savedAlerts` (in settings events, handlers, sections, display_screen, display_layer_controller)
- `mosque.photoStudioUrls` → `mosque.albumImageUrls` (in settings handlers, photo_studio_section, display)
- `mosque.backgroundAlbumUrls` → `mosque.albumImageUrls` (in display_background_image, background_settings_section, design_settings_handler)

Run `flutter analyze` repeatedly until 0 errors.

- [ ] **Step 3: Commit**

```
git add -A
git commit -m "feat(model): unify album data, add publish fields, rename activeAlerts→savedAlerts"
```

---

### Task 5: Update settings events and BLoC handlers

**Files:**
- Modify: `lib/features/settings/bloc/settings/settings_event.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/announcement_handler.dart`
- Modify: `lib/features/settings/bloc/settings/settings_bloc.dart` (wire new events)

- [ ] **Step 1: Update DesignFontSizeField enum**

In `settings_event.dart`, change:
```dart
enum DesignFontSizeField { clock, mosqueInfo, prayers, announcements, content }
```
to:
```dart
enum DesignFontSizeField { clock, mosqueInfo, prayers, announcements, religiousContent, alerts, countdown }
```

- [ ] **Step 2: Rename Photo Studio events to Album events**

In `settings_event.dart`, replace the Photo Studio section:
```dart
// ——— Album ———

class AlbumImageAdded extends SettingsEvent {
  final String url;
  const AlbumImageAdded(this.url);
  @override
  List<Object?> get props => [url];
}

class AlbumImageRemoved extends SettingsEvent {
  final String url;
  const AlbumImageRemoved(this.url);
  @override
  List<Object?> get props => [url];
}

class AlbumImagePublished extends SettingsEvent {
  final String url;
  final int durationSeconds;
  const AlbumImagePublished(this.url, this.durationSeconds);
  @override
  List<Object?> get props => [url, durationSeconds];
}

class AlbumImageUnpublished extends SettingsEvent {
  const AlbumImageUnpublished();
}

class SaveAlbumRequested extends SettingsEvent {
  const SaveAlbumRequested();
}
```

- [ ] **Step 3: Add alert publish/unpublish events**

In the Instant Alerts section of `settings_event.dart`, add after `AlertRemoved`:
```dart
class AlertPublished extends SettingsEvent {
  final String alertId;
  final int durationSeconds;
  const AlertPublished(this.alertId, this.durationSeconds);
  @override
  List<Object?> get props => [alertId, durationSeconds];
}

class AlertUnpublished extends SettingsEvent {
  final String alertId;
  const AlertUnpublished(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class AlertUpdated extends SettingsEvent {
  final AnnouncementModel alert;
  const AlertUpdated(this.alert);
  @override
  List<Object?> get props => [alert];
}
```

Rename `AlertsCleared` → `AllAlertsDeleted`:
```dart
class AllAlertsDeleted extends SettingsEvent {
  const AllAlertsDeleted();
}
```

- [ ] **Step 4: Update design_settings_handler.dart**

In `onDesignFontSizeChanged`, update the switch to handle all 7 fields:
```dart
final fontSizes = switch (event.field) {
  DesignFontSizeField.clock =>
    m.designSettings.fontSizes.copyWith(clock: event.fontSize),
  DesignFontSizeField.mosqueInfo =>
    m.designSettings.fontSizes.copyWith(mosqueInfo: event.fontSize),
  DesignFontSizeField.prayers =>
    m.designSettings.fontSizes.copyWith(prayers: event.fontSize),
  DesignFontSizeField.announcements =>
    m.designSettings.fontSizes.copyWith(announcements: event.fontSize),
  DesignFontSizeField.religiousContent =>
    m.designSettings.fontSizes.copyWith(religiousContent: event.fontSize),
  DesignFontSizeField.alerts =>
    m.designSettings.fontSizes.copyWith(alerts: event.fontSize),
  DesignFontSizeField.countdown =>
    m.designSettings.fontSizes.copyWith(countdown: event.fontSize),
};
```

Rename `onPhotoStudioUrlAdded` → `onAlbumImageAdded`, update body to use `albumImageUrls`:
```dart
void onAlbumImageAdded(AlbumImageAdded event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final urls = [...m.albumImageUrls, event.url];
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(albumImageUrls: urls)));
}
```

Rename `onPhotoStudioUrlRemoved` → `onAlbumImageRemoved`:
```dart
void onAlbumImageRemoved(AlbumImageRemoved event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final urls = m.albumImageUrls.where((u) => u != event.url).toList();
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(albumImageUrls: urls)));
}
```

Add `onAlbumImagePublished`:
```dart
void onAlbumImagePublished(AlbumImagePublished event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  emitDraftUpdated(emit, state.request.copyWith(
    mosque: m.copyWith(
      publishedAlbumImageUrl: event.url,
      publishedAlbumImageAt: DateTime.now(),
      publishedAlbumImageDuration: event.durationSeconds,
    ),
  ));
}
```

Add `onAlbumImageUnpublished`:
```dart
void onAlbumImageUnpublished(AlbumImageUnpublished event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  // Clear publish fields by setting URL to empty
  emitDraftUpdated(emit, state.request.copyWith(
    mosque: m.copyWith(publishedAlbumImageUrl: ''),
  ));
}
```

Update `onBackgroundAlbumUrlAdded`/`Removed`/`Reordered` to use `albumImageUrls` instead of `backgroundAlbumUrls`.

- [ ] **Step 5: Update announcement_handler.dart**

Rename alert methods to use `savedAlerts`:
```dart
void onAlertAdded(AlertAdded event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final list = List<AnnouncementModel>.from(m.savedAlerts)..add(event.alert);
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: list)));
}

void onAlertRemoved(AlertRemoved event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final list = m.savedAlerts.where((a) => a.id != event.alertId).toList();
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: list)));
}
```

Add `onAlertPublished`:
```dart
void onAlertPublished(AlertPublished event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final list = m.savedAlerts.map((a) {
    if (a.id == event.alertId) {
      return a.copyWith(
        isPublished: true,
        publishedAt: DateTime.now(),
        publishDurationSeconds: event.durationSeconds,
      );
    }
    return a;
  }).toList();
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: list)));
}
```

Add `onAlertUnpublished`:
```dart
void onAlertUnpublished(AlertUnpublished event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final list = m.savedAlerts.map((a) {
    if (a.id == event.alertId) {
      return a.copyWith(isPublished: false);
    }
    return a;
  }).toList();
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: list)));
}
```

Add `onAlertUpdated`:
```dart
void onAlertUpdated(AlertUpdated event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  final list = m.savedAlerts.map((a) => a.id == event.alert.id ? event.alert : a).toList();
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: list)));
}
```

Rename `onAlertsCleared` → `onAllAlertsDeleted`:
```dart
void onAllAlertsDeleted(AllAlertsDeleted event, Emitter<SettingsState> emit) {
  final m = currentMosque;
  if (m == null) return;
  emitDraftUpdated(emit, state.request.copyWith(mosque: m.copyWith(savedAlerts: [])));
}
```

- [ ] **Step 6: Wire new events in settings_bloc.dart**

In `SettingsBloc` constructor, add registrations for new events:
```dart
on<AlbumImageAdded>(onAlbumImageAdded);
on<AlbumImageRemoved>(onAlbumImageRemoved);
on<AlbumImagePublished>(onAlbumImagePublished);
on<AlbumImageUnpublished>(onAlbumImageUnpublished);
on<SaveAlbumRequested>(_onSaveAlbum);
on<AlertPublished>(onAlertPublished);
on<AlertUnpublished>(onAlertUnpublished);
on<AlertUpdated>(onAlertUpdated);
on<AllAlertsDeleted>(onAllAlertsDeleted);
```

Remove old registrations:
```dart
// Remove: on<PhotoStudioUrlAdded>, on<PhotoStudioUrlRemoved>, on<SavePhotoStudioRequested>
// Remove: on<AlertsCleared>
```

- [ ] **Step 7: Verify**

Run: `flutter analyze`
Expected: 0 errors. Fix any remaining references to old event/field names.

- [ ] **Step 8: Commit**

```
git add -A
git commit -m "feat(bloc): update events and handlers for album unification, alert publish, 7 font sizes"
```

---

### Task 6: Wire font sizes into display layers

**Files:**
- Modify: `lib/features/display/presentation/widgets/layers/alert_layer.dart`
- Modify: `lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart`
- Modify: `lib/features/display/presentation/widgets/layers/religious_content_layer.dart`

- [ ] **Step 1: AlertLayer — accept and use alertsFontSize**

Add parameter to `AlertLayer`:
```dart
final double alertsFontSize;
```

Add to constructor: `required this.alertsFontSize,`

Replace hardcoded sizes in `build()`:
- Title `fontSize: 64` → `fontSize: (alertsFontSize * 3.2).clamp(24.0, 120.0)`
- Subtitle `fontSize: 38` → `fontSize: (alertsFontSize * 1.9).clamp(14.0, 72.0)`
- Icon `size: 64` → `size: (alertsFontSize * 3.2).clamp(24.0, 120.0)`

- [ ] **Step 2: IqamaAdhanLayer — accept and use countdownFontSize**

Add parameter to `IqamaAdhanLayer`:
```dart
final double countdownFontSize;
```

Add to constructor: `required this.countdownFontSize,`

Replace hardcoded sizes in `build()`:
- Countdown `fontSize: 96` → `fontSize: (countdownFontSize * 4.8).clamp(32.0, 180.0)`
- Title `fontSize: 48` → `fontSize: (countdownFontSize * 2.4).clamp(16.0, 90.0)`
- Icon `size: 80` → `size: (countdownFontSize * 4.0).clamp(28.0, 150.0)`

- [ ] **Step 3: ReligiousContentLayer — accept and use religiousContentFontSize**

Add parameter to `ReligiousContentLayer`:
```dart
final double religiousContentFontSize;
```

Add to constructor: `required this.religiousContentFontSize,`

Replace hardcoded sizes in `build()`:
- Main text `fontSize: 42` → `fontSize: (religiousContentFontSize * 2.1).clamp(14.0, 80.0)`
- Source `fontSize: 22` → `fontSize: (religiousContentFontSize * 1.1).clamp(10.0, 42.0)`
- Badge `fontSize: 20` → `fontSize: (religiousContentFontSize * 1.0).clamp(10.0, 38.0)`

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: Errors in `display_screen.dart` where layers are instantiated without the new required params — that's expected, we'll fix in Task 10.

- [ ] **Step 5: Commit**

```
git add lib/features/display/presentation/widgets/layers/
git commit -m "feat(display): wire configurable font sizes into AlertLayer, IqamaAdhanLayer, ReligiousContentLayer"
```

---

### Task 7: Update FontSizeSettingsSection UI + DesignSection wiring

**Files:**
- Modify: `lib/features/settings/presentation/widgets/design/font_size_settings_section.dart`
- Modify: `lib/features/settings/presentation/sections/design_section.dart`

- [ ] **Step 1: Add 2 new font size sliders**

In `FontSizeSettingsSection`, add 2 new callbacks:
```dart
final ValueChanged<double> onAlertsSizeChanged;
final ValueChanged<double> onCountdownSizeChanged;
```

Add to constructor as required params.

Rename `onContentSizeChanged` → `onReligiousContentSizeChanged`.

Add 2 new `DesignFontSizeItem` widgets after the existing 5:
```dart
DesignFontSizeItem(
  label: s.design_alerts_font_size,
  value: fontSizes.alerts,
  onChanged: onAlertsSizeChanged,
  icon: Icons.notification_important_outlined,
),
DesignFontSizeItem(
  label: s.design_countdown_font_size,
  value: fontSizes.countdown,
  onChanged: onCountdownSizeChanged,
  icon: Icons.timer_outlined,
),
```

Update the existing content item:
```dart
DesignFontSizeItem(
  label: s.design_religious_content_font_size,
  value: fontSizes.religiousContent,
  onChanged: onReligiousContentSizeChanged,
  icon: Icons.auto_stories_outlined,
),
```

- [ ] **Step 2: Wire in DesignSection**

In `design_section.dart`, update `FontSizeSettingsSection` instantiation:
```dart
FontSizeSettingsSection(
  fontSizes: design.fontSizes,
  onClockSizeChanged: (val) =>
      bloc.add(DesignFontSizeChanged(DesignFontSizeField.clock, val)),
  onMosqueInfoSizeChanged: (val) => bloc.add(
    DesignFontSizeChanged(DesignFontSizeField.mosqueInfo, val),
  ),
  onPrayersSizeChanged: (val) =>
      bloc.add(DesignFontSizeChanged(DesignFontSizeField.prayers, val)),
  onAnnouncementsSizeChanged: (val) => bloc.add(
    DesignFontSizeChanged(DesignFontSizeField.announcements, val),
  ),
  onReligiousContentSizeChanged: (val) =>
      bloc.add(DesignFontSizeChanged(DesignFontSizeField.religiousContent, val)),
  onAlertsSizeChanged: (val) =>
      bloc.add(DesignFontSizeChanged(DesignFontSizeField.alerts, val)),
  onCountdownSizeChanged: (val) =>
      bloc.add(DesignFontSizeChanged(DesignFontSizeField.countdown, val)),
),
```

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: 0 errors.

- [ ] **Step 4: Commit**

```
git add lib/features/settings/presentation/
git commit -m "feat(settings): add alerts + countdown font size sliders to design section"
```

---

### Task 8: Create SettingsAppBar widget

**Files:**
- Create: `lib/features/settings/presentation/widgets/common/settings_app_bar.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart`

- [ ] **Step 1: Create SettingsAppBar**

Create `lib/features/settings/presentation/widgets/common/settings_app_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';

/// Beautiful gradient AppBar for the settings screen.
class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int sectionIndex;
  final String mosqueName;
  final VoidCallback onMenuPressed;
  final VoidCallback onRefreshPressed;
  final List<PopupMenuEntry<String>> Function(BuildContext) popupMenuBuilder;
  final void Function(String) onPopupMenuSelected;

  const SettingsAppBar({
    super.key,
    required this.sectionIndex,
    required this.mosqueName,
    required this.onMenuPressed,
    required this.onRefreshPressed,
    required this.popupMenuBuilder,
    required this.onPopupMenuSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  static const _gradient = LinearGradient(
    colors: [Color(0xFF1A3C34), Color(0xFF2E7D52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = _titleForIndex(s, sectionIndex);
    final icon = _iconForIndex(sectionIndex);

    return Container(
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // Menu button
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                  onPressed: onMenuPressed,
                ),
                const SizedBox(width: 4),
                // Section icon
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(width: 10),
                // Title area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mosqueName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          mosqueName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Refresh
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                  onPressed: onRefreshPressed,
                ),
                // Popup menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                  onSelected: onPopupMenuSelected,
                  itemBuilder: popupMenuBuilder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForIndex(S s, int i) {
    switch (i) {
      case 0: return s.tab_general;
      case 1: return s.tab_prayer_iqama;
      case 2: return s.tab_religious_content;
      case 3: return s.tab_design;
      case 4: return s.tab_album;
      case 5: return s.tab_announcements;
      case 6: return s.tab_alerts;
      case 7: return s.tab_profile;
      case 8: return s.tab_about;
      case 9: return s.tab_update;
      default: return s.settings_title;
    }
  }

  IconData _iconForIndex(int i) {
    switch (i) {
      case 0: return Icons.mosque_outlined;
      case 1: return Icons.access_time_outlined;
      case 2: return Icons.auto_stories_outlined;
      case 3: return Icons.palette_outlined;
      case 4: return Icons.photo_library_outlined;
      case 5: return Icons.campaign_outlined;
      case 6: return Icons.notification_important_outlined;
      case 7: return Icons.person_outlined;
      case 8: return Icons.info_outlined;
      case 9: return Icons.system_update_outlined;
      default: return Icons.settings_outlined;
    }
  }
}
```

- [ ] **Step 2: Integrate into SettingsPage**

In `settings_page.dart`, replace the plain `AppBar(...)` with `SettingsAppBar`:

Replace:
```dart
appBar: AppBar(
  toolbarHeight: 72,
  ...
),
```
with:
```dart
appBar: SettingsAppBar(
  sectionIndex: _sectionIndex,
  mosqueName: state.request.mosque?.name ?? '',
  onMenuPressed: _drawerController.toggle,
  onRefreshPressed: () => context.read<SettingsBloc>().add(const LoadSettings()),
  popupMenuBuilder: (context) => [
    PopupMenuItem<String>(
      value: 'smart_screen',
      child: Text(S.of(context).enable_smart_screen),
    ),
  ],
  onPopupMenuSelected: (value) async {
    if (value == 'smart_screen') {
      await sl<IAuthRepository>().setAppModeOverride(AppMode.deviceDisplay);
      if (!context.mounted) return;
      context.go(Routes.displayPath);
    }
  },
),
```

Note: The `SettingsAppBar` needs access to `state.request.mosque?.name`. Move the `appBar` inside the `BlocConsumer.builder` so it has access to state. The Scaffold construction must be inside the builder.

Also remove the old `_titleForIndex` method since it's now inside `SettingsAppBar`.

Update the `import` to include the new file.

Also update tab index 4: replace `PhotoStudioSection` reference with `AlbumSection` (create placeholder first that just returns the old content, or do in Task 9).

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: 0 errors.

- [ ] **Step 4: Commit**

```
git add lib/features/settings/presentation/
git commit -m "feat(settings): create gradient SettingsAppBar with section icons and mosque name"
```

---

### Task 9: Redesign AlertsSection with saved-list + publish flow

**Files:**
- Modify: `lib/features/settings/presentation/sections/alerts_section.dart`
- Modify: `lib/features/settings/presentation/widgets/alerts/alert_card.dart`
- Modify: `lib/features/settings/presentation/widgets/alerts/alert_edit_dialog.dart`

- [ ] **Step 1: Redesign AlertsSection**

Rewrite `alerts_section.dart` with the new saved-list + publish flow:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../widgets/alerts/alert_card.dart';
import '../widgets/alerts/alert_edit_dialog.dart';

class AlertsSection extends StatelessWidget {
  final MosqueModel mosque;

  const AlertsSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();
    final s = S.of(context);
    final alerts = mosque.savedAlerts;

    return Scaffold(
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notification_important_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(s.alerts_empty_title, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(s.alerts_empty_subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final isLive = _isAlertLive(alert);
                return AlertCard(
                  alert: alert,
                  isLive: isLive,
                  onPublish: () => _showPublishDialog(context, bloc, alert),
                  onUnpublish: () {
                    bloc.add(AlertUnpublished(alert.id));
                    bloc.add(const SaveAlertsRequested());
                  },
                  onEdit: () => _showEditAlert(context, bloc, alert),
                  onDelete: () {
                    bloc.add(AlertRemoved(alert.id));
                    bloc.add(const SaveAlertsRequested());
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'alerts_fab',
        onPressed: () => _showCreateAlert(context, bloc),
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(s.alert_create),
        backgroundColor: const Color(0xFF1A3C34),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: alerts.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  bloc.add(const AllAlertsDeleted());
                  bloc.add(const SaveAlertsRequested());
                },
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(s.alerts_delete_all),
              ),
            )
          : null,
    );
  }

  bool _isAlertLive(AnnouncementModel alert) {
    if (!alert.isPublished || alert.publishedAt == null) return false;
    final expiry = alert.publishedAt!.add(Duration(seconds: alert.publishDurationSeconds));
    return DateTime.now().isBefore(expiry);
  }

  void _showPublishDialog(BuildContext context, SettingsBloc bloc, AnnouncementModel alert) {
    int duration = 30;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final s = S.of(ctx);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.alert_publish, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(alert.title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
                Text('${s.alert_publish_duration}: $duration ${s.album_seconds_suffix}'),
                Slider(
                  value: duration.toDouble(),
                  min: 10,
                  max: 300,
                  divisions: 29,
                  label: '$duration',
                  onChanged: (v) => setSheetState(() => duration = v.round()),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    bloc.add(AlertPublished(alert.id, duration));
                    bloc.add(const SaveAlertsRequested());
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: Text(s.alert_publish),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateAlert(BuildContext context, SettingsBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertEditDialog(
        onAdd: (alert) {
          bloc.add(AlertAdded(alert));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }

  void _showEditAlert(BuildContext context, SettingsBloc bloc, AnnouncementModel alert) {
    showDialog(
      context: context,
      builder: (context) => AlertEditDialog(
        initialAlert: alert,
        onAdd: (updated) {
          bloc.add(AlertUpdated(updated));
          bloc.add(const SaveAlertsRequested());
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Update AlertCard to show status badges and actions**

Rewrite `alert_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../data/models/mosque/announcement_model.dart';

class AlertCard extends StatelessWidget {
  final AnnouncementModel alert;
  final bool isLive;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlertCard({
    super.key,
    required this.alert,
    required this.isLive,
    required this.onPublish,
    required this.onUnpublish,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Card(
      elevation: isLive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLive ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.green : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLive ? s.alert_status_live : s.alert_status_ready,
                    style: TextStyle(
                      color: isLive ? Colors.white : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (alert.subtitle != null && alert.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(alert.subtitle!, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (isLive)
                  OutlinedButton.icon(
                    onPressed: onUnpublish,
                    icon: const Icon(Icons.stop_rounded, size: 18),
                    label: Text(s.alert_unpublish),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  )
                else
                  FilledButton.icon(
                    onPressed: onPublish,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(s.alert_publish),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A3C34)),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  tooltip: s.alert_edit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: onDelete,
                  tooltip: s.alert_delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Update AlertEditDialog to support editing**

Add an optional `initialAlert` parameter to `AlertEditDialog`. When provided, pre-fill the title and subtitle fields. The dialog should work for both create and edit flows.

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: 0 errors.

- [ ] **Step 5: Commit**

```
git add lib/features/settings/presentation/
git commit -m "feat(settings): redesign AlertsSection with saved-list + publish flow"
```

---

### Task 10: Create AlbumSection (replace PhotoStudioSection)

**Files:**
- Create: `lib/features/settings/presentation/sections/album_section.dart`
- Modify: `lib/features/settings/presentation/settings_page.dart` (update import + tab)
- Modify: `lib/features/settings/presentation/widgets/design/background_settings_section.dart` (remove album URL management)

- [ ] **Step 1: Create AlbumSection with grid layout and publish flow**

Create `lib/features/settings/presentation/sections/album_section.dart` with a grid of album images, add URL FAB, tap-to-publish flow, and save button. Follow the same pattern as AlertsSection (grid of CachedImage thumbnails, tap → bottom sheet with duration picker and publish button, green "LIVE" badge on published image).

Key features:
- `GridView.builder` with 2-3 columns depending on screen width
- Each cell: CachedImage thumbnail + overlay with delete button
- Published image shows green "LIVE" banner
- Tap → bottom sheet: publish to display with duration slider
- FAB: add image URL
- Bottom save button

- [ ] **Step 2: Update SettingsPage import**

In `settings_page.dart`:
- Replace `import 'sections/photo_studio_section.dart'` with `import 'sections/album_section.dart'`
- In the `IndexedStack`, replace `PhotoStudioSection(mosque: mosque)` at index 4 with `AlbumSection(mosque: mosque)`

- [ ] **Step 3: Remove album URL management from BackgroundSettingsSection**

In `background_settings_section.dart`, remove the `AlbumUrlList` widget and the album URL add/remove callbacks. Keep only the background type selector (Color/Image/Album) — when Album is selected, show a message pointing to the Album tab.

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: 0 errors.

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat(settings): create AlbumSection replacing PhotoStudioSection with publish flow"
```

---

### Task 11: Create ReligiousContentInline + modify DisplayBeigeArea

**Files:**
- Create: `lib/features/display/presentation/widgets/content/religious_content_inline.dart`
- Modify: `lib/features/display/presentation/widgets/content/display_beige_area.dart`

- [ ] **Step 1: Create ReligiousContentInline widget**

Create `lib/features/display/presentation/widgets/content/religious_content_inline.dart`. This is similar to `ReligiousContentLayer` but:
- No fullscreen background (transparent, fits within beige area)
- Uses `designSettings.colors.inactiveCardTextValue` for text color (readable on beige)
- Accepts `religiousContentFontSize` parameter for scaling
- Same typewriter animation, same _pickSlide logic, same kind badge

Copy the core logic from `ReligiousContentLayer` (the `_pickSlide`, `_SlideContent`, `_kindLabel` methods, the AnimationController typewriter logic) but adapt the build method:
- Remove `Container(color: bgColor, width/height: infinity)`
- Use `Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16))`
- Text color: `designSettings.colors.inactiveCardTextValue`
- Badge background: `textColor.withValues(alpha: 0.15)`
- Font sizes use `religiousContentFontSize` multipliers

- [ ] **Step 2: Modify DisplayBeigeArea to switch between prayer cards and content**

Add new parameters to `DisplayBeigeArea`:
```dart
final bool showReligiousContent;
final int religiousSlideIndex;
```

In the `build` method, use `AnimatedSwitcher` to switch between `PrayerCardsRow` and `ReligiousContentInline`:

```dart
child: AnimatedSwitcher(
  duration: const Duration(milliseconds: 600),
  child: widget.showReligiousContent
      ? ReligiousContentInline(
          key: ValueKey('religious_${widget.religiousSlideIndex}'),
          mosque: widget.mosque,
          designSettings: design,
          slideIndex: widget.religiousSlideIndex,
          religiousContentFontSize: design.fontSizes.religiousContent,
        )
      : PrayerCardsRow(
          key: const ValueKey('prayers'),
          mosque: widget.mosque,
          designSettings: design,
          helper: _helper,
          now: _now,
          focusScale: design.prayerCardScale,
        ),
),
```

Default values: `showReligiousContent = false`, `religiousSlideIndex = 0`.

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: May have errors in display_screen.dart — will fix in Task 12.

- [ ] **Step 4: Commit**

```
git add lib/features/display/presentation/widgets/content/
git commit -m "feat(display): create ReligiousContentInline, add content/prayer toggle to DisplayBeigeArea"
```

---

### Task 12: Update DisplayScreen + DisplayLayerController

**Files:**
- Modify: `lib/features/display/presentation/display_screen.dart`
- Modify: `lib/features/display/controller/display_layer_controller.dart`
- Modify: `lib/features/display/presentation/widgets/layers/photo_studio_layer.dart` (rename class)

- [ ] **Step 1: Update DisplayLayerController alert detection**

In `display_layer_controller.dart`, change the `activeAlert` getter to use publish fields:

```dart
AnnouncementModel? get activeAlert {
  if (_alerts.isEmpty) return null;
  final now = DateTime.now();
  for (final a in _alerts) {
    if (!a.isPublished || a.publishedAt == null) continue;
    final expiry = a.publishedAt!.add(Duration(seconds: a.publishDurationSeconds));
    if (now.isBefore(expiry)) return a;
  }
  return null;
}
```

Also update `updateAlerts` to accept the renamed parameter:
```dart
void updateAlerts(List<AnnouncementModel> savedAlerts) {
  _alerts = savedAlerts;
  _resolve();
}
```

- [ ] **Step 2: Rename PhotoStudioLayer class to AlbumImageLayer**

In `photo_studio_layer.dart`, rename the class:
```dart
class AlbumImageLayer extends StatelessWidget { ... }
```

Update all references in `display_screen.dart` and barrel files.

- [ ] **Step 3: Update DisplayScreen**

In `display_screen.dart`:

**a) Update _updateLayerInputs** — pass `savedAlerts` and `albumImageUrls`:
```dart
_layerController.updateAlerts(mosque.savedAlerts);
```

**b) Update _buildBaseLayer** — pass religious content flag to DisplayBeigeArea:
```dart
DisplayBeigeArea(
  mosque: mosque,
  designSettings: design,
  showReligiousContent: _layerController.state.activeLayer == DisplayLayerKind.religious,
  religiousSlideIndex: _layerController.religiousSlideIndex,
),
```

Also update `DisplayBackgroundImage` to use `mosque.albumImageUrls`:
```dart
DisplayBackgroundImage(
  fallbackColor: colors.primaryValue,
  settings: design.background,
  albumUrls: mosque.albumImageUrls,
),
```

**c) Update _buildOverlayLayer** — pass font sizes and handle religious case:

For AlertLayer:
```dart
case DisplayLayerKind.alert:
  return AlertLayer(
    alerts: mosque.savedAlerts,
    alertsFontSize: design.fontSizes.alerts,
    primaryColor: colors.activeCardTextValue,
    backgroundColor: colors.activeCardValue,
    numeralFormat: design.numeralFormat,
    fontFamily: design.fontFamily,
    onExpired: _updateLayerInputs,
  );
```

For IqamaAdhanLayer:
```dart
case DisplayLayerKind.iqamaAdhan:
  ...
  return IqamaAdhanLayer(
    phase: phase,
    remaining: remaining,
    designSettings: design,
    isFriday: now.weekday == DateTime.friday,
    countdownFontSize: design.fontSizes.countdown,
  );
```

For PhotoStudio (now AlbumImageLayer):
```dart
case DisplayLayerKind.photoStudio:
  return AlbumImageLayer(
    imageUrl: _layerController.photoStudioUrl ?? '',
    backgroundColor: colors.primaryValue,
  );
```

For Religious — **remove from overlay stack** since it's now inline:
```dart
case DisplayLayerKind.religious:
  return const SizedBox.shrink(); // Handled inline by DisplayBeigeArea
```

**d) Update overlay check** — religious layer no longer shows overlay:
```dart
if (activeLayer == DisplayLayerKind.prayerTimes ||
    activeLayer == DisplayLayerKind.religious) {
  return const SizedBox.shrink();
}
```

- [ ] **Step 4: Update display_background_image.dart**

If it references `backgroundAlbumUrls`, update the parameter name to match `albumUrls`.

- [ ] **Step 5: Verify**

Run: `flutter analyze`
Expected: 0 errors.

Run: `flutter build web`
Expected: Build succeeds.

- [ ] **Step 6: Commit**

```
git add -A
git commit -m "feat(display): wire font sizes, inline religious content, rename to AlbumImageLayer"
```

---

### Task 13: Update barrel files, clean imports, fix drawer content

**Files:**
- Modify: `lib/features/display/presentation/widgets/layers/layers_widgets.dart`
- Modify: `lib/features/settings/presentation/widgets/design/design_widgets.dart`
- Modify: `lib/features/settings/presentation/widgets/common/settings_zoom_drawer_content.dart`
- Modify: `lib/features/display/presentation/widgets/content/content_widgets.dart`

- [ ] **Step 1: Update layers barrel file**

In `layers_widgets.dart`, rename the photo studio export:
```dart
export 'photo_studio_layer.dart'; // class is now AlbumImageLayer
```

Add the religious content inline widget if needed.

- [ ] **Step 2: Update content barrel file**

In `content_widgets.dart`, add:
```dart
export 'religious_content_inline.dart';
```

- [ ] **Step 3: Update drawer content**

In `settings_zoom_drawer_content.dart`, update tab 4 label from `s.tab_photo_studio` to `s.tab_album`.

- [ ] **Step 4: Remove old PhotoStudioSection file**

Delete or empty `lib/features/settings/presentation/sections/photo_studio_section.dart` since it's replaced by `album_section.dart`.

- [ ] **Step 5: Verify everything compiles**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings (info OK).

Run: `flutter build web`
Expected: Build succeeds.

- [ ] **Step 6: Commit**

```
git add -A
git commit -m "chore: update barrel files, clean imports, rename photo studio→album throughout"
```

---

### Task 14: Final verification and hardcoded string audit

- [ ] **Step 1: Audit for hardcoded strings**

Search all modified files for user-facing strings not going through `S.of(context)`. Check:
- `alert_layer.dart` — no hardcoded text (just icons)
- `iqama_adhan_layer.dart` — has hardcoded Arabic strings ('حان الآن...') — wrap in i18n
- `religious_content_layer.dart` — uses `s.display_ticker_*` — OK
- `album_section.dart` — uses `s.album_*` — OK
- `alerts_section.dart` — uses `s.alert_*` — OK
- `settings_app_bar.dart` — uses `s.tab_*` — OK

Fix any hardcoded strings found.

- [ ] **Step 2: Run full analysis**

```
flutter analyze
```
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Run web build**

```
flutter build web
```
Expected: Build succeeds.

- [ ] **Step 4: Commit any final fixes**

```
git add -A
git commit -m "chore: fix hardcoded strings, final verification passes"
```
