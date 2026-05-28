# Settings Feature Restructuring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the monolithic settings feature into feature-based subdirectories with independent BLoCs, add single save button + add shortcut to religious content.

**Architecture:** Each of the 10 settings tabs becomes an independent feature subfolder. The monolithic SettingsBloc (5 handler mixins, 43 events) is replaced with 7 independent feature BLoCs, each streaming the mosque model independently. File moves use `git mv` to preserve history.

**Tech Stack:** Flutter, flutter_bloc, GetIt DI, Firestore, go_router

---

### Task 1: Religious Content UI — Single Save + Add Shortcut

**Files:**
- Modify: `lib/features/settings/widgets/content_panel.dart`
- Modify: `lib/features/settings/presentation/sections/mosque_text_list_section.dart`
- Modify: `lib/features/settings/presentation/sections/religious_content_section.dart`

- [ ] **Step 1: Modify ContentPanel to add + icon shortcut**

Add `onAddPressed` callback. Show a small `+` IconButton next to the title in the ExpansionTile header:

```dart
import 'package:flutter/material.dart';

import '../../../core/styles/app_colors.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../presentation/sections/mosque_text_list_section.dart';

class ContentPanel extends StatelessWidget {
  final MosqueModel mosque;
  final MosqueTextListKind kind;
  final IconData icon;
  final String title;
  final ColorScheme scheme;
  final VoidCallback? onAddPressed;

  const ContentPanel({
    super.key,
    required this.mosque,
    required this.kind,
    required this.icon,
    required this.title,
    required this.scheme,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final items = mosque.listByKind(kind);
    final fullTitle = '$title (${items.length})';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Row(
          children: [
            Expanded(
              child: Text(
                fullTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onAddPressed != null)
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                  onPressed: onAddPressed,
                  tooltip: title,
                ),
              ),
          ],
        ),
        childrenPadding: EdgeInsets.zero,
        children: [
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

- [ ] **Step 2: Remove save bar + FAB from MosqueTextListSection**

In `mosque_text_list_section.dart`, remove these two UI elements:
1. The bottom save bar (`Container` with `FilledButton.icon` that calls `_save()`)
2. The `Positioned` FAB at the bottom-right

Also remove the `_save()` method.

The list should be a clean list-only view. Keep the `_openEditor()`, `_confirmDelete()`, item list, and empty state. Remove the `Stack` wrapper (no longer needed without FAB), change to just `Column`. Update padding from `fromLTRB(16, 12, 16, 100)` to `fromLTRB(16, 12, 16, 16)`.

- [ ] **Step 3: Wire add callbacks in ReligiousContentSection**

Update ReligiousContentSection to:
1. Pass `onAddPressed` to each `ContentPanel` that opens the editor for that kind
2. Replace the existing save button to save ALL kinds (hadiths, verses, duas, adhkar) + timing

```dart
// In ReligiousContentSection.build():

// Helper to open editor for a specific kind
void openEditor(MosqueTextListKind kind) {
  final bloc = context.read<SettingsBloc>();
  final s = S.of(context);
  final labels = MosqueTextL10n.of(s, kind);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => MosqueTextEditorSheet(
      existing: null,
      bloc: bloc,
      kind: kind,
      labels: labels,
    ),
  );
}

// Each ContentPanel gets onAddPressed:
ContentPanel(
  mosque: mosque,
  kind: MosqueTextListKind.hadith,
  icon: Icons.menu_book_rounded,
  title: s.tab_hadith,
  scheme: scheme,
  onAddPressed: () => openEditor(MosqueTextListKind.hadith),
),
// ... same for verse, dua, adhkar

// Replace save button to save all kinds + timing:
ElevatedButton.icon(
  onPressed: () {
    bloc.add(const SaveDesignSettingsRequested());
    for (final kind in MosqueTextListKind.values) {
      bloc.add(SaveMosqueTextListRequested(kind));
    }
  },
  icon: const Icon(Icons.cloud_upload_rounded),
  label: Text(s.save),
  // ... style
),
```

Add import for `MosqueTextEditorSheet` and `MosqueTextL10n` at the top.

- [ ] **Step 4: Verify and commit**

Run: `cd "C:\Users\Mounir\Documents\FlutterProject\mosques" && flutter analyze`
Expected: 0 issues

```bash
git add lib/features/settings/widgets/content_panel.dart lib/features/settings/presentation/sections/mosque_text_list_section.dart lib/features/settings/presentation/sections/religious_content_section.dart
git commit -m "feat(settings): single save button + add shortcut for religious content"
```

---

### Task 2: Create Directory Structure + git mv All Files

**Files:**
- Move: 55+ files via `git mv`
- Delete: `presentation/sections/iqama_section.dart`, `presentation/sections/photo_studio_section.dart` (dead code)

- [ ] **Step 1: Create all target directories**

```bash
cd "C:\Users\Mounir\Documents\FlutterProject\mosques\lib\features\settings"

