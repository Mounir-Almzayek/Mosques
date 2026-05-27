# Settings Restructuring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure settings from 12 flat drawer sections into logically grouped tabs, replace gold color system with `#384c4b` teal-green, add timing/scale controls, consolidate religious content, and add album background type.

**Architecture:** Settings drawer navigation remains but items are reorganized from 12→10. Models gain `backgroundAlbumUrls` (MosqueModel), `prayerCardScale` (DesignSettingsModel), and `backgroundFolderUrl` (AppSettingsModel). `DisplayBackgroundType.remoteUrl` is renamed to `album`. New events and handler methods are added to the existing mixin-based SettingsBloc architecture.

**Tech Stack:** Flutter, flutter_bloc, Equatable, GetIt DI, Firebase Firestore

---

## Task 1: Replace gold color palette with teal-green `#384c4b`

**Files:**
- Modify: `lib/core/styles/app_colors.dart`
- Modify: `lib/core/styles/app_theme.dart`

- [ ] **Step 1: Rewrite AppColors with teal palette**

Replace the entire `app_colors.dart` content. The gold constants (`goldDeep`, `goldRich`, `goldBright`, `goldLight`, `goldWhisper`) become teal equivalents. All gradient definitions update to teal tones.

```dart
import 'package:flutter/material.dart';

/// App color palette: deep teal-green brand, warm neutral surfaces.
abstract final class AppColors {
  // —— Brand teal ——
  static const Color primaryDark = Color(0xFF2A3A39);
  static const Color primary = Color(0xFF384C4B);
  static const Color primaryLight = Color(0xFF4D6362);
  static const Color primarySurface = Color(0xFFA8BFBE);
  static const Color primaryWhisper = Color(0xFFDCE8E7);

  // —— Warm surfaces ——
  static const Color creamWhite = Color(0xFFFFFBF7);
  static const Color pearlMist = Color(0xFFF7F3ED);

  /// Alias for primary brand color
  static const Color primaryStart = primaryLight;
  static const Color primaryEnd = primaryDark;

  // —— Text ——
  static const Color primaryText = Color(0xFF2A2A2A);
  static const Color secondaryText = Color(0xFF5E5E5E);
  static const Color mutedForeground = secondaryText;
  static const Color foreground = primaryText;

  // —— Backgrounds & cards ——
  static const Color background = pearlMist;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = surface;
  static const Color brightWhite = surface;
  static const Color muted = primaryWhisper;

  // —— Borders & inputs ——
  static const Color border = Color(0xFFD4DBD9);
  static const Color input = Color(0xFFB8C4C3);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // —— States ——
  static const Color error = Color(0xFFC53030);
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFB8860B);

  // —— Gradients ——
  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), creamWhite, pearlMist],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0x00384C4B), primarySurface, Color(0x00384C4B)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0x1A384C4B), Color(0x26384C4B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
```

- [ ] **Step 2: Update AppTheme color scheme seeds**

In `app_theme.dart`, find the `ColorScheme.fromSeed` call and change the seed color from `AppColors.primary` (which was gold, now teal) — the new palette value flows through automatically. Also search for any direct references to `goldLuxuryGradient` or `goldHairlineGradient` and replace with `primaryGradient` / `accentGradient`.

Note: The theme file uses `AppColors.primary` as seed — since we changed that constant, the ColorScheme will regenerate with teal. Verify no hardcoded gold hex values remain.

- [ ] **Step 3: Run `flutter analyze` and verify 0 errors**

Run: `flutter analyze --no-fatal-infos --no-fatal-warnings`
Expected: No errors. Any compile error means a `gold*` constant was referenced that no longer exists — fix by using the new teal name.

- [ ] **Step 4: Commit**

```
git add lib/core/styles/app_colors.dart lib/core/styles/app_theme.dart
git commit -m "style: replace gold color palette with #384c4b teal-green"
```

---

## Task 2: Add `backgroundAlbumUrls` to MosqueModel + rename `remoteUrl` to `album`

**Files:**
- Modify: `lib/core/enums/display_background_type.dart`
- Modify: `lib/data/models/mosque/mosque_model.dart`
- Modify: `lib/core/constants/firestore_schema.dart`
- Modify: `lib/features/display/presentation/widgets/background/display_background_image.dart`
- Modify: `lib/features/settings/presentation/widgets/design/background_settings_section.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`

