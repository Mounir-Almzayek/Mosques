# Settings Restructuring & Display Improvements - Design Spec

## Goal

Restructure the mosque app settings from 12 flat drawer sections into logically grouped tabs, add missing timing controls, replace the gold color system with `#384c4b` teal-green, and consolidate religious content and prayer settings.

## Scope

1. **Color system**: Replace all gold/yellow (`#D4AF37`, `#C9A227`, `#8B6914`) with `#384c4b` teal-green palette
2. **Settings tab restructure**: Reorganize 12 sections into 7 main + 3 utility tabs
3. **Background type change**: Replace `remoteUrl` with `album` (list of URLs)
4. **New settings controls**: Timing controls, prayer card scale slider
5. **Data model additions**: `backgroundAlbumUrls`, `prayerCardScale`, `backgroundFolderUrl`

---

## 1. Color System Change

### Current State

`lib/core/styles/app_colors.dart` defines a gold palette:
- `goldDeep` = `#8B6914`
- `goldRich` / `primary` = `#C9A227`
- `goldBright` / `primaryStart` = `#D4AF37`
- `goldLight` = `#E8D5A3`
- `goldWhisper` = `#F3EAD8`

These are used in:
- Drawer header gradient
- Login page backgrounds
- Save buttons and accents
- Selection highlights
- `goldLuxuryGradient`, `primaryGradient`, `goldHairlineGradient`

### New Palette

Base color: `#384c4b` (deep teal-green).

| Token | Hex | Usage |
|-------|-----|-------|
| `primaryDark` | `#2a3a39` | Deep accents, gradient end |
| `primary` | `#384c4b` | Main brand color |
| `primaryLight` | `#4d6362` | Lighter variant, gradient start |
| `primarySurface` | `#a8bfbe` | Surface tints, disabled states |
| `primaryWhisper` | `#dce8e7` | Very light backgrounds, cards |

### Gradient Updates

- `primaryGradient`: `[#4d6362, #384c4b, #2a3a39]` (topLeft → bottomRight)
- `loginBackgroundGradient`: Adjust to use teal whisper/surface tones
- `goldHairlineGradient` → rename to `accentGradient`: Teal-based thin decorative gradient
- Remove all `gold*` named constants

### Files to Change

- `lib/core/styles/app_colors.dart` — Replace palette and gradients
- `lib/core/styles/app_theme.dart` — Update primary/secondary ColorScheme seeds
- `lib/features/settings/presentation/widgets/common/settings_drawer.dart` — Drawer header gradient
- `lib/features/auth/presentation/login_screen.dart` — Login background
- `lib/features/settings/presentation/sections/*_section.dart` — Save button gradients (all sections using `AppColors.primaryGradient`)

---

## 2. Settings Tab Restructure

### Current State

`settings_page.dart` uses `IndexedStack` with `_sectionIndex` driven by a side drawer. 12 flat sections.

### New Structure

Same `IndexedStack` + drawer pattern, but reorganized into **10 tabs** (7 functional + 3 utility):

| Index | Tab | Icon | Section Widget |
|-------|-----|------|----------------|
| 0 | General | `Icons.mosque` | `GeneralSection` (simplified) |
| 1 | Prayer & Iqama | `Icons.access_time` | `PrayerIqamaSection` (new, merged) |
| 2 | Religious Content | `Icons.menu_book` | `ReligiousContentSection` (new, merged) |
| 3 | Design | `Icons.palette` | `DesignSection` (extended) |
| 4 | Photo Studio | `Icons.photo_library` | `PhotoStudioSection` (new) |
| 5 | Announcements | `Icons.campaign` | `AnnouncementSection` (existing) |
| 6 | Alerts | `Icons.warning_amber` | `AlertsSection` (existing) |
| 7 | Profile | `Icons.person` | `ProfileSection` (existing) |
| 8 | About | `Icons.info_outline` | `AboutSection` (existing) |
| 9 | Update | `Icons.system_update_alt` | `UpdateSection` (existing) |

### 2.1 General Section (Simplified)

**Remove from General:**
- Prayer calculation method → moves to Prayer & Iqama tab
- Prayer offsets (6 steppers) → moves to Prayer & Iqama tab
- Language dropdown → moves to Prayer & Iqama tab