# Core shared
mkdir -p core/widgets core/models

# Feature directories
mkdir -p general/presentation
mkdir -p iqama/presentation
mkdir -p religious_content/presentation religious_content/widgets
mkdir -p design/presentation design/widgets
mkdir -p album/presentation
mkdir -p announcements/presentation announcements/widgets
mkdir -p alerts/presentation alerts/widgets
mkdir -p profile/bloc profile/presentation profile/widgets
mkdir -p about/presentation about/widgets
mkdir -p update/bloc update/presentation
```

- [ ] **Step 2: git mv shared/core files**

```bash
cd "C:\Users\Mounir\Documents\FlutterProject\mosques"

# Core widgets (from widgets/common/)
git mv lib/features/settings/widgets/common/settings_app_bar.dart lib/features/settings/core/widgets/
git mv lib/features/settings/widgets/common/settings_zoom_drawer_content.dart lib/features/settings/core/widgets/
git mv lib/features/settings/widgets/common/drawer_nav_tile.dart lib/features/settings/core/widgets/
git mv lib/features/settings/widgets/common/common_widgets.dart lib/features/settings/core/widgets/
git mv lib/features/settings/widgets/common/offset_stepper_field.dart lib/features/settings/core/widgets/

# Core models
git mv lib/features/settings/models/settings_edit_request.dart lib/features/settings/core/models/
```

- [ ] **Step 3: git mv feature section + widget files**

```bash
cd "C:\Users\Mounir\Documents\FlutterProject\mosques"

# General (tab 0)
git mv lib/features/settings/presentation/sections/general_section.dart lib/features/settings/general/presentation/

# Iqama (tab 1)
git mv lib/features/settings/presentation/sections/prayer_iqama_section.dart lib/features/settings/iqama/presentation/

# Religious Content (tab 2)
git mv lib/features/settings/presentation/sections/religious_content_section.dart lib/features/settings/religious_content/presentation/
git mv lib/features/settings/widgets/content_panel.dart lib/features/settings/religious_content/widgets/
git mv lib/features/settings/presentation/sections/mosque_text_list_section.dart lib/features/settings/religious_content/widgets/
git mv lib/features/settings/widgets/mosque_text_editor_sheet.dart lib/features/settings/religious_content/widgets/

# Design (tab 3)
git mv lib/features/settings/presentation/sections/design_section.dart lib/features/settings/design/presentation/
git mv lib/features/settings/widgets/design/design_card.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/design_font_size_item.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/design_widgets.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/album_url_list.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/background_settings_section.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/behavior_settings_section.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/color_settings_section.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/design_color_item.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/display_background_picker.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/font_browser_dialog.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/font_size_settings_section.dart lib/features/settings/design/widgets/
git mv lib/features/settings/widgets/design/typography_settings_section.dart lib/features/settings/design/widgets/

# Album (tab 4)
git mv lib/features/settings/presentation/sections/album_section.dart lib/features/settings/album/presentation/

# Announcements (tab 5)
git mv lib/features/settings/presentation/sections/announcement_section.dart lib/features/settings/announcements/presentation/
git mv lib/features/settings/widgets/announcement_editor_sheet.dart lib/features/settings/announcements/widgets/

# Alerts (tab 6)
git mv lib/features/settings/presentation/sections/alerts_section.dart lib/features/settings/alerts/presentation/
git mv lib/features/settings/widgets/alert_card.dart lib/features/settings/alerts/widgets/
git mv lib/features/settings/widgets/alert_edit_dialog.dart lib/features/settings/alerts/widgets/