- [ ] **Step 1: Rename enum variant `remoteUrl` → `album`**

In `display_background_type.dart`, replace:
```dart
enum DisplayBackgroundType {
  image,
  color,
  remoteUrl;

  String get code {
    if (this == remoteUrl) return 'remote_url';
    return name;
  }

  static DisplayBackgroundType fromCode(String? code) {
    if (code == 'color') return DisplayBackgroundType.color;
    if (code == 'remote_url' || code == 'remoteUrl') return DisplayBackgroundType.remoteUrl;
    return DisplayBackgroundType.image;
  }
}
```

With:
```dart
enum DisplayBackgroundType {
  image,
  color,
  album;

  String get code {
    if (this == album) return 'album';
    return name;
  }

  static DisplayBackgroundType fromCode(String? code) {
    if (code == 'color') return DisplayBackgroundType.color;
    if (code == 'album' || code == 'remote_url' || code == 'remoteUrl') {
      return DisplayBackgroundType.album;
    }
    return DisplayBackgroundType.image;
  }
}
```

- [ ] **Step 2: Add `backgroundAlbumUrls` to MosqueModel**

In `mosque_model.dart`, add field to the class:
```dart
/// Background album image URLs for cycling backgrounds.
final List<String> backgroundAlbumUrls;
```

Add to constructor with default:
```dart
this.backgroundAlbumUrls = const [],
```

Add to `fromMap`:
```dart
backgroundAlbumUrls: (map['background_album_urls'] as List<dynamic>?)
    ?.map((e) => e.toString())
    .toList() ??
    [],
```

Add to `toMap`:
```dart
'background_album_urls': backgroundAlbumUrls,
```

Add to `copyWith` parameter and body:
```dart
List<String>? backgroundAlbumUrls,
// in body:
backgroundAlbumUrls: backgroundAlbumUrls ?? this.backgroundAlbumUrls,
```

Add to `props`:
```dart
backgroundAlbumUrls,
```

- [ ] **Step 3: Add FirestoreSchema constant**

In `firestore_schema.dart`, in the "Mosque fields" section, add:
```dart
static const String backgroundAlbumUrls = 'background_album_urls';
```

- [ ] **Step 4: Update DisplayBackgroundImage widget**

In `display_background_image.dart`, change the `remoteUrl` branch to `album`. For now it shows the first URL from the album list (album cycling will be added in a later task when DisplayScreen integrates it):

Replace:
```dart
if (settings.type == DisplayBackgroundType.remoteUrl) {
```
With:
```dart
if (settings.type == DisplayBackgroundType.album) {
```

- [ ] **Step 5: Update BackgroundCustomUrlChanged handler**

In `design_settings_handler.dart`, change `DisplayBackgroundType.remoteUrl` to `DisplayBackgroundType.album`:

Replace:
```dart
type: DisplayBackgroundType.remoteUrl,
```
With:
```dart
type: DisplayBackgroundType.album,
```

- [ ] **Step 6: Run `flutter analyze`, fix any remaining `remoteUrl` references**

Run: `flutter analyze --no-fatal-infos --no-fatal-warnings`

Search for any remaining `remoteUrl` references:
```
grep -r "remoteUrl" lib/
```

- [ ] **Step 7: Commit**

```
git add -A
git commit -m "refactor: rename remoteUrl to album background type, add backgroundAlbumUrls to MosqueModel"
```

---

## Task 3: Add `prayerCardScale` to DesignSettingsModel + `backgroundFolderUrl` to AppSettingsModel

**Files:**
- Modify: `lib/data/models/design/design_settings_model.dart`
- Modify: `lib/data/models/app/app_settings_model.dart`
- Modify: `lib/core/constants/firestore_schema.dart`

- [ ] **Step 1: Add `prayerCardScale` to DesignSettingsModel**

Add field:
```dart
final double prayerCardScale;
```

Add to constructor with default:
```dart
this.prayerCardScale = 1.0,
```