**Keep in General:**
- Mosque name (text field, required)
- City (text field, required)
- Location coordinates (display + "get current location" button)
- Save button

### 2.2 Prayer & Iqama Section (New - Merged)

Combines content from old General section and old Iqama section.

**Sub-sections (scrollable, card-based):**

1. **Prayer Calculation**
   - Method dropdown (12 methods)
   - Language selection dropdown

2. **Prayer Time Offsets**
   - 6 `OffsetStepperField` widgets (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)

3. **Iqama Offsets**
   - 6 `OffsetStepperField` widgets (Fajr, Dhuhr, Asr, Maghrib, Isha, Jummah)

4. **Display Timing**
   - Pre-Adhan minutes stepper (how many minutes before adhan to show countdown), default 5
   - Adhan moment duration seconds stepper (how long the adhan screen stays), default 60

**Save button** at bottom (floating, same pattern as Design section).

### 2.3 Religious Content Section (New - Merged)

Combines old Hadith, Verses, Duas, and Adhkar sections into one tab.

**Layout:** 4 expandable/accordion panels, one per content type.

Each panel when expanded shows the same list-management UI that the individual sections had:
- List of items with add/edit/delete
- Reorderable

**Timing Controls** at top (above the accordion):
- Religious content wait seconds stepper (interval between appearances), default 120
- Religious content display seconds stepper (how long it stays on screen), default 30

**Save button** at bottom.

### 2.4 Design Section (Extended)

Existing sub-sections stay:
1. Background settings (modified — see section 3 below)
2. Color settings (6 pickers)
3. Font size settings (5 controls)
4. Typography settings (font family + numeral format)
5. Behavior settings (ticker speed, strip speed)

**New sub-section** between Font Sizes and Typography:

6. **Prayer Card Scale**
   - Slider from 0.5 to 2.0, step 0.1
   - Label shows current value: "1.2x"
   - Default: 1.0
   - Visual preview text: "Prayer card size"

### 2.5 Photo Studio Section (New)

Manages `MosqueModel.photoStudioUrls: List<String>`.

**UI:**
- Header text explaining this is for fullscreen photo display rotation
- "Add URL" button → text field dialog
- List of URL cards, each with:
  - Thumbnail preview (network image, small)
  - URL text (truncated)
  - Delete button (icon)
- Reorderable via drag handles
- Save button at bottom

---

## 3. Background Type Change

### Current State

`DisplayBackgroundType` enum: `image`, `color`, `remoteUrl`

`DesignBackgroundSettings`:
- `type: DisplayBackgroundType`
- `value: String` (preset ID, hex color, or single remote URL)

### New State

Replace `remoteUrl` with `album`:

```dart
enum DisplayBackgroundType {
  image,   // Preset/local backgrounds
  color,   // Solid color fill
  album,   // Cycles through list of user URLs
}
```

**Album mode:**
- When `album` is selected, the display cycles through `MosqueModel.backgroundAlbumUrls`
- Crossfade transition between images (same interval as photo studio or a fixed 30s)
- `DesignBackgroundSettings.value` is unused in album mode (URLs stored separately)

**Background Settings UI (Design tab):**
- `SegmentedButton` with 3 options: Image | Color | Album
- Image mode: existing preset picker
- Color mode: existing color picker
- Album mode: list management UI (same pattern as Photo Studio):
  - Add URL button
  - Thumbnail + URL + delete per item
  - Reorderable

### Global Background Folder URL

`AppSettingsModel` gets a new field:
- `backgroundFolderUrl: String?` — A URL prefix/folder that the app can use to discover background images

This is read-only for mosque admins (set globally in Firebase `app_settings/global` document). The display screen can use this as a fallback source for backgrounds.

**Firestore field:** `background_folder_url` in `app_settings/global`

---

## 4. Data Model Changes

### MosqueModel

Add field:
- `List<String> backgroundAlbumUrls` — default `[]`

Firestore field: `background_album_urls`

### DesignSettingsModel

Add field:
- `double prayerCardScale` — default `1.0`, range 0.5-2.0

Firestore field: `prayer_card_scale` (nested inside `design_settings`)

### AppSettingsModel

Add field:
- `String? backgroundFolderUrl`

Firestore field: `background_folder_url`

### DisplayBackgroundType enum