# Profile (tab 7)
git mv lib/features/settings/bloc/profile/profile_bloc.dart lib/features/settings/profile/bloc/
git mv lib/features/settings/bloc/profile/profile_event.dart lib/features/settings/profile/bloc/
git mv lib/features/settings/bloc/profile/profile_state.dart lib/features/settings/profile/bloc/
git mv lib/features/settings/presentation/sections/profile_section.dart lib/features/settings/profile/presentation/
git mv lib/features/settings/widgets/profile/profile_widgets.dart lib/features/settings/profile/widgets/
git mv lib/features/settings/widgets/profile/profile_action_card.dart lib/features/settings/profile/widgets/
git mv lib/features/settings/widgets/profile/profile_info_card.dart lib/features/settings/profile/widgets/
git mv lib/features/settings/widgets/profile/profile_phone_card.dart lib/features/settings/profile/widgets/

# About (tab 8)
git mv lib/features/settings/presentation/sections/about_section.dart lib/features/settings/about/presentation/
git mv lib/features/settings/widgets/about/about_widgets.dart lib/features/settings/about/widgets/
git mv lib/features/settings/widgets/about/about_category_view.dart lib/features/settings/about/widgets/
git mv lib/features/settings/widgets/about/about_empty_state.dart lib/features/settings/about/widgets/
git mv lib/features/settings/widgets/about/about_item_view.dart lib/features/settings/about/widgets/

# Update (tab 9)
git mv lib/features/settings/bloc/update/update_bloc.dart lib/features/settings/update/bloc/
git mv lib/features/settings/bloc/update/update_event.dart lib/features/settings/update/bloc/
git mv lib/features/settings/bloc/update/update_state.dart lib/features/settings/update/bloc/
git mv lib/features/settings/presentation/sections/update_section.dart lib/features/settings/update/presentation/
```

- [ ] **Step 4: Delete dead files + commit**

```bash
git rm lib/features/settings/presentation/sections/iqama_section.dart
git rm lib/features/settings/presentation/sections/photo_studio_section.dart
```

Commit: `git commit -m "refactor(settings): restructure into feature-based directories via git mv"`

Note: Imports will be broken at this point. That is expected and will be fixed in Task 3.

---

### Task 3: Fix All Import Paths

**Files:**
- Modify: Every moved file (update relative imports)
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/settings/settings.dart`

- [ ] **Step 1: Fix imports in all moved files**

For every file that was moved, update its relative imports to reflect the new directory structure. The general pattern:

**Core widgets** (moved from `widgets/common/` to `core/widgets/`):
- Internal references between core widgets: adjust from `./` siblings
- References to external code (core/styles, data/models): recalculate `../` depth

**Feature presentation files** (moved from `presentation/sections/` to `<feature>/presentation/`):
- Old: `../../bloc/settings/settings_bloc.dart` → New: depends on feature location
- Old: `../../widgets/common/common_widgets.dart` → New: `../../../core/widgets/common_widgets.dart` (if 1 level deeper) or adjust based on actual depth
- References to `../../../../core/` paths: add one more `../` since features are one level deeper

**Feature widget files** (moved from `widgets/` to `<feature>/widgets/`):
- Similar pattern: recalculate all relative import depths

The key rule: count the directory levels from the new file location to the target file location and construct the correct `../` chain.

For each file, read its current content, identify all import statements, recalculate the relative path from the new location, and update.

- [ ] **Step 2: Fix settings_page.dart imports**

Update imports to reference new feature locations:

```dart
// Old section imports:
import 'sections/general_section.dart';
// New:
import '../general/presentation/general_section.dart';

// Old widget imports:
import 'widgets/common/settings_zoom_drawer_content.dart';
// New:
import '../core/widgets/settings_zoom_drawer_content.dart';
```

Full import list for settings_page.dart:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/navigation/zoom_drawer.dart';
import '../bloc/settings/settings_bloc.dart';
import '../core/widgets/settings_zoom_drawer_content.dart';
import '../core/widgets/settings_app_bar.dart';

