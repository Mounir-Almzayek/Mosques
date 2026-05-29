# Android TV Remote / Keyboard Focus — Design Spec

**Date:** 2026-05-29
**Status:** Approved (design shape) — pending spec review
**Scope:** App-wide focus system so the entire interactive UI (login + all settings + dialogs) is fully operable with an Android TV remote (D-pad + OK/center + Back) and a hardware keyboard.

---

## 1. Problem

The app is installed on Android-based display screens and configured via a remote control (and sometimes a keyboard). Today the remote/keyboard "can't interact" with most UI. Audit findings:

- **Manifest is already TV-ready** — `android.software.leanback` (required=false), touchscreen not required, `LEANBACK_LAUNCHER` intent, banner. No manifest change needed.
- Flutter's Material widgets (`TextButton`, `FilledButton`, `OutlinedButton`, `IconButton`, `InkWell`, `Switch`, `ListTile`) are **already focus-traversable** by D-pad/arrow/Tab. `AppButton` (InkWell/TextButton based) is fine.
- The reasons it *feels* broken:
  1. **No visible focus indicator** — the default Material focus overlay is too subtle on a TV at distance, so the user cannot see what is selected.
  2. **No autofocus on screen entry** — nothing holds focus when a screen opens, so the first D-pad press does nothing.
  3. **Bare `GestureDetector` controls are not focusable at all** — color swatch (`design_color_item.dart:79`), album grid cell (`album_grid_cell.dart:21`), background picker (`display_background_picker.dart:67`).
  4. **Plain `TextField`s in dialogs** lack the remote-activation handling that `CustomTextField` already implements (Enter/Select/center opens the keyboard).
  5. **No global Back/Escape handling** to dismiss dialogs/drawer from the remote.

## 2. Goals / Non-Goals

**Goals**
- Every interactive element is reachable and activatable by D-pad + OK and by keyboard.
- A single, consistent, clearly visible focus highlight across the whole app, driven by theme tokens.
- Each top-level screen autofocuses a sensible first control on entry.
- Back/Escape reliably dismisses the topmost dismissible surface (dialog → drawer → nothing).
- Clean, maintainable, reusable module — no per-widget bespoke focus code.