Add to `fromMap`:
```dart
prayerCardScale: (map['prayer_card_scale'] ?? 1.0).toDouble(),
```

Add to `toMap`:
```dart
'prayer_card_scale': prayerCardScale,
```

Add to `copyWith` parameter and body:
```dart
double? prayerCardScale,
// body:
prayerCardScale: prayerCardScale ?? this.prayerCardScale,
```

Add to `props`:
```dart
prayerCardScale,
```

- [ ] **Step 2: Add `backgroundFolderUrl` to AppSettingsModel**

Add field:
```dart
final String? backgroundFolderUrl;
```

Add to constructor:
```dart
this.backgroundFolderUrl,
```

Add to `fromMap`:
```dart
backgroundFolderUrl: map['background_folder_url'] as String?,
```

Add to `toMap`:
```dart
if (backgroundFolderUrl != null) 'background_folder_url': backgroundFolderUrl,
```

Add to `props`:
```dart
backgroundFolderUrl,
```

- [ ] **Step 3: Add FirestoreSchema constants**

```dart
static const String prayerCardScale = 'prayer_card_scale';
static const String backgroundFolderUrl = 'background_folder_url';
```

- [ ] **Step 4: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat: add prayerCardScale to design settings, backgroundFolderUrl to app settings"
```

---

## Task 4: Add new settings events + BLoC handler wiring

**Files:**
- Modify: `lib/features/settings/bloc/settings/settings_event.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`
- Modify: `lib/features/settings/bloc/settings/settings_bloc.dart`

- [ ] **Step 1: Add new events to settings_event.dart**

Add after the existing `SaveDesignSettingsRequested` class:

```dart
// ——— Prayer Card Scale ———

class PrayerCardScaleChanged extends SettingsEvent {
  final double scale;

  const PrayerCardScaleChanged(this.scale);

  @override
  List<Object?> get props => [scale];
}

// ——— Background Album ———

class BackgroundAlbumUrlAdded extends SettingsEvent {
  final String url;

  const BackgroundAlbumUrlAdded(this.url);

  @override
  List<Object?> get props => [url];
}

class BackgroundAlbumUrlRemoved extends SettingsEvent {
  final int index;

  const BackgroundAlbumUrlRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class BackgroundAlbumUrlsReordered extends SettingsEvent {
  final List<String> urls;

  const BackgroundAlbumUrlsReordered(this.urls);

  @override
  List<Object?> get props => [urls];
}

class SaveBackgroundAlbumRequested extends SettingsEvent {
  const SaveBackgroundAlbumRequested();
}
```

- [ ] **Step 2: Add handler methods to DesignSettingsHandler**

Add to `design_settings_handler.dart`:

```dart
void onPrayerCardScaleChanged(
  PrayerCardScaleChanged event,
  Emitter<SettingsState> emit,
) {
  final m = currentMosque;
  if (m == null) return;
  final d = m.designSettings.copyWith(prayerCardScale: event.scale);
  emitDraftUpdated(
    emit,
    state.request.copyWith(mosque: m.copyWith(designSettings: d)),
  );
}

void onBackgroundAlbumUrlAdded(
  BackgroundAlbumUrlAdded event,
  Emitter<SettingsState> emit,
) {
  final m = currentMosque;
  if (m == null) return;
  final urls = [...m.backgroundAlbumUrls, event.url];
  emitDraftUpdated(
    emit,
    state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: urls)),
  );
}

void onBackgroundAlbumUrlRemoved(
  BackgroundAlbumUrlRemoved event,
  Emitter<SettingsState> emit,
) {
  final m = currentMosque;
  if (m == null) return;
  final urls = List<String>.from(m.backgroundAlbumUrls)..removeAt(event.index);
  emitDraftUpdated(
    emit,
    state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: urls)),
  );
}

