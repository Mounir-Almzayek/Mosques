# Settings, Font Controls, Album, Alerts & Display Refactor

## Goal

Expand font size controls to 7 independent fields, unify Photo Studio and Album into one concept, redesign instant alerts as a saved-list with publish-on-demand flow, change religious content from full overlay to prayer-area replacement, redesign the settings AppBar, and clean up naming and i18n across the board.

## Architecture

The refactor touches three layers: **data models** (FontSizeSettings expansion, album unification, alert publish flow), **settings UI** (AppBar redesign, new font sliders, album tab, alerts tab), and **display screen** (wire new font sizes, religious content inline mode, album layer rename). All changes follow existing patterns: Equatable models with `fromMap`/`toMap`/`copyWith`, BLoC events with parameterized enums, and the display layer controller state machine.

## Tech Stack

- Flutter 3.x with flutter_bloc, Equatable, GetIt DI
- Firestore for persistence (existing schema, additive changes only)
- `S.of(context)` for i18n (intl_en.arb + intl_ar.arb)
- CachedNetworkImage for album images

---

## 1. Font Size Architecture Expansion

### Current State

`FontSizeSettings` has 5 fields: `clock`, `mosqueInfo`, `prayers`, `announcements`, `content`. Each stored in Firestore as `<name>_font_size`. The `DesignFontSizeField` enum mirrors these 5 values.

**Problem**: Two display layers use hardcoded font sizes:
- `AlertLayer`: title=64px, subtitle=38px (ignores model)
- `IqamaAdhanLayer`: countdown=96px, title=48px (ignores model)
- `ReligiousContentLayer`: text=42px (ignores `content` field in model!)

### Changes

#### 1.1 Expand FontSizeSettings model

**File**: `lib/data/models/design/font_size_settings.dart`

Add 2 new fields:
- `alerts: double` (default: 20.0) — controls AlertLayer title size. Subtitle derives from `alerts * 0.6`.
- `countdown: double` (default: 20.0) — controls IqamaAdhanLayer countdown timer size. Title derives from `countdown * 0.5`.

Firestore keys: `alerts_font_size`, `countdown_font_size`.

Update `copyWith`, `fromMap`, `toMap`, `props`.

#### 1.2 Expand DesignFontSizeField enum

**File**: `lib/features/settings/bloc/settings/settings_event.dart`

Add: `alerts`, `countdown` to `DesignFontSizeField`.

#### 1.3 Update design_settings_handler.dart