import '../general/presentation/general_section.dart';
import '../iqama/presentation/prayer_iqama_section.dart';
import '../religious_content/presentation/religious_content_section.dart';
import '../design/presentation/design_section.dart';
import '../album/presentation/album_section.dart';
import '../announcements/presentation/announcement_section.dart';
import '../alerts/presentation/alerts_section.dart';
import '../profile/presentation/profile_section.dart';
import '../about/presentation/about_section.dart';
import '../update/presentation/update_section.dart';
```

- [ ] **Step 3: Fix barrel file**

```dart
// settings.dart
export 'bloc/settings/settings_bloc.dart';
export 'bloc/settings/settings_event.dart';
export 'bloc/settings/settings_state.dart';
export 'profile/bloc/profile_bloc.dart';
export 'update/bloc/update_bloc.dart';
export 'presentation/settings_page.dart';
```

- [ ] **Step 4: Verify and commit**

Run: `flutter analyze`
Expected: 0 issues

Fix any remaining import issues found by the analyzer.

```bash
git add -A
git commit -m "refactor(settings): fix all import paths after directory restructuring"
```

---

### Task 4: Create Feature BLoCs — General, Iqama, ReligiousContent

**Files:**
- Create: `lib/features/settings/general/bloc/general_bloc.dart`
- Create: `lib/features/settings/general/bloc/general_event.dart`
- Create: `lib/features/settings/general/bloc/general_state.dart`
- Create: `lib/features/settings/iqama/bloc/iqama_bloc.dart`
- Create: `lib/features/settings/iqama/bloc/iqama_event.dart`
- Create: `lib/features/settings/iqama/bloc/iqama_state.dart`
- Create: `lib/features/settings/religious_content/bloc/religious_content_bloc.dart`
- Create: `lib/features/settings/religious_content/bloc/religious_content_event.dart`
- Create: `lib/features/settings/religious_content/bloc/religious_content_state.dart`
- Modify: `lib/features/settings/general/presentation/general_section.dart`
- Modify: `lib/features/settings/iqama/presentation/prayer_iqama_section.dart`
- Modify: `lib/features/settings/religious_content/presentation/religious_content_section.dart`
- Modify: `lib/features/settings/religious_content/widgets/mosque_text_list_section.dart`

- [ ] **Step 1: Create base state pattern**

Each feature BLoC state follows this pattern:

```dart
import 'package:equatable/equatable.dart';
import '../../../../data/models/mosque/mosque_model.dart';

class XState extends Equatable {
  final MosqueModel? mosque;
  final bool isLoading;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final String? error;