void onBackgroundAlbumUrlsReordered(
  BackgroundAlbumUrlsReordered event,
  Emitter<SettingsState> emit,
) {
  final m = currentMosque;
  if (m == null) return;
  emitDraftUpdated(
    emit,
    state.request.copyWith(mosque: m.copyWith(backgroundAlbumUrls: event.urls)),
  );
}
```

- [ ] **Step 3: Register new handlers in SettingsBloc**

In `settings_bloc.dart` constructor, add after the existing design event registrations:

```dart
on<PrayerCardScaleChanged>(onPrayerCardScaleChanged);
on<BackgroundAlbumUrlAdded>(onBackgroundAlbumUrlAdded);
on<BackgroundAlbumUrlRemoved>(onBackgroundAlbumUrlRemoved);
on<BackgroundAlbumUrlsReordered>(onBackgroundAlbumUrlsReordered);
on<SaveBackgroundAlbumRequested>(_onSaveBackgroundAlbum);
```

Add the save method:
```dart
Future<void> _onSaveBackgroundAlbum(
  SaveBackgroundAlbumRequested event,
  Emitter<SettingsState> emit,
) async {
  final m = state.request.mosque;
  if (m == null) return;
  await _save(emit, () => _mosqueRepo.updateMosque(m));
}
```

- [ ] **Step 4: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat: add prayer card scale, background album events and handlers"
```

---

## Task 5: Create PrayerIqamaSection (merged Prayer + Iqama tab)

**Files:**
- Create: `lib/features/settings/presentation/sections/prayer_iqama_section.dart`

- [ ] **Step 1: Create the merged Prayer & Iqama section**

This combines: prayer calculation method + language dropdown from GeneralSection, prayer offsets (6 steppers) from GeneralSection, iqama offsets (6 steppers) from IqamaSection, plus new display timing controls (preAdhan minutes, adhan duration).