**File**: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`

Add switch cases for `DesignFontSizeField.alerts` and `DesignFontSizeField.countdown`.

#### 1.4 Update FontSizeSettingsSection widget

**File**: `lib/features/settings/presentation/widgets/design/font_size_settings_section.dart`

Add 2 new `DesignFontSizeItem` entries:
- Alerts font size (icon: `Icons.campaign_outlined`)
- Countdown font size (icon: `Icons.timer_outlined`)

Add 2 new callbacks: `onAlertsSizeChanged`, `onCountdownSizeChanged`.

#### 1.5 Update DesignSection

**File**: `lib/features/settings/presentation/sections/design_section.dart`

Wire the 2 new font size callbacks to `DesignFontSizeChanged` events.

#### 1.6 Wire font sizes into display layers

**AlertLayer** (`lib/features/display/presentation/widgets/layers/alert_layer.dart`):
- Accept `alertsFontSize: double` parameter
- Title: `fontSize: alertsFontSize * 3.2` (was hardcoded 64px)
- Subtitle: `fontSize: alertsFontSize * 1.9` (was hardcoded 38px)
- Icon: `size: alertsFontSize * 3.2`

**IqamaAdhanLayer** (`lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart`):
- Accept `countdownFontSize: double` parameter
- Countdown: `fontSize: countdownFontSize * 4.8` (was hardcoded 96px)
- Title: `fontSize: countdownFontSize * 2.4` (was hardcoded 48px)
- Icon: `size: countdownFontSize * 4.0` (was hardcoded 80px)

**ReligiousContentLayer** (`lib/features/display/presentation/widgets/layers/religious_content_layer.dart`):
- Accept `contentFontSize: double` parameter
- Main text: `fontSize: contentFontSize * 2.1` (was hardcoded 42px)
- Source: `fontSize: contentFontSize * 1.1` (was hardcoded 22px)
- Badge: `fontSize: contentFontSize * 1.0` (was hardcoded 20px)

**DisplayScreen** passes `designSettings.fontSizes.alerts`, `.countdown`, `.content` to each layer.

#### 1.7 Add i18n strings

English (`intl_en.arb`):
- `design_alerts_font_size`: "Alerts font size"
- `design_countdown_font_size`: "Countdown font size"

Arabic (`intl_ar.arb`):
- `design_alerts_font_size`: "حجم خط التنبيهات"
- `design_countdown_font_size`: "حجم خط العد التنازلي"

---

## 2. Album Unification (Photo Studio = Album)

### Current State

Two separate URL lists:
- `photoStudioUrls: List<String>` on MosqueModel — shown fullscreen via PhotoStudioLayer
- `backgroundAlbumUrls: List<String>` on MosqueModel — cycle as background images

Two separate settings sections:
- PhotoStudioSection (tab index 4) — manage photo URLs
- BackgroundSettingsSection (inside DesignSection) — manage background album URLs

### Changes

#### 2.1 Unify data on MosqueModel

**File**: `lib/data/models/mosque/mosque_model.dart`

- Rename `photoStudioUrls` to `albumImageUrls`
- Remove `backgroundAlbumUrls` (album images serve both purposes)
- Firestore key: `album_image_urls` (add migration fallback reading `photo_studio_urls` and `background_album_urls` and merging)
- Keep `backgroundAlbumUrls` as a deprecated getter that returns `albumImageUrls` during transition

#### 2.2 Add published image tracking

Add to MosqueModel:
- `publishedAlbumImageUrl: String?` — URL of currently published fullscreen image
- `publishedAlbumImageAt: DateTime?` — when it was published
- `publishedAlbumImageDuration: int` — display duration in seconds (default: 30)

Firestore keys: `published_album_url`, `published_album_at`, `published_album_duration`.

Display logic: Show fullscreen if `publishedAlbumImageUrl != null && now < publishedAlbumImageAt + duration`.

#### 2.3 Rename and redesign AlbumSection

**Rename**: `PhotoStudioSection` → `AlbumSection`
**File**: `lib/features/settings/presentation/sections/album_section.dart`

New UX:
- Grid layout showing all album image thumbnails (2-3 columns)
- Each thumbnail shows the image with a subtle overlay
- Tap image → bottom sheet with "Publish to Display" button + duration picker
- Published image shows green "LIVE" badge with countdown timer
- FAB to add new image URL
- Long-press to delete

#### 2.4 Remove album URLs from BackgroundSettingsSection

**File**: `lib/features/settings/presentation/widgets/design/background_settings_section.dart`

Remove the album URL management from the design section. Album management lives exclusively in the Album tab. The background type `album` still works but reads from `albumImageUrls`.

#### 2.5 Update display widgets

**DisplayBackgroundImage**: Read from `mosque.albumImageUrls` instead of `mosque.backgroundAlbumUrls`.

**PhotoStudioLayer** → rename to **AlbumImageLayer**:
- Read published image from `mosque.publishedAlbumImageUrl`
- Check expiry: `now < publishedAlbumImageAt + duration`

**DisplayLayerController**: Update photo studio references to album terminology.

#### 2.6 Update settings events

Rename events:
- `PhotoStudioUrlAdded` → `AlbumImageAdded`
- `PhotoStudioUrlRemoved` → `AlbumImageRemoved`
- `SavePhotoStudioRequested` → `SaveAlbumRequested`

Add new events:
- `AlbumImagePublished(url: String, durationSeconds: int)` — publishes image to display
- `AlbumImageUnpublished()` — removes published image

#### 2.7 Update BLoC handler

Rename handler methods to match new event names. Add publish/unpublish handlers that update `publishedAlbumImageUrl`, `publishedAlbumImageAt`, `publishedAlbumImageDuration` on the mosque model.

#### 2.8 i18n updates

Rename all `photo_studio_*` keys to `album_*`:

English:
- `tab_album`: "Album"
- `album_empty`: "No images added yet"
- `album_add_url`: "Add Image URL"
- `album_publish`: "Publish to Display"
- `album_publish_duration`: "Display duration"
- `album_live_badge`: "LIVE"
- `album_unpublish`: "Remove from Display"

Arabic:
- `tab_album`: "الألبوم"
- `album_empty`: "لم تتم إضافة صور بعد"
- `album_add_url`: "إضافة رابط صورة"
- `album_publish`: "نشر على الشاشة"
- `album_publish_duration`: "مدة العرض"
- `album_live_badge`: "مباشر"
- `album_unpublish`: "إزالة من الشاشة"

---

## 3. Instant Alerts Redesign

### Current State

`activeAlerts: List<AnnouncementModel>` on MosqueModel. Each alert has `startDate`, `endDate`, `displayDurationSeconds`. AlertsSection creates alerts that immediately show on display. No concept of "saved but not published."

### Changes

#### 3.1 Rename field on MosqueModel

**File**: `lib/data/models/mosque/mosque_model.dart`

- Rename `activeAlerts` to `savedAlerts`
- Firestore key stays `active_alerts` (backward compatible), but add migration alias

#### 3.2 Add publish fields to AnnouncementModel

**File**: `lib/data/models/mosque/announcement_model.dart`

Add fields:
- `isPublished: bool` (default: false) — whether currently published to display
- `publishedAt: DateTime?` — when last published
- `publishDurationSeconds: int` (default: 30) — how long to show

Keep existing fields (`title`, `subtitle`, `id`, `isActive`, `order`, `qrCodeUrl`).

The `startDate`/`endDate` fields stay on `AnnouncementModel` (used by regular announcements in the ticker). For alerts (`isPriority=true`), display logic switches to the new publish fields.

Firestore: `is_published`, `published_at`, `publish_duration_seconds`.

**Migration**: Existing alerts in Firestore without `is_published` default to `isPublished: false`. Any alert with a `startDate` in the past that hasn't expired is migrated to `isPublished: true, publishedAt: startDate` on first read.

Display logic: Show if `isPublished && publishedAt != null && now < publishedAt + publishDurationSeconds`.

#### 3.3 Redesign AlertsSection

**File**: `lib/features/settings/presentation/sections/alerts_section.dart`

New UX:
- Card-based list of all saved alerts
- Each card shows: title, subtitle (if any), status badge
- Status badges:
  - **Green "LIVE"** — currently published and not expired
  - **Gray "Ready"** — saved but not published
- Tap alert → bottom sheet with:
  - "Publish" button + duration slider (10s–300s, default 30s)
  - "Edit" button → edit title/subtitle
  - "Delete" button → remove from saved list
- Published alert shows countdown timer on card
- FAB to create new alert (just saves it, doesn't publish)

#### 3.4 Update settings events

Rename events:
- `AlertAdded(alert)` stays (creates saved alert)
- `AlertRemoved(alertId)` stays (deletes saved alert)
- `AlertsCleared()` → `AllAlertsDeleted()` (clearer naming)

Add new events:
- `AlertPublished(alertId: String, durationSeconds: int)` — publishes specific alert
- `AlertUnpublished(alertId: String)` — unpublishes specific alert
- `AlertUpdated(alert: AnnouncementModel)` — edit existing alert

#### 3.5 Update AlertLayer display

**File**: `lib/features/display/presentation/widgets/layers/alert_layer.dart`

Change filter logic:
- Current: checks `now` between `startDate` and `startDate + displayDurationSeconds`
- New: checks `isPublished && publishedAt != null && now < publishedAt + publishDurationSeconds`

#### 3.6 Update DisplayLayerController

Adjust alert detection to use new publish fields instead of startDate/endDate.

#### 3.7 i18n updates

English:
- `alert_status_live`: "LIVE"
- `alert_status_ready`: "Ready"
- `alert_publish`: "Publish to Display"
- `alert_unpublish`: "Remove from Display"
- `alert_publish_duration`: "Display duration"
- `alert_edit`: "Edit Alert"
- `alert_delete`: "Delete Alert"
- `alert_create`: "Create Alert"
- `alerts_delete_all`: "Delete All Alerts"

Arabic:
- `alert_status_live`: "مباشر"
- `alert_status_ready`: "جاهز"
- `alert_publish`: "نشر على الشاشة"
- `alert_unpublish`: "إزالة من الشاشة"
- `alert_publish_duration`: "مدة العرض"
- `alert_edit`: "تعديل التنبيه"
- `alert_delete`: "حذف التنبيه"
- `alert_create`: "إنشاء تنبيه"
- `alerts_delete_all`: "حذف جميع التنبيهات"

---

## 4. Religious Content — Prayer Area Replacement

### Current State

`ReligiousContentLayer` is a **full-screen overlay** rendered in the display screen's overlay stack. When active, it covers everything including the header and ticker bar.

### Changes

#### 4.1 Create ReligiousContentInline widget

**File**: `lib/features/display/presentation/widgets/content/religious_content_inline.dart`

A new widget that renders religious content (hadith/verse/dua/dhikr) **within the beige area bounds** (same space as prayer cards). Uses the same typewriter animation, same text styling, same content selection logic as ReligiousContentLayer.

Key differences from overlay version:
- No fullscreen background — uses the existing beige area background
- Sized to fit the prayer cards area (not fullscreen)
- Text colors use `designSettings.colors.inactiveCardTextValue` for readability on beige
- Respects the same `contentFontSize` from FontSizeSettings
- Shows kind badge (Hadith/Verse/Dua/Dhikr) at top
- Animated text in center
- Source at bottom

#### 4.2 Modify DisplayBeigeArea

**File**: `lib/features/display/presentation/widgets/content/display_beige_area.dart`

Add a mode switch:
- Accept `showReligiousContent: bool` and `slideIndex: int` parameters
- When `showReligiousContent == false`: render `PrayerCardsRow` (current behavior)
- When `showReligiousContent == true`: render `ReligiousContentInline`
- Use `AnimatedSwitcher` with crossfade for smooth transition between modes

#### 4.3 Update DisplayScreen

**File**: `lib/features/display/presentation/display_screen.dart`

- Remove `ReligiousContentLayer` from the overlay stack
- Pass `showReligiousContent` flag from `DisplayLayerController.activeLayer == DisplayLayerKind.religious` to `DisplayBeigeArea`
- Pass `slideIndex` from controller to beige area
- The `DisplayLayerKind.religious` no longer triggers a full overlay; it signals the beige area to switch content

#### 4.4 Remove full-screen overlay

Delete the `ReligiousContentLayer` rendering from `DisplayScreen`'s overlay stack. The widget file itself can remain (other projects might reference it), but `DisplayScreen` no longer renders it. The `DisplayLayerKind.religious` enum value stays; its meaning changes from "show full overlay" to "signal beige area to swap content."

---

## 5. Settings AppBar Redesign

### Current State

Plain Material `AppBar`:
- `toolbarHeight: 72`
- Basic `titleLarge` text style (fontSize: 23, fontWeight: w600)
- Plain icon buttons (menu, refresh, popup menu)
- No gradient, no icon per section, no subtitle

### Changes

#### 5.1 Create SettingsAppBar widget

**File**: `lib/features/settings/presentation/widgets/common/settings_app_bar.dart`

A custom `PreferredSizeWidget` that replaces the plain AppBar:

**Visual design**:
- **Height**: 80px
- **Background**: Linear gradient from `#1A3C34` (dark teal) to `#2E7D52` (medium green)
- **Bottom corners**: Rounded with `borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))`
- **Shadow**: Subtle box shadow (`color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)`)