  const XState({
    this.mosque,
    this.isLoading = false,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  XState copyWith({...}) { ... }

  @override
  List<Object?> get props => [mosque, isLoading, isSaving, hasUnsavedChanges, error];
}
```

- [ ] **Step 2: Create GeneralBloc**

Extract logic from `GeneralSettingsHandler` into standalone BLoC:

**general_event.dart**: Move `GeneralField`, `PrayerOffsetField` enums + event classes:
`LoadGeneral`, `GeneralSettingChanged`, `LanguageChanged`, `CoordinatesChanged`, `PrayerOffsetChanged`, `SaveGeneralRequested`, `_MosqueUpdated` (internal)

**general_state.dart**: Standard feature state with `mosque`, `isLoading`, `isSaving`, `hasUnsavedChanges`, `error`

**general_bloc.dart**:
- Constructor takes `IMosqueRepository`
- `_onLoad`: subscribes to `_repo.streamActiveMosque`
- Handlers: same logic as `GeneralSettingsHandler` but using `emit(state.copyWith(mosque: updated, hasUnsavedChanges: true))` instead of `emitDraftUpdated`
- `_onSave`: calls `_repo.updateMosque(state.mosque!)`

- [ ] **Step 3: Create IqamaBloc**

Extract from `IqamaSettingsHandler`:

**iqama_event.dart**: Move `IqamaField` enum + `LoadIqama`, `IqamaOffsetChanged`, `SaveIqamaRequested`, `_MosqueUpdated`

**iqama_state.dart**: Standard feature state

**iqama_bloc.dart**:
- Streams mosque, handles `IqamaOffsetChanged` (same logic as handler)
- Save calls `_repo.updateIqamaSettings(state.mosque!)`

- [ ] **Step 4: Create ReligiousContentBloc**

Extract from `MosqueTextHandler` + timing events from `DesignSettingsHandler`:

**religious_content_event.dart**: `LoadReligiousContent`, `MosqueTextAdded`, `MosqueTextUpdated`, `MosqueTextRemoved`, `ReligiousContentTimingChanged` (replaces `DisplayTimingChanged` for religious-specific fields), `SaveAllReligiousContentRequested`, `_MosqueUpdated`

Keep `DisplayTimingField` enum for `religiousContentWait` and `religiousContentDisplay` only.

**religious_content_state.dart**: Standard feature state

**religious_content_bloc.dart**:
- Streams mosque
- CRUD handlers from `MosqueTextHandler` (`_mosqueWithTextList` helper, add/update/remove)
- Timing handlers for `religiousContentWait` and `religiousContentDisplay` (from `DesignSettingsHandler.onDisplayTimingChanged`)
- `_onSaveAll`: saves all 4 text kinds + design settings:
```dart
Future<void> _onSaveAll(SaveAllReligiousContentRequested event, Emitter emit) async {
  final m = state.mosque;
  if (m == null) return;
  emit(state.copyWith(isSaving: true));
  try {
    for (final kind in MosqueTextListKind.values) {
      await _repo.updateMosqueTextList(m, kind);
    }
    await _repo.updateDesignSettings(m);
    emit(state.copyWith(isSaving: false, hasUnsavedChanges: false, error: null));
  } catch (e) {
    emit(state.copyWith(isSaving: false, error: e.toString()));
  }
}
```

- [ ] **Step 5: Update GeneralSection to use GeneralBloc**

Wrap `GeneralSection` in its own `BlocProvider<GeneralBloc>`:
```dart
class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GeneralBloc(mosqueRepository: sl<IMosqueRepository>())..add(const LoadGeneral()),
      child: const _GeneralSectionBody(),
    );
  }
}
```
Remove `mosque` parameter. Use `BlocBuilder<GeneralBloc, GeneralState>` to get mosque from bloc state. Replace `context.read<SettingsBloc>().add(...)` with `context.read<GeneralBloc>().add(...)`.

- [ ] **Step 6: Update PrayerIqamaSection similarly**

Remove `mosque` param. Add local `BlocProvider<IqamaBloc>`. Use `BlocBuilder<IqamaBloc, IqamaState>`.

- [ ] **Step 7: Update ReligiousContentSection + MosqueTextListSection**

ReligiousContentSection: Remove `mosque` param. Add local `BlocProvider<ReligiousContentBloc>`. Replace the save button to use `SaveAllReligiousContentRequested`. Fix add callbacks to use ReligiousContentBloc.

MosqueTextListSection: Change `context.read<SettingsBloc>()` to `context.read<ReligiousContentBloc>()` for all event dispatches.

- [ ] **Step 8: Verify and commit**

Run: `flutter analyze`
```bash
git add -A
git commit -m "feat(settings): create GeneralBloc, IqamaBloc, ReligiousContentBloc"
```

---

### Task 5: Create Feature BLoCs — Design, Album

**Files:**
- Create: `lib/features/settings/design/bloc/design_bloc.dart`
- Create: `lib/features/settings/design/bloc/design_event.dart`
- Create: `lib/features/settings/design/bloc/design_state.dart`
- Create: `lib/features/settings/album/bloc/album_bloc.dart`
- Create: `lib/features/settings/album/bloc/album_event.dart`
- Create: `lib/features/settings/album/bloc/album_state.dart`
- Modify: `lib/features/settings/design/presentation/design_section.dart`
- Modify: `lib/features/settings/album/presentation/album_section.dart`

- [ ] **Step 1: Create DesignBloc**

Extract design portion from `DesignSettingsHandler`:

**design_event.dart**: Move enums `DesignColorField`, `DesignFontSizeField`, `DisplayTimingField` (only preAdhanMinutes, adhanMomentDuration). Events: `LoadDesign`, background events, color events, font size events, ticker/strip speed, numeral format, font family, prayer card scale, background album url events, `SaveDesignRequested`, `_MosqueUpdated`

**design_bloc.dart**: All design handler methods. Save calls `_repo.updateDesignSettings(state.mosque!)`.

- [ ] **Step 2: Create AlbumBloc**

Extract album portion from `DesignSettingsHandler`:

**album_event.dart**: `LoadAlbum`, `AlbumImageAdded`, `AlbumImageRemoved`, `AlbumImagePublished`, `AlbumImageUnpublished`, `SaveAlbumRequested`, `_MosqueUpdated`

**album_bloc.dart**: Album add/remove/publish/unpublish handlers. Save calls `_repo.updateMosque(state.mosque!)`.

- [ ] **Step 3: Update DesignSection**

Remove `SettingsBloc` dependency. Wrap in `BlocProvider<DesignBloc>`. Use `BlocBuilder<DesignBloc, DesignState>`.

- [ ] **Step 4: Update AlbumSection**

Remove `mosque` param. Wrap in `BlocProvider<AlbumBloc>`. Use `BlocBuilder<AlbumBloc, AlbumState>`.

- [ ] **Step 5: Verify and commit**

Run: `flutter analyze`
```bash
git add -A
git commit -m "feat(settings): create DesignBloc, AlbumBloc"
```

---

### Task 6: Create Feature BLoCs — Announcements, Alerts

**Files:**
- Create: `lib/features/settings/announcements/bloc/announcements_bloc.dart`
- Create: `lib/features/settings/announcements/bloc/announcements_event.dart`
- Create: `lib/features/settings/announcements/bloc/announcements_state.dart`
- Create: `lib/features/settings/alerts/bloc/alerts_bloc.dart`
- Create: `lib/features/settings/alerts/bloc/alerts_event.dart`
- Create: `lib/features/settings/alerts/bloc/alerts_state.dart`
- Modify: `lib/features/settings/announcements/presentation/announcement_section.dart`
- Modify: `lib/features/settings/alerts/presentation/alerts_section.dart`

- [ ] **Step 1: Create AnnouncementsBloc**

Extract announcement portion from `AnnouncementHandler`:

**announcements_event.dart**: `LoadAnnouncements`, `AnnouncementAdded`, `AnnouncementUpdated`, `AnnouncementRemoved`, `SaveAnnouncementsRequested`, `_MosqueUpdated`

**announcements_bloc.dart**: Add/update/remove handlers. Save calls `_repo.updateAnnouncements(state.mosque!)`.

- [ ] **Step 2: Create AlertsBloc**

Extract alerts portion from `AnnouncementHandler`:

**alerts_event.dart**: `LoadAlerts`, `AlertAdded`, `AlertRemoved`, `AlertPublished`, `AlertUnpublished`, `AlertUpdated`, `AllAlertsDeleted`, `SaveAlertsRequested`, `_MosqueUpdated`

**alerts_bloc.dart**: All alert handlers. Save calls `_repo.updateActiveAlerts(state.mosque!)`.

- [ ] **Step 3: Update AnnouncementSection + AlertsSection**

Same pattern: remove `mosque` param, add local `BlocProvider`, use feature BLoC.

Also update `announcement_editor_sheet.dart` and `alert_card.dart` / `alert_edit_dialog.dart` to use the correct BLoC type.

- [ ] **Step 4: Verify and commit**

Run: `flutter analyze`
```bash
git add -A
git commit -m "feat(settings): create AnnouncementsBloc, AlertsBloc"
```

---

### Task 7: Update SettingsPage + Remove Old SettingsBloc

**Files:**
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/settings/settings.dart`
- Delete: `lib/features/settings/bloc/settings/settings_bloc.dart`
- Delete: `lib/features/settings/bloc/settings/settings_event.dart`
- Delete: `lib/features/settings/bloc/settings/settings_state.dart`
- Delete: `lib/features/settings/bloc/settings/handlers/general_settings_handler.dart`
- Delete: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`
- Delete: `lib/features/settings/bloc/settings/handlers/iqama_settings_handler.dart`
- Delete: `lib/features/settings/bloc/settings/handlers/mosque_text_handler.dart`
- Delete: `lib/features/settings/bloc/settings/handlers/announcement_handler.dart`
- Delete: `lib/features/settings/core/models/settings_edit_request.dart`

- [ ] **Step 1: Rewrite SettingsPage**

SettingsPage becomes a lightweight shell. Since each section now provides its own BLoC, the page just needs:
1. A way to get the mosque name for the AppBar (stream it directly or use any feature BLoc)
2. The drawer + IndexedStack

Use a lightweight approach: stream the mosque name from the repository directly in the page, or create a minimal SettingsShellCubit that only streams the mosque name for the AppBar.

Simplest approach: use a `StreamBuilder` on `sl<IMosqueRepository>().streamActiveMosque` for the mosque name:

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}

class SettingsScreen extends StatefulWidget { ... }

class _SettingsScreenState extends State<SettingsScreen> {
  int _sectionIndex = 0;
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MosqueModel?>(
      stream: sl<IMosqueRepository>().streamActiveMosque,
      builder: (context, snapshot) {
        final mosqueName = snapshot.data?.name ?? '';
        
        return ZoomDrawer(
          controller: _drawerController,
          menuScreen: SettingsZoomDrawerContent(...),
          mainScreen: Scaffold(
            appBar: SettingsAppBar(
              sectionIndex: _sectionIndex,
              mosqueName: mosqueName,
              ...
            ),
            body: IndexedStack(
              index: _sectionIndex,
              sizing: StackFit.expand,
              children: const [
                GeneralSection(),          // 0
                PrayerIqamaSection(),      // 1
                ReligiousContentSection(), // 2
                DesignSection(),           // 3
                AlbumSection(),            // 4
                AnnouncementSection(),     // 5
                AlertsSection(),           // 6
                ProfileSection(),          // 7
                AboutSection(),            // 8
                UpdateSection(),           // 9
              ],
            ),
          ),
        );
      },
    );
  }
}
```