Create `prayer_iqama_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/app_language.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../../../features/language/language.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../widgets/common/common_widgets.dart';

class PrayerIqamaSection extends StatelessWidget {
  final MosqueModel mosque;

  const PrayerIqamaSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final design = mosque.designSettings;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Prayer Calculation ---
              _SectionHeader(title: s.prayer_calculation_method, icon: Icons.calculate_outlined),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: mosque.prayerCalculationMethod,
                decoration: InputDecoration(labelText: s.prayer_calculation_method),
                items: const [
                  'MuslimWorldLeague', 'Egyptian', 'Karachi', 'UmmAlQura',
                  'Dubai', 'MoonsightingCommittee', 'NorthAmerica', 'Kuwait',
                  'Qatar', 'Singapore', 'Tehran', 'Turkey',
                ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsBloc>().add(
                      GeneralSettingChanged(GeneralField.calculationMethod, v),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // --- Language ---
              BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, langState) {
                  return DropdownButtonFormField<AppLanguage>(
                    value: langState.language,
                    decoration: InputDecoration(labelText: s.language),
                    items: AppLanguage.values
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context.read<SettingsBloc>().add(LanguageChanged(v));
                        context.read<LanguageBloc>().add(ChangeLanguage(v));
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- Prayer Offsets ---
              _SectionHeader(title: s.prayer_offsets_title, icon: Icons.tune_outlined),
              const SizedBox(height: 8),
              ..._buildPrayerOffsets(context, s, mosque),

              const SizedBox(height: 24),

              // --- Iqama Offsets ---
              _SectionHeader(title: s.tab_iqama, icon: Icons.schedule_outlined),
              const SizedBox(height: 8),
              ..._buildIqamaOffsets(context, s, mosque),

              const SizedBox(height: 24),

              // --- Display Timing ---
              _SectionHeader(title: s.display_timing_title, icon: Icons.timer_outlined),
              const SizedBox(height: 8),
              OffsetStepperField(
                label: s.pre_adhan_minutes,
                value: design.preAdhanMinutes,
                onChanged: (v) => context.read<SettingsBloc>().add(
                  DisplayTimingChanged(DisplayTimingField.preAdhanMinutes, v),
                ),
              ),
              OffsetStepperField(
                label: s.adhan_moment_duration,
                value: design.adhanMomentDurationSeconds,
                onChanged: (v) => context.read<SettingsBloc>().add(
                  DisplayTimingChanged(DisplayTimingField.adhanMomentDuration, v),
                ),
              ),
            ],
          ),
        ),
        // Save button
        _SaveBar(
          onSave: () {
            context.read<SettingsBloc>().add(const SaveGeneralSettingsRequested());
            context.read<SettingsBloc>().add(const SaveIqamaSettingsRequested());
            context.read<SettingsBloc>().add(const SaveDesignSettingsRequested());
          },
        ),
      ],
    );
  }

  List<Widget> _buildPrayerOffsets(BuildContext context, S s, MosqueModel mosque) {
    final fields = [
      (PrayerOffsetField.fajr, s.prayer_fajr, mosque.prayerOffsets.fajr),
      (PrayerOffsetField.sunrise, s.prayer_sunrise, mosque.prayerOffsets.sunrise),
      (PrayerOffsetField.dhuhr, s.prayer_dhuhr, mosque.prayerOffsets.dhuhr),
      (PrayerOffsetField.asr, s.prayer_asr, mosque.prayerOffsets.asr),
      (PrayerOffsetField.maghrib, s.prayer_maghrib, mosque.prayerOffsets.maghrib),
      (PrayerOffsetField.isha, s.prayer_isha, mosque.prayerOffsets.isha),
    ];
    return fields.map((f) => OffsetStepperField(
      label: f.$2,
      value: f.$3,
      onChanged: (v) => context.read<SettingsBloc>().add(PrayerOffsetChanged(f.$1, v)),
    )).toList();
  }

  List<Widget> _buildIqamaOffsets(BuildContext context, S s, MosqueModel mosque) {
    final fields = [
      (IqamaField.fajr, s.prayer_fajr, mosque.iqamaSettings.fajrOffset),
      (IqamaField.dhuhr, s.prayer_dhuhr, mosque.iqamaSettings.dhuhrOffset),
      (IqamaField.asr, s.prayer_asr, mosque.iqamaSettings.asrOffset),
      (IqamaField.maghrib, s.prayer_maghrib, mosque.iqamaSettings.maghribOffset),
      (IqamaField.isha, s.prayer_isha, mosque.iqamaSettings.ishaOffset),
      (IqamaField.jummah, s.prayer_jummah, mosque.iqamaSettings.jummahOffset),
    ];
    return fields.map((f) => OffsetStepperField(
      label: f.$2,
      value: f.$3,
      onChanged: (v) => context.read<SettingsBloc>().add(IqamaOffsetChanged(f.$1, v)),
    )).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (!state.hasUnsavedChanges) return const SizedBox.shrink();
        return Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: FilledButton.icon(
            onPressed: state.isSaving ? null : onSave,
            icon: state.isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(S.of(context).save),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Expected: 0 errors (the section isn't wired into settings_page yet)

- [ ] **Step 3: Commit**

```
git add lib/features/settings/presentation/sections/prayer_iqama_section.dart
git commit -m "feat: create PrayerIqamaSection merging prayer + iqama settings"
```

---

## Task 6: Create ReligiousContentSection (merged 4 text types)

**Files:**
- Create: `lib/features/settings/presentation/sections/religious_content_section.dart`

- [ ] **Step 1: Create the merged Religious Content section**

This section uses an accordion (ExpansionTile) layout with 4 panels (hadith, verse, dua, adhkar) plus timing controls at the top. The list UI inside each panel reuses the same pattern from the existing `MosqueTextListSection`.

Create `religious_content_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/settings/mosque_text_list_kind.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../widgets/common/common_widgets.dart';
import 'mosque_text_list_section.dart';

class ReligiousContentSection extends StatelessWidget {
  final MosqueModel mosque;