**Content layout**:
- **Leading**: Menu icon (white, 26px) with circular ripple
- **Title area** (column):
  - Section title (white, 20px, FontWeight.w600)
  - Mosque name subtitle (white70, 13px, FontWeight.w400)
- **Section icon**: Small icon matching the current tab (white70, 22px) to the left of the title
- **Actions**: Refresh icon + overflow menu (white icons)

**Section icons map**:
| Tab | Icon |
|-----|------|
| General | `Icons.mosque_outlined` |
| Prayer & Iqama | `Icons.access_time_outlined` |
| Religious Content | `Icons.auto_stories_outlined` |
| Design | `Icons.palette_outlined` |
| Album | `Icons.photo_library_outlined` |
| Announcements | `Icons.campaign_outlined` |
| Alerts | `Icons.notification_important_outlined` |
| Profile | `Icons.person_outlined` |
| About | `Icons.info_outlined` |
| Update | `Icons.system_update_outlined` |

#### 5.2 Integrate into SettingsPage

**File**: `lib/features/settings/presentation/settings_page.dart`

Replace the inline `AppBar(...)` with `SettingsAppBar(sectionIndex: _sectionIndex, mosqueName: mosque.name, ...)`.

---

## 6. Naming & i18n Cleanup

### 6.1 File and class renames