Remove all SettingsBloc references. Remove BlocProvider/BlocConsumer. Remove loading/error handling from page (each section handles its own).

- [ ] **Step 2: Delete old SettingsBloc files**

```bash
git rm lib/features/settings/bloc/settings/settings_bloc.dart
git rm lib/features/settings/bloc/settings/settings_event.dart
git rm lib/features/settings/bloc/settings/settings_state.dart
git rm lib/features/settings/bloc/settings/handlers/general_settings_handler.dart
git rm lib/features/settings/bloc/settings/handlers/design_settings_handler.dart
git rm lib/features/settings/bloc/settings/handlers/iqama_settings_handler.dart
git rm lib/features/settings/bloc/settings/handlers/mosque_text_handler.dart
git rm lib/features/settings/bloc/settings/handlers/announcement_handler.dart
git rm lib/features/settings/core/models/settings_edit_request.dart
```

- [ ] **Step 3: Update barrel file**

```dart
// settings.dart — export feature BLoCs + page
export 'general/bloc/general_bloc.dart';
export 'iqama/bloc/iqama_bloc.dart';
export 'religious_content/bloc/religious_content_bloc.dart';
export 'design/bloc/design_bloc.dart';
export 'album/bloc/album_bloc.dart';
export 'announcements/bloc/announcements_bloc.dart';
export 'alerts/bloc/alerts_bloc.dart';
export 'profile/bloc/profile_bloc.dart';
export 'update/bloc/update_bloc.dart';
export 'presentation/settings_page.dart';
```