  const ReligiousContentSection({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final design = mosque.designSettings;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Timing Controls ---
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 22, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    s.religious_content_timing,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OffsetStepperField(
                label: s.religious_content_wait,
                value: design.religiousContentWaitSeconds,
                onChanged: (v) => context.read<SettingsBloc>().add(
                  DisplayTimingChanged(DisplayTimingField.religiousContentWait, v),
                ),
              ),
              OffsetStepperField(
                label: s.religious_content_display,
                value: design.religiousContentDisplaySeconds,
                onChanged: (v) => context.read<SettingsBloc>().add(
                  DisplayTimingChanged(DisplayTimingField.religiousContentDisplay, v),
                ),
              ),

              const SizedBox(height: 16),

              // --- 4 Accordion panels ---
              _ContentPanel(
                mosque: mosque,
                kind: MosqueTextListKind.hadith,
                title: s.tab_hadith,
                icon: Icons.menu_book_rounded,
              ),
              _ContentPanel(
                mosque: mosque,
                kind: MosqueTextListKind.verse,
                title: s.tab_verses,
                icon: Icons.format_quote_rounded,
              ),
              _ContentPanel(
                mosque: mosque,
                kind: MosqueTextListKind.dua,
                title: s.tab_duas,
                icon: Icons.favorite_border_rounded,
              ),
              _ContentPanel(
                mosque: mosque,
                kind: MosqueTextListKind.adhkar,
                title: s.tab_adhkar,
                icon: Icons.psychology_outlined,
              ),
            ],
          ),
        ),
        // Save timing button
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (!state.hasUnsavedChanges) return const SizedBox.shrink();
              return FilledButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () => context.read<SettingsBloc>().add(
                          const SaveDesignSettingsRequested(),
                        ),
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(S.of(context).save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContentPanel extends StatelessWidget {
  final MosqueModel mosque;
  final MosqueTextListKind kind;
  final String title;
  final IconData icon;

  const _ContentPanel({
    required this.mosque,
    required this.kind,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final items = mosque.listByKind(kind);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          '$title (${items.length})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          // Embed the existing MosqueTextListSection content as a constrained-height child.
          // The MosqueTextListSection is already a full section, so we show it inline.
          SizedBox(
            height: 400,
            child: MosqueTextListSection(mosque: mosque, kind: kind),
          ),
        ],
      ),
    );
  }
}
```

Note: This reuses the existing `MosqueTextListSection` widget inside each accordion panel. Each panel has its own save flow (from `MosqueTextListSection`). The save button at the bottom of `ReligiousContentSection` saves the timing controls (which are design settings).

- [ ] **Step 2: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 3: Commit**

```
git add lib/features/settings/presentation/sections/religious_content_section.dart
git commit -m "feat: create ReligiousContentSection with accordion layout + timing controls"
```

---

## Task 7: Create PhotoStudioSection

**Files:**
- Create: `lib/features/settings/presentation/sections/photo_studio_section.dart`

- [ ] **Step 1: Create the Photo Studio section**

This section manages a list of image URLs with add/remove, thumbnail preview, and save.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../data/models/mosque/mosque_model.dart';
import '../../bloc/settings/settings_bloc.dart';

class PhotoStudioSection extends StatelessWidget {
  final MosqueModel mosque;

  const PhotoStudioSection({super.key, required this.mosque});

  void _showAddUrlDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).photo_studio_add_url),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: S.of(context).url,
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                context.read<SettingsBloc>().add(PhotoStudioUrlAdded(url));
              }
              Navigator.pop(ctx);
            },
            child: Text(S.of(context).add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final urls = mosque.photoStudioUrls;

    return Stack(
      children: [
        urls.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: AppColors.primarySurface),
                    const SizedBox(height: 16),
                    Text(s.photo_studio_empty, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: urls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final url = urls[index];
                  return Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: AppColors.primaryWhisper,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      title: Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () {
                          context.read<SettingsBloc>().add(PhotoStudioUrlRemoved(url));
                        },
                      ),
                    ),
                  );
                },
              ),
        // Floating add button
        Positioned(
          right: 16,
          bottom: 80,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            onPressed: () => _showAddUrlDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
        // Save button
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (!state.hasUnsavedChanges) return const SizedBox.shrink();
              return FilledButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () => context.read<SettingsBloc>().add(const SavePhotoStudioRequested()),
                icon: state.isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(S.of(context).save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 3: Commit**

```
git add lib/features/settings/presentation/sections/photo_studio_section.dart
git commit -m "feat: create PhotoStudioSection for image URL list management"
```

---

## Task 8: Simplify GeneralSection + extend DesignSection

**Files:**
- Modify: `lib/features/settings/presentation/sections/general_section.dart`
- Modify: `lib/features/settings/presentation/sections/design_section.dart`
- Modify: `lib/features/settings/presentation/widgets/design/background_settings_section.dart`

- [ ] **Step 1: Simplify GeneralSection**

Remove from `general_section.dart`:
1. The prayer calculation method dropdown
2. The language dropdown and LanguageBloc import
3. The 6 prayer offset steppers
4. Keep ONLY: mosque name, city, coordinates, get-location button, save button

The GeneralSection should be significantly shorter — just a simple form with name, city, and location.

- [ ] **Step 2: Add prayer card scale slider to DesignSection**

In `design_section.dart`, add a new sub-section between FontSizeSettingsSection and TypographySettingsSection:

```dart
// Prayer Card Scale
DesignCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DesignSectionTitle(
        title: s.prayer_card_scale,
        icon: Icons.aspect_ratio_outlined,
      ),
      Row(
        children: [
          const Text('0.5x'),
          Expanded(
            child: Slider(
              value: design.prayerCardScale,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${design.prayerCardScale.toStringAsFixed(1)}x',
              onChanged: (v) => context.read<SettingsBloc>().add(
                PrayerCardScaleChanged(v),
              ),
            ),
          ),
          const Text('2.0x'),
        ],
      ),
      Center(
        child: Text(
          '${design.prayerCardScale.toStringAsFixed(1)}x',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ],
  ),
),
```

- [ ] **Step 3: Add album mode to BackgroundSettingsSection**

In `background_settings_section.dart`, add a third `ButtonSegment` for album mode:

```dart
ButtonSegment(
  value: DisplayBackgroundType.album,
  label: Text(s.design_bg_type_album),
  icon: const Icon(Icons.photo_library_outlined),
),
```

When album is selected, show album URL management (add/remove/list) instead of the image picker or color picker. This requires adding `backgroundAlbumUrls` and callback parameters to the widget.

Add parameters:
```dart
final List<String> albumUrls;
final ValueChanged<String> onAlbumUrlAdded;
final void Function(int) onAlbumUrlRemoved;
```

When `settings.type == DisplayBackgroundType.album`, render a compact URL list with add button.

- [ ] **Step 4: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat: simplify GeneralSection, add prayer card scale + album background to DesignSection"
```

