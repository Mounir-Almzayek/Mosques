# Android TV Remote / Keyboard Focus — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the entire interactive UI (login + all settings + dialogs) fully operable by an Android TV remote (D-pad + OK + Back) and a hardware keyboard, with a single, clearly visible focus highlight.

**Architecture:** A `lib/core/widgets/focus/` module with three reusable units — `FocusRing` (presentational highlight), `AppFocusable` (focusable+tappable, replaces bare `GestureDetector`s), `TvNavigationScope` (per-screen traversal group + Back handling) — plus a focus-color token in the theme. No data-layer changes; presentation only.

**Tech Stack:** Flutter, Material 3, `FocusableActionDetector`, `FocusTraversalGroup`, `Shortcuts`/`Actions`, `flutter_test`. Package import prefix is exactly `package:Tebyan/`.

---

### Task 1: Focus theme token

**Files:**
- Modify: `lib/core/styles/app_colors.dart`
- Modify: `lib/core/styles/app_theme.dart` (inside `AppTheme.light`)

- [ ] **Step 1: Add the focus-ring color token**

In `app_colors.dart`, add a high-contrast focus color near the other brand color constants:

```dart
/// High-contrast ring used to mark the focused control for TV remote /
/// keyboard navigation. Brightened brand teal so it reads at a distance.
static const Color focusRing = Color(0xFF2DD4BF);
```

- [ ] **Step 2: Wire a visible focus treatment into the theme**

In `app_theme.dart`, inside the `ThemeData(...)` returned by `AppTheme.light`, add `focusColor` and boost the focus overlay on the existing button themes so Material controls show a clear focus state. Add to the `ThemeData`:

```dart
focusColor: AppColors.focusRing.withValues(alpha: 0.24),
```

And in `elevatedButtonTheme`'s `ElevatedButton.styleFrom(...)`, add:

```dart
          overlayColor: AppColors.focusRing.withValues(alpha: 0.22),
```

- [ ] **Step 3: Verify analyzer is clean**

Run: `flutter analyze lib/core/styles/app_colors.dart lib/core/styles/app_theme.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/core/styles/app_colors.dart lib/core/styles/app_theme.dart
git commit -m "feat(focus): add focus-ring color token and theme focus treatment"
```

---

### Task 2: FocusRing widget

**Files:**
- Create: `lib/core/widgets/focus/focus_ring.dart`
- Test: `test/core/widgets/focus/focus_ring_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/focus_ring.dart';

void main() {
  testWidgets('FocusRing paints a highlight border when focused', (tester) async {
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FocusRing(
          focusNode: node,
          borderRadius: BorderRadius.circular(8),
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));

    // Not focused: no highlight flag.
    expect(find.byKey(const ValueKey('focus_ring_highlight')), findsNothing);

    node.requestFocus();
    await tester.pumpAndSettle();

    // Focused: highlight container present.
    expect(find.byKey(const ValueKey('focus_ring_highlight')), findsOneWidget);

    node.dispose();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/focus/focus_ring_test.dart`
Expected: FAIL — `focus_ring.dart` does not exist / `FocusRing` undefined.

- [ ] **Step 3: Implement FocusRing**

```dart
import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';

/// The single source of truth for "what a focused control looks like" on
/// TV / keyboard navigation. Presentational only — does not handle taps.
///
/// Uses [FocusableActionDetector.onShowFocusHighlight] so the ring appears
/// for directional/keyboard focus but NOT for casual pointer taps.
class FocusRing extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<bool>? onFocusChange;

  const FocusRing({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.onFocusChange,
  });

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _showHighlight = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onShowFocusHighlight: (v) {
        if (v == _showHighlight) return;
        setState(() => _showHighlight = v);
        widget.onFocusChange?.call(v);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _showHighlight ? 1.04 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          key: _showHighlight ? const ValueKey('focus_ring_highlight') : null,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _showHighlight ? AppColors.focusRing : Colors.transparent,
              width: 3,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/focus/focus_ring_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/focus/focus_ring.dart test/core/widgets/focus/focus_ring_test.dart
git commit -m "feat(focus): add FocusRing highlight widget"
```

---

### Task 3: AppFocusable widget

**Files:**
- Create: `lib/core/widgets/focus/app_focusable.dart`
- Test: `test/core/widgets/focus/app_focusable_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/app_focusable.dart';

void main() {
  testWidgets('AppFocusable fires onPressed on pointer tap', (tester) async {
    var count = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    await tester.tap(find.byType(AppFocusable));
    expect(count, 1);
  });

  testWidgets('AppFocusable fires onPressed on Enter key when focused', (tester) async {
    var count = 0;
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          focusNode: node,
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    node.requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(count, 1);
    node.dispose();
  });

  testWidgets('AppFocusable disabled blocks tap and is not focusable', (tester) async {
    var count = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFocusable(
          enabled: false,
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    ));
    await tester.tap(find.byType(AppFocusable));
    expect(count, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/focus/app_focusable_test.dart`