| Current | New | Files affected |
|---------|-----|----------------|
| `PhotoStudioSection` | `AlbumSection` | section file + settings_page.dart |
| `PhotoStudioLayer` | `AlbumImageLayer` | layer file + display_screen.dart + barrel |
| `photo_studio_layer.dart` | `album_image_layer.dart` | file rename |
| `photo_studio_section.dart` | `album_section.dart` | file rename |
| `PhotoStudioUrlAdded` | `AlbumImageAdded` | events + handler |
| `PhotoStudioUrlRemoved` | `AlbumImageRemoved` | events + handler |
| `SavePhotoStudioRequested` | `SaveAlbumRequested` | events + handler |
| `photoStudioUrls` | `albumImageUrls` | MosqueModel + all refs |

### 6.2 Font size field rename

| Current | New | Reason |
|---------|-----|--------|
| `content` | `religiousContent` | More explicit about what it controls |

This affects: `FontSizeSettings`, `DesignFontSizeField`, `design_settings_handler`, `FontSizeSettingsSection`, Firestore key (`religious_content_font_size` with fallback to `content_font_size`).

### 6.3 i18n key renames and additions

All `photo_studio_*` keys become `album_*`. See Sections 1-4 above for complete i18n additions.

### 6.4 Hardcoded string audit

