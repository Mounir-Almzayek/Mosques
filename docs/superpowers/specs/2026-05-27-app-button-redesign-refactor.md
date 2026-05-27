# AppButton + Splash/Login Redesign + ZoomDrawer + Widget Refactor

## Goal

Create a unified AppButton widget, redesign splash/login screens, implement ZoomDrawer (from visitors project pattern), clean up logo assets, and refactor all inline function-widgets into proper classes in separate files.

## Architecture

Five workstreams, each independently shippable:

1. **AppButton** — three-variant button (elevated/outlined/text) with loading, disabled, icon support. Replaces all `CustomElevatedButton` and ad-hoc `TextButton` usages.
2. **Logo cleanup** — delete `logo.jpg`, ensure all references point to `logo.png`, verify launcher icon config.
3. **Splash & Login redesign** — modern, polished screens using the teal-green `#384c4b` palette, `logo.png` as centerpiece, smooth entrance animations.
4. **ZoomDrawer** — slide-and-scale drawer (inspired by visitors project) replacing the current `Drawer` in settings. Deep teal/navy background, stagger-animated nav items, profile header area replaced with brand header.
5. **Widget extraction refactor** — convert all inline/function widgets (like `_BrandMark`, `navTile()`, `_AlbumUrlList`) to top-level classes in their own files with proper folder organization.

## Tech Stack

Flutter 3.10+, flutter_bloc, flutter_screenutil, go_router, GetIt DI. Beiruti font. Teal-green `#384c4b` primary palette.

---

## 1. AppButton Widget

### Location
`lib/core/widgets/buttons/app_button.dart`

### API

```dart
class AppButton extends StatelessWidget {
  // Three factory constructors:
  const AppButton.elevated({...});
  const AppButton.outlined({...});
  const AppButton.text({...});
  
  // Common parameters:
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
  final IconData? leadingIcon;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final LinearGradient? gradient;
  final bool expand; // default true = full width
}
```

### Variants

- **Elevated**: Gradient fill (default `AppColors.primaryGradient`), white text, optional shadow. This is the primary CTA.
- **Outlined**: Transparent background, `AppColors.primary` border and text. For secondary actions.
- **Text**: No background/border. Colored text. For tertiary actions like "Register" link.

### States
- **Normal**: Full color, pointer cursor.
- **Loading**: Content replaced with `SizedBox` + `CircularProgressIndicator`, taps disabled.
- **Disabled**: Muted colors (`AppColors.muted` bg / `AppColors.mutedForeground` text), no tap.

### Sizing
- Default height: `48.h` mobile, `52.h` tablet, `40.h` desktop (via `context.responsive`).
- `expand: true` → `width: double.infinity`. `expand: false` → intrinsic width with padding.
- Border radius: `14.r` default.

### Replaces
- `CustomElevatedButton` — direct replacement with `AppButton.elevated`
- All inline `TextButton` / `ElevatedButton` usages — replaced with `AppButton.text` / `AppButton.outlined`
- `CustomElevatedButton` file deleted after migration.

---

## 2. Logo Cleanup

- Delete `assets/logo.jpg`.
- Grep entire codebase for `logo.jpg` references, replace with `logo.png`.
- Verify `pubspec.yaml` `flutter_launcher_icons` config points to `assets/logo.png`.
- Verify `LogoRectangle` uses `assets/logo.png` (already does).
- Verify `settings_drawer.dart` uses `assets/logo.png` (already does).

---

## 3. Splash Screen Redesign

### Location
`lib/features/splash/presentation/splash_screen.dart`

### Design Concept
Clean, centered composition. Teal-green palette. The logo is the hero.

### Layout (top to bottom, vertically centered)
1. **Background**: Soft gradient from `#F8FAFC` top-left to `#F0FDFA` bottom-right (keep current), with two decorative teal-tinted circular blobs for depth.
2. **Logo**: `logo.png` displayed in a white rounded container (similar to current `LogoRectangle` but bigger — 120x120). Entrance: scale from 0.7→1.0 with `Curves.elasticOut` over 1200ms + fade in over 800ms.
3. **App Name**: "ميقات" / tagline text below logo. Entrance: fade in over 1000ms, delayed 200ms after logo.
4. **Subtle spinner**: Small `CircularProgressIndicator` at bottom, appears after 800ms delay. Teal color.

### Animations
- Use `AnimatedScale` + `AnimatedOpacity` (current approach is fine, keep it).
- Add a subtle shimmer/pulse on the logo container after it lands (optional polish).

### Behavior
- Same BLoC routing logic (SplashRoutingBloc): login → settings → display.
- 2000ms display before navigation.

---

## 4. Login Screen Redesign

### Location
`lib/features/auth/presentation/login_screen.dart`

### Design Concept
Clean card-based form. Logo as brand anchor. Teal-green accent, white card, soft shadows. Professional and polished.

### Layout (scrollable, vertically centered)
1. **Bismillah text** — subtle, small, centered top.
2. **Logo** — `logo.png` in white rounded rectangle container (LogoRectangle, big=false). Not the circular gradient icon — the actual logo image.
3. **Title + subtitle** — "تسجيل الدخول" + "لوحة تحكم إدارة المسجد".
4. **Form card** — white container, rounded 22.r, subtle shadow. Contains:
   - Email field (CustomTextField, current style)
   - Password field (CustomTextField, current style)
   - Login button: `AppButton.elevated` (replaces CustomElevatedButton)