- [ ] **Step 4: Fix external imports**

Check `lib/core/routes/app_pages.dart` — it imports `../../features/settings/settings.dart`. This should still work if barrel exports are correct.

Search entire codebase for any other imports of old settings paths and fix them.

- [ ] **Step 5: Clean up empty directories**

Remove any now-empty directories:
```bash
# These should be empty after git rm:
rmdir lib/features/settings/bloc/settings/handlers
rmdir lib/features/settings/bloc/settings
rmdir lib/features/settings/bloc/profile
rmdir lib/features/settings/bloc/update
rmdir lib/features/settings/bloc
rmdir lib/features/settings/models
rmdir lib/features/settings/widgets/common
rmdir lib/features/settings/widgets/design
rmdir lib/features/settings/widgets/profile
rmdir lib/features/settings/widgets/about
rmdir lib/features/settings/widgets
rmdir lib/features/settings/presentation/sections
```

- [ ] **Step 6: Verify and commit**

Run: `flutter analyze`
Expected: 0 issues

```bash
git add -A
git commit -m "refactor(settings): remove monolithic SettingsBloc, update SettingsPage to lightweight shell"
```

---

### Task 8: Final Verification

**Files:** None (verification only)

- [ ] **Step 1: Run flutter analyze**

```bash
cd "C:\Users\Mounir\Documents\FlutterProject\mosques" && flutter analyze
```
Expected: 0 issues

- [ ] **Step 2: Run flutter build web**

```bash
flutter build web --no-tree-shake-icons
```
Expected: Build succeeds

- [ ] **Step 3: Verify directory structure**

```bash
find lib/features/settings -type f -name "*.dart" | sort
```

Expected: All files in feature-based structure, no files in old locations.

- [ ] **Step 4: Verify no old imports remain**

```bash
grep -r "bloc/settings/settings_bloc" lib/ || echo "No old imports found"
grep -r "presentation/sections/" lib/features/settings/ || echo "No old section paths"
grep -r "widgets/common/" lib/features/settings/ || echo "No old widget paths"
```

- [ ] **Step 5: Final commit if any fixes needed**

```bash
git add -A
git commit -m "chore: final verification after settings restructuring"
```