Scan all display and settings widgets for any text not going through `S.of(context)`. Fix any hardcoded user-facing strings.

### 6.5 Naming convention enforcement

- All model fields: camelCase
- All Firestore keys: snake_case
- All i18n keys: snake_case
- All event classes: PascalCase with verb suffix (e.g., `AlertPublished`, `AlbumImageAdded`)
- All widget files: snake_case matching class name

---

## 7. Verification Requirements

After all changes:

1. **`flutter analyze`**: 0 errors, 0 warnings (info-level OK)
2. **`flutter build web`**: succeeds
3. **Font size verification**: Each of the 7 font sizes must:
   - Have a working slider in DesignSection (range 8.0–56.0)
   - Persist to Firestore with correct key
   - Be read and applied in the corresponding display widget
   - Scale proportionally (e.g., alerts title = `alertsFontSize * 3.2`)
4. **Album verification**: Images display as both background cycling and fullscreen publish
5. **Alert verification**: Create → Save → Publish → Display → Auto-expire → Re-publish flow works
6. **Religious content**: Shows inline in prayer area, not as overlay
7. **i18n**: No hardcoded user-facing strings in any modified file
8. **Backward compatibility**: Old Firestore documents with `photo_studio_urls`, `background_album_urls`, `content_font_size` still load correctly via migration fallbacks

---

## Summary of File Changes

### New files
- `lib/features/display/presentation/widgets/content/religious_content_inline.dart`
- `lib/features/settings/presentation/widgets/common/settings_app_bar.dart`

### Renamed files
- `photo_studio_section.dart` → `album_section.dart`
- `photo_studio_layer.dart` → `album_image_layer.dart`

### Modified files
- `lib/data/models/design/font_size_settings.dart` (add alerts, countdown, rename content)
- `lib/data/models/mosque/mosque_model.dart` (unify album, add publish fields, rename alerts)
- `lib/data/models/mosque/announcement_model.dart` (add publish fields)
- `lib/features/settings/bloc/settings/settings_event.dart` (new enum values, rename events)
- `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart` (new switch cases)
- `lib/features/settings/presentation/sections/design_section.dart` (wire new font callbacks)
- `lib/features/settings/presentation/widgets/design/font_size_settings_section.dart` (add 2 sliders)
- `lib/features/settings/presentation/sections/alerts_section.dart` (redesign with publish flow)
- `lib/features/settings/presentation/settings_page.dart` (new AppBar, rename album tab)
- `lib/features/display/presentation/display_screen.dart` (pass font sizes, inline content mode)
- `lib/features/display/presentation/widgets/content/display_beige_area.dart` (add content switch)
- `lib/features/display/presentation/widgets/layers/alert_layer.dart` (use font size param, new publish logic)
- `lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart` (use font size param)
- `lib/features/display/presentation/widgets/layers/religious_content_layer.dart` (use font size param)
- `lib/features/display/controller/display_layer_controller.dart` (update alert detection)
- `lib/features/settings/presentation/widgets/design/background_settings_section.dart` (remove album URLs)
- `lib/core/l10n/intl_en.arb` (new + renamed keys)
- `lib/core/l10n/intl_ar.arb` (new + renamed keys)
- Various barrel files for import updates