5. **Tawakkul quote** — italic, subtle.
6. **Register link** — `AppButton.text` (replaces inline TextButton).

### Key Changes from Current
- Replace `_BrandMark` (circular gradient with mosque icon) with actual `logo.png` display via `LogoRectangle`.
- Replace `CustomElevatedButton` with `AppButton.elevated`.
- Replace inline `TextButton` for register with `AppButton.text`.
- Extract `_BrandMark` into nothing (it's removed).
- Keep form validation, BLoC logic, SystemUiOverlayStyle unchanged.

---

## 5. ZoomDrawer Implementation

### Concept
Replaces the standard Flutter `Drawer` with a slide-and-scale drawer like the visitors project. When open, the main screen scales down and slides right, revealing the drawer menu underneath.

### Files
- `lib/core/widgets/navigation/zoom_drawer.dart` — ZoomDrawerController + ZoomDrawer widget
- `lib/features/settings/presentation/widgets/common/settings_zoom_drawer.dart` — The actual drawer content (replaces settings_drawer.dart content)
- `lib/features/settings/presentation/settings_page.dart` — Modified to use ZoomDrawer instead of Scaffold drawer

### ZoomDrawerController
```dart
class ZoomDrawerController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;
  void toggle() { _isOpen = !_isOpen; notifyListeners(); }
  void open() { if (!_isOpen) { _isOpen = true; notifyListeners(); } }
  void close() { if (_isOpen) { _isOpen = false; notifyListeners(); } }
}
```

### ZoomDrawer Widget
- Stack-based: menu behind, main screen on top.
- Animation: 300ms, main screen translates + scales to 0.85.
- RTL support via `Directionality.of(context)`.
- Shadow + border radius on main screen when open.
- Tap main screen to close.

### Drawer Content (SettingsZoomDrawer)
- **Background**: Deep teal `Color(0xFF1A2F2E)` (dark version of primary).
- **Header**: Logo + app name + tagline (same content as current drawer header but adapted to dark background with white/light text).
- **Nav items**: 10 items with stagger animation on open. Each item: icon + label, selected state with light teal highlight background + white dot indicator.
- **Footer**: Contact support button + sign out button + version.
- **Stagger animation**: Items fade+slide in with 40ms stagger per item on drawer open.

### Integration
- `SettingsPage` replaces `Scaffold(drawer: SettingsDrawer(...))` with `ZoomDrawer(controller: ..., menuScreen: SettingsZoomDrawer(...), mainScreen: Scaffold(...))`.
- AppBar hamburger menu button calls `controller.toggle()` instead of `Scaffold.of(context).openDrawer()`.

---

## 6. Widget Extraction Refactor

### Principle
Every widget that's currently a local function or private class (`_WidgetName`) inside another file gets extracted to its own file as a public class, organized in appropriate folders.

### Extractions Needed

**Settings widgets:**
- `navTile()` function in settings_drawer.dart → `DrawerNavTile` class in `widgets/common/drawer_nav_tile.dart`
- `_AlbumUrlList` in background_settings_section.dart → `AlbumUrlList` class in `widgets/design/album_url_list.dart`

**Auth widgets:**
- `_BrandMark` in login_screen.dart → Removed (replaced with LogoRectangle)

**Display widgets (check for inline functions):**
- Any local `_buildXxx` methods that return substantial widget trees should be extracted if they represent reusable components.

**Settings sections (check for inline widgets):**
- Scan all 10 section files for private widget classes or complex builder functions.

### Folder Structure After Refactor
```
lib/core/widgets/
├── buttons/
│   ├── app_button.dart          ← NEW
│   └── buttons_widgets.dart     ← barrel
├── forms/
│   ├── custom_text_field.dart
│   ├── custom_date_picker_field.dart
│   ├── custom_dropdown_field.dart
│   ├── custom_radio_group_field.dart
│   ├── custom_image_picker.dart
│   ├── profile_image_picker.dart
│   └── forms_widgets.dart       ← barrel (remove custom_elevated_button export)
├── navigation/
│   ├── zoom_drawer.dart         ← NEW
│   ├── custom_back_button.dart
│   └── navigation_widgets.dart  ← barrel
├── media/
│   ├── logo_rectangle.dart
│   ├── optimized_image.dart
│   └── media_widgets.dart
├── feedback/
│   ├── (existing files)
│   └── feedback_widgets.dart
├── animation/
│   ├── (existing files)
│   └── animation_widgets.dart
└── lists/
    ├── (existing files)
    └── list_widgets.dart
```

### Migration Safety
- After creating `AppButton`, grep for all `CustomElevatedButton` usages and replace.
- After replacing, delete `custom_elevated_button.dart`.
- Update barrel files.
- Run `flutter analyze` after each extraction to catch import issues.

---

## Non-Goals
- No changes to BLoC logic, data models, or repository layer.
- No changes to display screen.
- No changes to registration screen (beyond button replacement).
- No new dependencies needed.
