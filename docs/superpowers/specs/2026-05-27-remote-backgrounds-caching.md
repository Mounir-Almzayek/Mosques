# Remote Backgrounds, Image Caching & Album UX

## Goal

Replace hardcoded background image assets with remote images fetched from `backgroundFolderUrl`, improve album management UX in settings, add `cached_network_image` for offline-friendly image caching, and delete the 12 bundled `mosque_display_*.jpg` files to reduce app size.

## Architecture

Four workstreams:

1. **Remote Background Library** — Use `backgroundFolderUrl` from AppSettings to provide a library of remote background images. The `DisplayBackgroundPreset` enum is removed. The "image" background type now stores a remote URL instead of a preset asset ID. The `DisplayBackgroundPicker` fetches image list from the folder URL.
2. **Image Caching** — Add `cached_network_image` package. Replace all `Image.network()` calls with `CachedNetworkImage` (display background, album cycling, photo studio, settings thumbnails). This gives disk caching, offline support, placeholder/error widgets.
3. **Album UX Improvement** — Redesign `AlbumUrlList` from a plain list of URLs to a visual grid with image previews, add/remove capability, and better empty state.
4. **Asset Cleanup** — Delete all 12 `assets/display_backgrounds/mosque_display_*.jpg` files, remove `DisplayBackgroundPreset` enum, update pubspec.yaml to remove the `assets/display_backgrounds/` directory entry.

## Tech Stack

Flutter 3.10+, `cached_network_image` (new dependency), flutter_bloc, Equatable.

---

## 1. Remote Background Library

### Concept

The `backgroundFolderUrl` in AppSettings points to a folder/API that returns a JSON list of image URLs. The display screen uses these URLs instead of bundled assets.

### Data Flow

- `AppSettingsModel.backgroundFolderUrl` → a URL like `https://example.com/backgrounds/` or a direct JSON endpoint
- A new service/utility fetches the list of available background image URLs from this folder
- `DisplayBackgroundPicker` shows these remote images as selectable options (with caching)
- When user selects one, stores the full URL as `background_value` in Firestore
- `DisplayBackgroundImage` renders the selected URL using `CachedNetworkImage`

### Model Changes

- `DisplayBackgroundType.image` now means "remote image URL" (no more asset presets)
- `DesignBackgroundSettings.value` stores a full URL when type is `image`
- Need a `BackgroundLibraryRepository` or utility to fetch available images from `backgroundFolderUrl`

### Backward Compatibility

- If `background_value` contains an old preset ID (like `mosque_display_01`), treat it as fallback (show solid color or first available remote image)
- The `fromStorageId` pattern is removed since we no longer have local presets

---

## 2. Image Caching

### Package

`cached_network_image: ^3.4.1` — provides:
- Disk + memory caching
- Offline support (previously cached images load without network)
- Placeholder and error widgets
- Fade-in animation

### Files to Update

- `display_background_image.dart` — Replace `Image.network` with `CachedNetworkImage` for album cycling and single URL backgrounds
- `album_url_list.dart` — Replace `Image.network` thumbnails with `CachedNetworkImage`
- `photo_studio_section.dart` — Replace `Image.network` thumbnails with `CachedNetworkImage`
- `photo_studio_layer.dart` — If it uses `Image.network`, replace with `CachedNetworkImage`
- `display_background_picker.dart` — Now shows remote images, use `CachedNetworkImage`

### Shared Widget

Create `lib/core/widgets/media/cached_image.dart` — a thin wrapper around `CachedNetworkImage` with app-consistent placeholder/error styling.

---

## 3. Album UX Improvement

### Current State

`AlbumUrlList` is a basic list of URL strings with tiny 40x40 thumbnails and raw URL text.

### New Design

Replace with a visual grid:
- Grid of cached image thumbnails (aspect ratio ~16:9 or 4:3)
- Each image has a delete button overlay (top-right X)
- "Add image URL" card at the end with + icon
- Empty state: centered icon + text + add button
- Smooth animations on add/remove

---

## 4. Asset Cleanup

### Files to Delete

All 12 files in `assets/display_backgrounds/`:
- `mosque_display_primary.jpg`
- `mosque_display_01.jpg` through `mosque_display_11.jpg`

### Code to Remove/Update

- Delete `lib/core/enums/display_background_preset.dart`
- Update `pubspec.yaml`: remove `- assets/display_backgrounds/` line
- Update `display_background_image.dart`: remove all preset-related code
- Update `display_screen.dart`: remove `_precacheBackgrounds` method (no longer needed for local assets)
- Update any barrel files that export `display_background_preset.dart`

---

## Non-Goals

- No changes to BLoC architecture patterns
- No changes to color/album background type behavior
- No new Firestore schema (backgroundFolderUrl already exists)
- Hadiths and instant alerts are NOT part of this scope