---

## Task 9: Restructure SettingsPage + SettingsDrawer (12→10 tabs)

**Files:**
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/settings/presentation/widgets/common/settings_drawer.dart`

- [ ] **Step 1: Update SettingsDrawer navigation items**

Replace the 12 navTile items with 10 reorganized items:

```dart
navTile(index: 0, icon: Icons.mosque_outlined, label: s.tab_general),
navTile(index: 1, icon: Icons.access_time_outlined, label: s.tab_prayer_iqama),
navTile(index: 2, icon: Icons.menu_book_rounded, label: s.tab_religious_content),
navTile(index: 3, icon: Icons.palette_outlined, label: s.tab_design),
navTile(index: 4, icon: Icons.photo_library_outlined, label: s.tab_photo_studio),
navTile(index: 5, icon: Icons.campaign_outlined, label: s.tab_announcements),
navTile(index: 6, icon: Icons.emergency_share_outlined, label: s.tab_alerts),
navTile(index: 7, icon: Icons.person_outline_rounded, label: s.tab_profile),
navTile(index: 8, icon: Icons.info_outline_rounded, label: s.tab_about),
navTile(index: 9, icon: Icons.system_update_rounded, label: s.tab_update),
```

- [ ] **Step 2: Update SettingsPage IndexedStack and title mapping**

Update the `_titleForIndex` method:
```dart
String _titleForIndex(S s, int i) {
  switch (i) {
    case 0: return s.tab_general;
    case 1: return s.tab_prayer_iqama;
    case 2: return s.tab_religious_content;
    case 3: return s.tab_design;
    case 4: return s.tab_photo_studio;
    case 5: return s.tab_announcements;
    case 6: return s.tab_alerts;
    case 7: return s.tab_profile;
    case 8: return s.tab_about;
    case 9: return s.tab_update;
    default: return s.settings_title;
  }
}
```

Update the `IndexedStack` children:
```dart
IndexedStack(
  index: _sectionIndex,
  sizing: StackFit.expand,
  children: [
    GeneralSection(mosque: mosque),            // 0
    PrayerIqamaSection(mosque: mosque),        // 1
    ReligiousContentSection(mosque: mosque),    // 2
    DesignSection(),                           // 3
    PhotoStudioSection(mosque: mosque),         // 4
    AnnouncementSection(mosque: mosque),        // 5
    AlertsSection(mosque: mosque),              // 6
    const ProfileSection(),                     // 7
    const AboutSection(),                      // 8
    const UpdateSection(),                     // 9
  ],
),
```

Update imports — add new sections, remove `iqama_section.dart` import (since it's now embedded in PrayerIqamaSection).

- [ ] **Step 3: Add missing l10n strings**

Check that the following strings exist in the l10n files. If not, add them:
- `tab_prayer_iqama` — "Prayer & Iqama" / "الصلاة والإقامة"
- `tab_religious_content` — "Religious Content" / "المحتوى الديني"
- `tab_photo_studio` — "Photo Studio" / "معرض الصور"
- `prayer_offsets_title` — "Prayer Time Offsets" / "تعديلات أوقات الصلاة"
- `display_timing_title` — "Display Timing" / "توقيت العرض"
- `pre_adhan_minutes` — "Minutes before Adhan" / "دقائق قبل الأذان"
- `adhan_moment_duration` — "Adhan duration (seconds)" / "مدة الأذان (ثواني)"
- `religious_content_timing` — "Content Timing" / "توقيت المحتوى"
- `religious_content_wait` — "Wait between content (seconds)" / "الانتظار بين المحتوى (ثواني)"
- `religious_content_display` — "Display duration (seconds)" / "مدة العرض (ثواني)"
- `photo_studio_empty` — "No photos added yet" / "لم تتم إضافة صور بعد"
- `photo_studio_add_url` — "Add Image URL" / "إضافة رابط صورة"
- `prayer_card_scale` — "Prayer Card Size" / "حجم بطاقات الصلاة"
- `design_bg_type_album` — "Album" / "ألبوم"
- `url` — "URL" / "رابط"
- `add` — "Add" / "إضافة"

Look in `lib/core/l10n/` for the arb files and add any missing keys.

- [ ] **Step 4: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat: restructure settings from 12 to 10 tabs with merged sections"
```