Expected: FAIL — `app_focusable.dart` does not exist.

- [ ] **Step 3: Implement AppFocusable**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'focus_ring.dart';

/// A focusable, tappable control for TV remote / keyboard navigation.
///
/// Replaces bare [GestureDetector]s so the control is reachable by D-pad and
/// activatable by OK/center/Enter/Select/Space, while preserving pointer taps.
/// Wraps its child in a [FocusRing] for a consistent focus highlight.
class AppFocusable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final String? semanticLabel;

  const AppFocusable({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;

    return Semantics(
      button: true,
      enabled: active,
      label: semanticLabel,
      child: FocusableActionDetector(
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: active,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (active) onPressed!.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: active ? onPressed : null,
          child: FocusRing(
            // The detector above owns focus; the ring is purely visual here.
            borderRadius: borderRadius,
            enabled: false,
            child: child,
          ),
        ),
      ),
    );
  }
}
```

NOTE for implementer: the `FocusableActionDetector` owns the focus node, so the inner `FocusRing` must NOT also create a focus node — set its `enabled: false` and instead drive its highlight via the detector's `onShowFocusHighlight`. If wiring the highlight through `FocusRing` proves awkward, inline the highlight `AnimatedContainer` directly in `AppFocusable` using a local `_showHighlight` bool fed by `FocusableActionDetector.onShowFocusHighlight` (convert `AppFocusable` to a `StatefulWidget`). Prefer whichever keeps a single highlight implementation; do not duplicate the border-painting logic. If you inline it, delete the now-unused visual path rather than leaving both.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/focus/app_focusable_test.dart`
Expected: PASS (all three tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/focus/app_focusable.dart test/core/widgets/focus/app_focusable_test.dart
git commit -m "feat(focus): add AppFocusable focusable+tappable control"
```

---

### Task 4: TvNavigationScope widget + barrel

**Files:**
- Create: `lib/core/widgets/focus/tv_navigation_scope.dart`
- Create: `lib/core/widgets/focus/focus_widgets.dart` (barrel)
- Test: `test/core/widgets/focus/tv_navigation_scope_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Tebyan/core/widgets/focus/tv_navigation_scope.dart';

void main() {
  testWidgets('TvNavigationScope invokes onDismiss on Escape', (tester) async {
    var dismissed = 0;
    final node = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TvNavigationScope(
          onDismiss: () => dismissed++,
          child: Focus(focusNode: node, autofocus: true, child: const SizedBox(width: 40, height: 40)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    node.dispose();
  });

  testWidgets('TvNavigationScope wraps content in a FocusTraversalGroup', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TvNavigationScope(child: const SizedBox(width: 40, height: 40)),
      ),
    ));
    expect(find.byType(FocusTraversalGroup), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/focus/tv_navigation_scope_test.dart`
Expected: FAIL — `tv_navigation_scope.dart` does not exist.

- [ ] **Step 3: Implement TvNavigationScope**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen-level wrapper that makes a screen remote/keyboard friendly:
/// groups focus traversal and routes Back/Escape to a dismiss action.
///
/// Autofocus is the responsibility of the screen's first control (it sets
/// `autofocus: true`); this scope only owns traversal grouping + dismissal.
class TvNavigationScope extends StatelessWidget {
  final Widget child;

  /// Called when the user presses Back/Escape. Defaults to popping the
  /// current route if one can be popped.
  final VoidCallback? onDismiss;

  const TvNavigationScope({super.key, required this.child, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.goBack): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              final cb = onDismiss;
              if (cb != null) {
                cb();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(child: child),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/focus/tv_navigation_scope_test.dart`
Expected: PASS (both tests).

- [ ] **Step 5: Create the barrel file**

`lib/core/widgets/focus/focus_widgets.dart`:

```dart
export 'app_focusable.dart';
export 'focus_ring.dart';
export 'tv_navigation_scope.dart';
```

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/focus/tv_navigation_scope.dart lib/core/widgets/focus/focus_widgets.dart test/core/widgets/focus/tv_navigation_scope_test.dart
git commit -m "feat(focus): add TvNavigationScope and focus barrel"
```

---

### Task 5: Migrate the color-swatch control to AppFocusable

**Files:**
- Modify: `lib/features/settings/design/widgets/design_color_item.dart:79-97`

- [ ] **Step 1: Replace the bare GestureDetector**

In the `build` method's `trailing:`, replace the `GestureDetector(onTap: ..., child: Container(...))` with `AppFocusable`, keeping the same `Container` child and tap behavior:

```dart
      trailing: AppFocusable(
        onPressed: () => _showColorPicker(context),
        borderRadius: BorderRadius.circular(10),
        semanticLabel: label,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
```

Add the import at the top:

```dart
import '../../../../core/widgets/focus/focus_widgets.dart';
```

- [ ] **Step 2: Verify analyzer is clean**

Run: `flutter analyze lib/features/settings/design/widgets/design_color_item.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/design/widgets/design_color_item.dart
git commit -m "feat(focus): make color swatch remote-focusable"
```

---

### Task 6: Migrate the album grid cell to AppFocusable

**Files:**
- Read first, then modify: `lib/features/settings/album/widgets/album_grid_cell.dart`

- [ ] **Step 1: Read the file to confirm the GestureDetector shape**

Run: read `lib/features/settings/album/widgets/album_grid_cell.dart` fully. Identify the `GestureDetector` at ~line 21 and its `onTap`/`child`.

- [ ] **Step 2: Replace the GestureDetector with AppFocusable**

Wrap the existing child in `AppFocusable`, moving the `onTap` callback to `onPressed` and preserving any `borderRadius` the cell already uses for its image (match it so the ring aligns). Add the import:

```dart
import '../../../../core/widgets/focus/focus_widgets.dart';
```

Preserve all existing visuals and any long-press/secondary handlers (if the cell has `onLongPress`, keep it by wrapping the `AppFocusable` in a `GestureDetector` that only handles `onLongPress`, or pass it through — do NOT drop existing behavior).

- [ ] **Step 3: Verify analyzer is clean**

Run: `flutter analyze lib/features/settings/album/widgets/album_grid_cell.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/album/widgets/album_grid_cell.dart
git commit -m "feat(focus): make album grid cell remote-focusable"
```

---

### Task 7: Migrate the background picker to AppFocusable

**Files:**
- Read first, then modify: `lib/features/settings/design/widgets/display_background_picker.dart`

- [ ] **Step 1: Read the file to confirm the GestureDetector shape**

Run: read `lib/features/settings/design/widgets/display_background_picker.dart` fully. Identify the `GestureDetector` at ~line 67 and its `onTap`/`child`.

- [ ] **Step 2: Replace the GestureDetector with AppFocusable**

Wrap the selectable card/child in `AppFocusable`, moving `onTap` → `onPressed`, matching the card's `borderRadius`. Add the import:

```dart
import '../../../../core/widgets/focus/focus_widgets.dart';
```

Preserve the existing "selected" visual state.

- [ ] **Step 3: Verify analyzer is clean**

Run: `flutter analyze lib/features/settings/design/widgets/display_background_picker.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/design/widgets/display_background_picker.dart
git commit -m "feat(focus): make background picker remote-focusable"
```

---

### Task 8: Route dialog text fields through CustomTextField

**Files:**
- Read first, then modify: `lib/features/settings/album/widgets/album_section_body.dart:~34`
- Read first, then modify: `lib/features/settings/design/widgets/album_url_list.dart:~36`
- Read first, then modify: `lib/features/settings/profile/widgets/profile_action_card.dart:~46`

- [ ] **Step 1: Read each file's TextField usage**

For each file, read the `TextField`/`TextFormField` and note its controller, hint/label, keyboardType, and any `onChanged`/`onSubmitted`.

- [ ] **Step 2: Replace each plain TextField with CustomTextField**

Swap each `TextField(controller: c, decoration: InputDecoration(hintText: ...))` for:

```dart
CustomTextField(
  controller: c,
  hintText: <existing hint>,
  // map existing keyboardType / onChanged / onFieldSubmitted as applicable
  // enableTvRemoteSupport defaults to true
)
```

Add the import where missing:

```dart
import 'package:Tebyan/core/widgets/forms/custom_text_field.dart';
```

(Use a relative import consistent with the file's existing style if the file uses relative imports.) Drop the now-redundant `autofocus: true` only if it conflicts; otherwise pass `autofocus: true` through to `CustomTextField`.

- [ ] **Step 3: Verify analyzer is clean**

Run: `flutter analyze lib/features/settings/album/widgets/album_section_body.dart lib/features/settings/design/widgets/album_url_list.dart lib/features/settings/profile/widgets/profile_action_card.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/album/widgets/album_section_body.dart lib/features/settings/design/widgets/album_url_list.dart lib/features/settings/profile/widgets/profile_action_card.dart
git commit -m "feat(focus): route dialog text fields through TV-aware CustomTextField"
```

---

### Task 9: Wrap the login screen in TvNavigationScope + autofocus

**Files:**
- Modify: `lib/features/auth/presentation/login_screen.dart`

- [ ] **Step 1: Read the build method and current FocusNode wiring**

Confirm the email/password `FocusNode`s (~lines 27-28) and the `CustomTextField` usages (~lines 262, 293) and the submit button.

- [ ] **Step 2: Wrap the screen body in TvNavigationScope**

Wrap the top-level content widget returned by `build` (the `Scaffold` body, or the outermost layout under it) in `TvNavigationScope(child: ...)`. Add import:

```dart
import 'package:Tebyan/core/widgets/focus/focus_widgets.dart';
```

(or relative, matching file style).

- [ ] **Step 3: Autofocus the email field**

On the email `CustomTextField`, set `autofocus: true` (only the email field). Leave password/button traversal to the existing `nextFocusNode` wiring.

- [ ] **Step 4: Verify analyzer is clean**

Run: `flutter analyze lib/features/auth/presentation/login_screen.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/login_screen.dart
git commit -m "feat(focus): make login screen remote-navigable with autofocus"
```

---

### Task 10: Wrap the settings shell + zoom drawer in TvNavigationScope

**Files:**
- Read first: `lib/features/settings/core/widgets/settings_zoom_drawer_content.dart`, the settings page/scaffold (find via `lib/features/settings/**` — the page registered at `/settings`), and `lib/features/settings/core/widgets/drawer_nav_tile.dart`

- [ ] **Step 1: Locate the settings scaffold and drawer**

Find the widget registered for `Routes.settingsPath` in `lib/core/routes/app_pages.dart` and read it. Identify where the zoom-drawer is built and where its nav tiles live.

- [ ] **Step 2: Wrap the settings scaffold body in TvNavigationScope**

Wrap the settings content in `TvNavigationScope`. For the drawer: provide an `onDismiss` that closes the drawer when it is open (call the existing drawer controller's close), and otherwise falls back to default pop. Add the focus barrel import.

- [ ] **Step 3: Autofocus the first drawer tile when the drawer opens**

On the first `DrawerNavTile` (or the first section's primary control when the drawer is closed), set `autofocus: true` so the remote has an initial target. If `DrawerNavTile` uses `InkWell`, it is already focusable — only add `autofocus` to the first one.

- [ ] **Step 4: Verify analyzer is clean**

Run: `flutter analyze lib/features/settings`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A lib/features/settings
git commit -m "feat(focus): make settings shell and drawer remote-navigable"
```

---

### Task 11: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the whole test suite**

Run: `flutter test`
Expected: all tests pass (including the 3 new focus test files and the prior 33).

- [ ] **Step 2: Run a full analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Manual remote/keyboard checklist (document results)**

On an Android TV / emulator with D-pad (or keyboard arrows + Enter + Esc), verify and record pass/fail for each:
- Login: email autofocused; arrow-down/Tab moves email → password → login button; each shows a visible ring; Enter on a field opens the keyboard; Enter on the button submits.
- Settings drawer: first tile focused; up/down traverses tiles; Enter opens a section; Back/Esc closes the drawer.
- Design section: color swatch reachable, shows ring, Enter opens picker; Esc closes picker.
- Album section: grid cell reachable + activatable; FAB reachable; add-URL dialog field accepts keyboard.
- Background picker: each option reachable, shows ring, Enter selects.
- Confirm casual touch still works everywhere (ring does not appear on pointer tap).

- [ ] **Step 4: Commit any checklist doc / fixes**

If the manual pass surfaces issues, fix them (re-running the relevant task's analyze/test), then commit. If clean, no commit needed.

---

## Self-Review Notes

- **Spec coverage:** Foundation (Tasks 1-4) = spec §3.1-3.4; custom controls (Tasks 5-7) = §3.3 migration; dialog fields (Task 8) = §3.5; login (Task 9) + settings (Task 10) = §5 steps 3-4; verification (Task 11) = §6.
- **Type consistency:** `AppFocusable.onPressed` (`VoidCallback?`), `FocusRing.borderRadius` (`BorderRadius`), `TvNavigationScope.onDismiss` (`VoidCallback?`) are used consistently across all migration tasks.
- **Known soft spot:** Task 3's `AppFocusable` has two acceptable highlight wirings (inner `FocusRing` vs inlined). The task instructs the implementer to keep a single highlight implementation and delete the unused path — flagged for the code-quality reviewer.
