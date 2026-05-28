# Settings Feature Restructuring Design Spec

**Date:** 2026-05-28

## Goals

1. **Religious Content UI**: Single external save button for all 4 text lists + add shortcut icon in panel headers
2. **Directory Restructuring**: Split monolithic `settings/` into feature-based subdirectories using `git mv`
3. **BLoC Splitting**: Replace single SettingsBloc (43 events, 5 handler mixins) with 7 independent feature BLoCs

## 1. Religious Content UI Changes

### Current
- `MosqueTextListSection` has its own save button (`SaveMosqueTextListRequested(kind)`) + FAB per list
- `ContentPanel` is a simple ExpansionTile wrapper
- `ReligiousContentSection` has a save button that only saves timing via `SaveDesignSettingsRequested()`

### Target
- **Remove** per-list save button and FAB from `MosqueTextListSection`
- **Add** `onAddPressed` callback to `ContentPanel` — renders a small `+` IconButton in the ExpansionTile title row
- **Single save button** in `ReligiousContentSection` saves ALL 4 kinds + timing in one action
- `MosqueTextListSection` becomes a pure display/edit list (no save/add UI)

## 2. Directory Structure

### Current (60 files in flat structure)
```
settings/
├── bloc/ (profile/, settings/ with 5 handlers, update/)
├── models/
├── presentation/ (settings_page + 12 section files)
├── widgets/ (about/, common/, design/, profile/ + loose files)
└── settings.dart
```

### Target (feature-based)
```
settings/
├── core/widgets/     (5 shared widgets: app_bar, drawer, nav_tile, common, stepper)
├── core/models/      (settings_edit_request.dart)
├── general/          (bloc/ + presentation/)
├── iqama/            (bloc/ + presentation/)
├── religious_content/ (bloc/ + presentation/ + widgets/)
├── design/           (bloc/ + presentation/ + widgets/)
├── album/            (bloc/ + presentation/)
├── announcements/    (bloc/ + presentation/ + widgets/)
├── alerts/           (bloc/ + presentation/ + widgets/)
├── profile/          (bloc/ + presentation/ + widgets/)
├── about/            (presentation/ + widgets/)
├── update/           (bloc/ + presentation/)
├── presentation/     (settings_page.dart — orchestrator)
└── settings.dart     (barrel)
```

### File Movement Rules
- Use `git mv` exclusively (preserves history)
- Dead files deleted: `iqama_section.dart`, `photo_studio_section.dart`
- All imports updated after moves

## 3. BLoC Architecture

### Current: Monolithic SettingsBloc
- Single `SettingsState` with `SettingsEditRequest` wrapping `MosqueModel`
- 5 handler mixins: General, Design, Iqama, MosqueText, Announcement
- 43 events, single `_save()` helper

### Target: 7 Independent Feature BLoCs

Each BLoC follows this pattern:
- Streams `MosqueModel` from `IMosqueRepository.streamActiveMosque`
- Has its own State class with `mosque`, `isLoading`, `isSaving`, `error`
- Has its own sealed Event class with domain-specific events + Save
- Calls feature-specific repo method for persistence
- Each section provides its own BLoC via local `BlocProvider` (like existing ProfileBloc pattern)

| BLoC | Source Handler | Repo Method |
|------|---------------|-------------|
| GeneralBloc | GeneralSettingsHandler | `updateMosque()` |
| IqamaBloc | IqamaSettingsHandler | `updateIqamaSettings()` |
| ReligiousContentBloc | MosqueTextHandler | `updateMosqueTextList()` |
| DesignBloc | DesignSettingsHandler (design) | `updateDesignSettings()` |
| AlbumBloc | DesignSettingsHandler (album) | `updateMosque()` |
| AnnouncementsBloc | AnnouncementHandler (announcements) | `updateAnnouncements()` |
| AlertsBloc | AnnouncementHandler (alerts) | `updateActiveAlerts()` |

### SettingsPage Changes
- Remove single `BlocProvider<SettingsBloc>`
- Each section wraps itself in `BlocProvider` for its feature BLoc
- SettingsPage becomes a lightweight shell (drawer + IndexedStack + loading from any feature)
- Save/error snackbars handled locally in each section

### Shared State Coordination
- No coordinator needed — each BLoC independently streams the same Firestore document
- Repository's `streamActiveMosque` is a broadcast stream (multiple subscriptions safe)
- Feature-specific save methods update only their domain fields
- Firestore merge semantics prevent overwriting other features' data

## Constraints
- `git mv` only for file moves (preserve git history)
- No functional behavior changes (only structural refactoring)
- `flutter analyze` must pass after every commit
- Existing tests (if any) must continue passing