---

## Task 10: Apply prayer card scale to DisplayScreen + album background cycling

**Files:**
- Modify: `lib/features/display/presentation/display_screen.dart`
- Modify: `lib/features/display/presentation/widgets/background/display_background_image.dart`

- [ ] **Step 1: Apply prayer card scale in DisplayScreen**

Find where `PrayerCardsRow` is used in `display_screen.dart` and wrap it with `Transform.scale`:

```dart
Transform.scale(
  scale: mosque.designSettings.prayerCardScale,
  child: PrayerCardsRow(...),
)
```

- [ ] **Step 2: Add album cycling to DisplayBackgroundImage**

In `display_background_image.dart`, update to accept `albumUrls` parameter and implement cycling with crossfade:

Add parameters:
```dart
final List<String> albumUrls;
```

For the album branch, create a stateful widget or use `AnimatedSwitcher` with a timer to cycle through `albumUrls`. If `albumUrls` is empty, fall back to the fallback color.

The simplest approach: make `DisplayBackgroundImage` a `StatefulWidget` when in album mode, with a timer that increments the current index every 30 seconds.

- [ ] **Step 3: Update all callers of DisplayBackgroundImage**

Pass `mosque.backgroundAlbumUrls` to the widget wherever it's constructed.

- [ ] **Step 4: Run `flutter analyze`**

Expected: 0 errors

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "feat: apply prayer card scale to display, add album background cycling"
```

---

## Task 11: Final integration verification

**Files:**
- No files to modify

- [ ] **Step 1: Run `flutter analyze`**

```
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Expected: 0 errors, 0 warnings (info-level only)

- [ ] **Step 2: Search for any remaining gold references**

```
grep -ri "gold" lib/core/styles/ lib/features/settings/
grep -ri "remoteUrl" lib/
grep -ri "remote_url" lib/ --include="*.dart"
```

Fix any remaining references.

- [ ] **Step 3: Verify the build compiles**

```
flutter build apk --debug
```

Expected: APK builds successfully

- [ ] **Step 4: Commit any fixes**

```
git add -A
git commit -m "fix: clean up remaining gold/remoteUrl references"
```