**Non-Goals**
- No change to the `/display` runtime screen's content (it is non-interactive output; only its existing settings shortcut matters).
- No custom directional focus graph / bespoke `FocusTraversalPolicy` per screen (Flutter's default reading-order + directional traversal is sufficient for these standard list/grid/form layouts).
- No new third-party packages.

## 3. Architecture

A new module: `lib/core/widgets/focus/`. Three small, independently testable units plus theme tokens.

### 3.1 Focus theme tokens
Add focus tokens to `AppColors` and wire a visible focus treatment into `AppTheme.light`:
- `AppColors.focusRing` — a high-contrast ring color derived from the brand primary (a brightened teal accent).
- In `AppTheme.light`: set `focusColor` and bump the Material `overlayColor` / `WidgetStateProperty` focus opacity for buttons so **existing Material controls** also get a clearly visible focus state without per-widget changes.

### 3.2 `FocusRing` widget — `lib/core/widgets/focus/focus_ring.dart`
A wrapper that gives any child one consistent focus highlight.
- Built on `FocusableActionDetector` (gives `onShowFocusHighlight` + actions in one widget).
- When focused: paints a rounded border ring (color `AppColors.focusRing`, width ~3) and an optional subtle scale (1.0 → 1.04) via `AnimatedScale`/`AnimatedContainer`.
- Inputs: `child`, `borderRadius`, `focusNode?`, `autofocus`, `enabled`, `onFocusChange?`. Pure presentational — does NOT own tap handling.
- This is the single source of truth for "what focus looks like."

### 3.3 `AppFocusable` widget — `lib/core/widgets/focus/app_focusable.dart`
Reusable focusable + tappable control to replace bare `GestureDetector`s.
- Built on `FocusableActionDetector` with `ActivateIntent`/`ButtonActivateIntent` → `onPressed`, wrapping its child in a `FocusRing`.
- Maps OK/center/Enter/Select/Space (activation) to `onPressed`; pointer `onTap` also calls `onPressed` (so touch still works).
- Inputs: `child`, `onPressed`, `borderRadius`, `focusNode?`, `autofocus`, `enabled`, `semanticLabel?`.
- Replaces the 3 bare `GestureDetector` controls. Other tappables already on Material/InkWell are left as-is (they inherit the theme focus treatment).

### 3.4 `TvNavigationScope` widget — `lib/core/widgets/focus/tv_navigation_scope.dart`
Screen-level wrapper that makes a whole screen remote-friendly.
- Wraps content in a `FocusTraversalGroup` (keeps traversal order within the screen sane; lets the drawer and content be separate sub-groups if nested).
- Autofocus is achieved by the screen's first logical control setting `autofocus: true` (on its `AppFocusable`/Material widget/`CustomTextField`). The scope's own responsibilities are the `FocusTraversalGroup` and Back/Escape handling — it does not manage individual node focus.
- Back/Escape: provides `Shortcuts` + `Actions` mapping `LogicalKeyboardKey.escape`/`goBack` and the Android system back to a `DismissIntent` that pops the topmost route if dismissible. (Dialogs use `showDialog` which already pops on system back; this scope covers in-screen overlays like the zoom drawer — closing the drawer instead of leaving the screen.)

### 3.5 Dialog text input
Route the plain dialog `TextField`s (`album_section_body.dart:34`, `album_url_list.dart:36`, `profile_action_card.dart:46`) through the existing TV-aware `CustomTextField` (which already handles Enter/Select → open keyboard, Escape → close). No new code — reuse.

## 4. Data / Control Flow

Remote/keyboard key → Flutter `FocusManager` directional traversal → focused widget shows `FocusRing` highlight (via theme for Material widgets, via `FocusRing`/`AppFocusable` for custom ones) → OK/center fires `ActivateIntent` → widget's `onPressed`/Material `onTap`. Back/Escape → `DismissIntent` in the nearest `TvNavigationScope`/dialog → pop overlay.

No BLoC, repository, or data-layer changes. This is purely a presentation-layer concern.

## 5. Migration Plan (order)

1. **Foundation:** `AppColors.focusRing` token + `AppTheme.light` focus treatment; `FocusRing`; `AppFocusable`; `TvNavigationScope`. Unit/widget tests for each.
2. **Custom controls:** migrate the 3 bare `GestureDetector` widgets to `AppFocusable`.
3. **Login screen:** wrap in `TvNavigationScope`, autofocus the email field, verify field→field→button traversal (FocusNodes already exist).
4. **Settings shell + drawer:** wrap the settings scaffold and zoom-drawer in `TvNavigationScope`; ensure drawer tiles autofocus when the drawer opens and Back closes the drawer.
5. **Settings sections + dialogs:** route dialog `TextField`s through `CustomTextField`; confirm section content (cards, steppers, toggles) is reachable.
6. **Manual remote/keyboard test pass** across login + every settings section + dialogs.

## 6. Testing Strategy

- **Widget tests** (per unit):
  - `FocusRing`: shows highlight decoration when its node gains focus; hides when it loses focus.
  - `AppFocusable`: `ActivateIntent` (simulated Enter/Select key) invokes `onPressed`; pointer tap invokes `onPressed`; disabled blocks both; not focusable when `enabled: false`.
  - `TvNavigationScope`: Escape key triggers dismiss/pop of an open overlay; focus traversal stays within the group.
- **Migration regression:** existing tests for the 3 migrated controls still pass; tapping still works (touch path preserved).
- **Manual D-pad/keyboard pass:** documented checklist (login, each settings section, each dialog) — verify visible focus, traversal in all 4 directions, OK activation, Back dismissal.

## 7. Risks & Mitigations

- **Double-activation** (pointer + activate firing twice): `AppFocusable` routes both through one `onPressed`; guard against duplicate by using the framework's `Actions`/`GestureDetector` separately (pointer vs key) — they cannot both fire for one input.
- **Focus highlight on touch-only use looks odd:** use `onShowFocusHighlight` (only true for directional/keyboard focus, not pointer) so the ring shows for remote/keyboard, not casual touch.
- **Autofocus stealing keyboard on phones:** autofocus targets non-text controls first where possible; text autofocus only where it already exists (login already autofocuses appropriately).
- **Nested traversal groups** (drawer over content): use separate `FocusTraversalGroup`s and ensure the drawer, when open, holds focus (modal barrier / `FocusScope`).

## 8. Affected Files

**New:** `lib/core/widgets/focus/focus_ring.dart`, `app_focusable.dart`, `tv_navigation_scope.dart` (+ a barrel `focus_widgets.dart`), and matching tests under `test/core/widgets/focus/`.

**Modified:** `lib/core/styles/app_colors.dart` (+token), `lib/core/styles/app_theme.dart` (focus treatment), `design_color_item.dart`, `album_grid_cell.dart`, `display_background_picker.dart` (→ `AppFocusable`), `album_section_body.dart`, `album_url_list.dart`, `profile_action_card.dart` (dialog fields → `CustomTextField`), `login_screen.dart` + settings shell/drawer (→ `TvNavigationScope`).