- Rename `remoteUrl` → `album`
- Update `fromString` / `name` accordingly

### FirestoreSchema constants

Add:
- `backgroundAlbumUrls = 'background_album_urls'`
- `prayerCardScale = 'prayer_card_scale'`
- `backgroundFolderUrl = 'background_folder_url'`

---

## 5. Settings Events

### New Events

```dart
// Prayer & Iqama tab
PrayerCalculationMethodChanged(String method)  // moved from GeneralField
LanguageChanged(AppLanguage language)            // already exists
PreAdhanMinutesChanged(int minutes)              // new
AdhanMomentDurationChanged(int seconds)          // new

// Religious Content tab
ReligiousContentWaitChanged(int seconds)         // new
ReligiousContentDisplayChanged(int seconds)      // new

// Design tab
PrayerCardScaleChanged(double scale)             // new

// Photo Studio tab
PhotoStudioUrlAdded(String url)                  // new
PhotoStudioUrlRemoved(int index)                 // new
PhotoStudioUrlsReordered(List<String> urls)       // new
SavePhotoStudioRequested()                       // new

// Background album (Design tab)
BackgroundAlbumUrlAdded(String url)              // new
BackgroundAlbumUrlRemoved(int index)             // new
BackgroundAlbumUrlsReordered(List<String> urls)  // new
```

### Moved Events

- `PrayerCalculationMethodChanged` — from GeneralField enum to standalone (moves to Prayer tab)
- `LanguageChanged` — stays as-is, handler moves to Prayer tab context
- Prayer offset events — stay as `PrayerOffsetChanged(PrayerOffsetField, int)`, handler moves to Prayer tab

---

## 6. Display Screen Integration

### Prayer Card Scale

In `DisplayScreen`, apply the scale to the prayer card row:

```dart
Transform.scale(
  scale: mosque.designSettings.prayerCardScale,
  child: PrayerCardsRow(...),
)
```

### Album Background Cycling

When `background.type == album` and `mosque.backgroundAlbumUrls.isNotEmpty`:
- Timer cycles through URLs (e.g., every 30 seconds)
- `AnimatedSwitcher` with crossfade between `Image.network` widgets
- Fallback to color/preset if album is empty

---

## 7. Files to Create

- `lib/features/settings/presentation/sections/prayer_iqama_section.dart`
- `lib/features/settings/presentation/sections/religious_content_section.dart`
- `lib/features/settings/presentation/sections/photo_studio_section.dart`

## 8. Files to Modify

- `lib/core/styles/app_colors.dart` — New teal palette
- `lib/core/styles/app_theme.dart` — Update color scheme
- `lib/core/constants/firestore_schema.dart` — New field constants
- `lib/core/enums/display_background_type.dart` — `remoteUrl` → `album`
- `lib/data/models/mosque/mosque_model.dart` — Add `backgroundAlbumUrls`
- `lib/data/models/design/design_settings_model.dart` — Add `prayerCardScale`
- `lib/data/models/app/app_settings_model.dart` — Add `backgroundFolderUrl`
- `lib/features/settings/presentation/settings_page.dart` — Restructure tabs
- `lib/features/settings/presentation/widgets/common/settings_drawer.dart` — Update navigation items + gradient
- `lib/features/settings/presentation/sections/general_section.dart` — Simplify (remove prayer/iqama/language)
- `lib/features/settings/presentation/sections/design_section.dart` — Add prayer card scale + album background UI
- `lib/features/settings/bloc/settings/settings_event.dart` — New events
- `lib/features/settings/bloc/settings/settings_bloc.dart` — Register new handlers
- `lib/features/settings/bloc/settings/handlers/general_settings_handler.dart` — Simplify
- `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart` — Add scale handler
- `lib/features/display/presentation/display_screen.dart` — Prayer card scale + album background cycling
- `lib/features/display/presentation/widgets/background/display_background_image.dart` — Album support
- `lib/features/auth/presentation/login_screen.dart` — Teal colors
- All section files with save buttons — Update gradient color

## 9. Files to Delete

- `lib/features/settings/presentation/sections/iqama_section.dart` (merged into prayer_iqama_section)
- `lib/features/settings/presentation/sections/mosque_text_list_section.dart` (merged into religious_content_section — the 4 individual content types that were separate drawer items are now sub-sections)
