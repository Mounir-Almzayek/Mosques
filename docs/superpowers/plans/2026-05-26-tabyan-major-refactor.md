# Tebyan (تبيان) Major Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the mosque display app into a clean, priority-based layered architecture where content (alerts, photos, iqama/adhan, religious text, prayer times) is managed through a dynamic overlay system with smooth transitions, configurable timings, remote backgrounds, and a photo studio feature.

**Architecture:** A `DisplayLayerController` state machine manages which content layer is active at any moment. Each layer is a fullscreen overlay with priority ranking. The default view (prayer times) shows when no higher-priority layer is active. Transitions between layers use fade/slide animations. All timing parameters are configurable from the settings app and persisted to Firestore.

**Tech Stack:** Flutter 3.x, flutter_bloc, Firestore, Dio (HTTP caching), Adhan library, go_router

---

## Architecture Overview

### Priority Layer System (highest → lowest)

| Priority | Layer | Trigger | Duration |
|----------|-------|---------|----------|
| 1 | **Alerts** (التنبيهات الفورية) | Manual from settings | `displayDurationSeconds` |
| 2 | **Photo Studio** (استديو الصور) | Manual selection | Until dismissed |
| 3 | **Iqama/Adhan** (الإقامة والأذان) | Automatic by prayer time | Until phase ends |
| 4 | **Religious Content** (المحتوى الديني) | Timed interval | `contentDisplaySeconds` |
| 5 | **Prayer Times** (الميقاتية) | Default | Always (base layer) |

Higher-priority layers obscure everything below them. When a layer expires, the next highest active layer takes over.

### Iqama/Adhan Sub-Phases (Priority 3 detail)

| Sub-Phase | Trigger | Display |
|-----------|---------|---------|
| Pre-Adhan Countdown | `preAdhanMinutes` before adhan | Fullscreen: الوقت المتبقي للأذان + countdown |
| Adhan Moment | Exact adhan minute | Fullscreen: حان الآن موعد أذان X |
| Iqama Countdown | Between adhan and iqama | Fullscreen: الوقت المتبقي لصلاة X + countdown |

### File Structure (New & Modified)

```
lib/
├── core/
│   ├── enums/
│   │   └── display/
│   │       ├── display_layer_kind.dart          [CREATE]
│   │       └── prayer_display_phase_kind.dart   [MODIFY - add preAdhan, adhanMoment]
│   └── utils/
│       ├── prayer_times_helper.dart             [MODIFY - add pre-adhan phase]
│       └── prayer_display_phase.dart            [KEEP]
├── data/
│   ├── models/
│   │   ├── design/
│   │   │   ├── design_settings_model.dart       [MODIFY - add new timing fields]
│   │   │   └── design_background_settings.dart  [MODIFY - add remote URL support]
│   │   ├── mosque/
│   │   │   ├── mosque_model.dart                [MODIFY - add photo studio URLs]
│   │   │   └── iqama_settings_model.dart        [KEEP]
│   │   └── display/
│   │       └── display_layer_state.dart         [CREATE]
│   └── repositories/
│       └── background_cache_repository.dart     [CREATE]
├── features/
│   ├── display/
│   │   ├── bloc/
│   │   │   └── display_bloc.dart                [MODIFY]
│   │   ├── controller/
│   │   │   └── display_layer_controller.dart    [CREATE]
│   │   └── presentation/
│   │       ├── display_screen.dart              [REWRITE]
│   │       └── widgets/
│   │           ├── layers/
│   │           │   ├── layer_transition_wrapper.dart   [CREATE]
│   │           │   ├── alert_layer.dart                [CREATE]
│   │           │   ├── photo_studio_layer.dart         [CREATE]
│   │           │   ├── iqama_adhan_layer.dart          [CREATE]
│   │           │   └── religious_content_layer.dart    [CREATE]
│   │           ├── prayer/
│   │           │   ├── display_prayer_card.dart        [REWRITE]
│   │           │   ├── prayer_cards_row.dart           [CREATE]
│   │           │   └── prayer_card_background.dart     [KEEP]
│   │           ├── content/
│   │           │   ├── display_beige_area.dart         [REWRITE]
│   │           │   └── display_spiritual_strip.dart    [DELETE]
│   │           │   └── typing_text_column.dart         [DELETE]
│   │           └── alerts/
│   │               └── display_alert_view.dart         [DELETE - replaced by alert_layer]
│   └── settings/
│       ├── bloc/settings/
│       │   ├── settings_event.dart              [MODIFY - add new events]
│       │   └── handlers/
│       │       └── design_settings_handler.dart [MODIFY]
│       └── presentation/sections/
│           ├── design_section.dart              [MODIFY - add timing controls]
│           └── photo_studio_section.dart        [CREATE]
```

---

## Task 1: Create Display Layer Kind Enum

**Files:**
- Create: `lib/core/enums/display/display_layer_kind.dart`

- [ ] **Step 1: Create the enum file**

```dart
// lib/core/enums/display/display_layer_kind.dart

/// Priority-based display layers. Lower index = higher priority.
/// Only one layer is visible at a time; the highest-priority active layer wins.
enum DisplayLayerKind {
  alert,          // Priority 1 - fullscreen instant alerts
  photoStudio,    // Priority 2 - fullscreen mosque photo
  iqamaAdhan,     // Priority 3 - pre-adhan, adhan moment, iqama countdown
  religious,      // Priority 4 - hadith/verse/dua/adhkar typewriter
  prayerTimes;    // Priority 5 - default view (prayer cards + header + ticker)

  bool get isFullscreen => this != prayerTimes;
}
```

- [ ] **Step 2: Verify compilation**

Run: `flutter analyze lib/core/enums/display/display_layer_kind.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```
feat: add DisplayLayerKind enum for priority-based layer system
```

---

## Task 2: Extend Prayer Display Phase for Pre-Adhan and Adhan Moment

**Files:**
- Modify: `lib/core/enums/display/prayer_display_phase_kind.dart`
- Modify: `lib/core/utils/prayer_times_helper.dart`
- Modify: `lib/data/models/design/design_settings_model.dart`

- [ ] **Step 1: Add new phase kinds**

In `lib/core/enums/display/prayer_display_phase_kind.dart`, replace the enum:

```dart
enum PrayerDisplayPhaseKind {
  preAdhan,        // Configurable minutes before adhan
  adhanMoment,     // Exact adhan minute
  iqama,           // Between adhan and iqama
  graceAfterIqama, // 1 min after iqama
  nextAdhan,       // Countdown to next adhan (default)
}
```

- [ ] **Step 2: Add timing settings to DesignSettingsModel**

In `lib/data/models/design/design_settings_model.dart`, add these fields to the class:

```dart
// Add to constructor parameters:
this.preAdhanMinutes = 5,
this.adhanMomentDurationSeconds = 60,
this.religiousContentWaitSeconds = 120,
this.religiousContentDisplaySeconds = 30,

// Add field declarations:
final int preAdhanMinutes;
final int adhanMomentDurationSeconds;
final int religiousContentWaitSeconds;
final int religiousContentDisplaySeconds;

// Add to fromMap:
preAdhanMinutes: map['pre_adhan_minutes'] ?? 5,
adhanMomentDurationSeconds: map['adhan_moment_duration_seconds'] ?? 60,
religiousContentWaitSeconds: map['religious_content_wait_seconds'] ?? 120,
religiousContentDisplaySeconds: map['religious_content_display_seconds'] ?? 30,

// Add to toMap:
'pre_adhan_minutes': preAdhanMinutes,
'adhan_moment_duration_seconds': adhanMomentDurationSeconds,
'religious_content_wait_seconds': religiousContentWaitSeconds,
'religious_content_display_seconds': religiousContentDisplaySeconds,

// Add to copyWith:
int? preAdhanMinutes,
int? adhanMomentDurationSeconds,
int? religiousContentWaitSeconds,
int? religiousContentDisplaySeconds,
// ... in return:
preAdhanMinutes: preAdhanMinutes ?? this.preAdhanMinutes,
adhanMomentDurationSeconds: adhanMomentDurationSeconds ?? this.adhanMomentDurationSeconds,
religiousContentWaitSeconds: religiousContentWaitSeconds ?? this.religiousContentWaitSeconds,
religiousContentDisplaySeconds: religiousContentDisplaySeconds ?? this.religiousContentDisplaySeconds,

// Add to props:
preAdhanMinutes, adhanMomentDurationSeconds, religiousContentWaitSeconds, religiousContentDisplaySeconds,
```

- [ ] **Step 3: Update PrayerTimesHelper to detect pre-adhan and adhan moment phases**

In `lib/core/utils/prayer_times_helper.dart`, update `getPrayerDisplayPhase` to accept `preAdhanMinutes`:

```dart
PrayerDisplayPhase getPrayerDisplayPhase(DateTime now, {int preAdhanMinutes = 5}) {
  final timeline = _buildContinuousTimeline(now);

  // 1. Check iqama/grace phases (existing logic stays)
  for (final item in timeline) {
    if (!item.isIqamaApplicable) {
      final postAdhanGrace = item.adhanTime.add(const Duration(minutes: 10));
      if ((now.isAfter(item.adhanTime) || now.isAtSameMomentAs(item.adhanTime)) &&
          now.isBefore(postAdhanGrace)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.iqama,
          prayerNameKey: item.prayerName,
          focusTime: postAdhanGrace,
        );
      }
      continue;
    }

    // Check Adhan Moment (exact minute of adhan)
    if (now.hour == item.adhanTime.hour &&
        now.minute == item.adhanTime.minute &&
        now.day == item.adhanTime.day) {
      return PrayerDisplayPhase(
        kind: PrayerDisplayPhaseKind.adhanMoment,
        prayerNameKey: item.prayerName,
        focusTime: item.adhanTime.add(const Duration(minutes: 1)),
      );
    }

    // Check Iqama countdown
    if ((now.isAfter(item.adhanTime) || now.isAtSameMomentAs(item.adhanTime)) &&
        now.isBefore(item.iqamaTime)) {
      return PrayerDisplayPhase(
        kind: PrayerDisplayPhaseKind.iqama,
        prayerNameKey: item.prayerName,
        focusTime: item.iqamaTime,
      );
    }

    // Check Grace after iqama
    final graceEnd = item.iqamaTime.add(const Duration(minutes: 1));
    if ((now.isAfter(item.iqamaTime) || now.isAtSameMomentAs(item.iqamaTime)) &&
        now.isBefore(graceEnd)) {
      return PrayerDisplayPhase(
        kind: PrayerDisplayPhaseKind.graceAfterIqama,
        prayerNameKey: item.prayerName,
        focusTime: graceEnd,
      );
    }
  }

  // 2. Check Pre-Adhan phase
  if (preAdhanMinutes > 0) {
    for (final item in timeline) {
      if (now.isBefore(item.adhanTime)) {
        final preAdhanStart = item.adhanTime.subtract(Duration(minutes: preAdhanMinutes));
        if (now.isAfter(preAdhanStart) || now.isAtSameMomentAs(preAdhanStart)) {
          return PrayerDisplayPhase(
            kind: PrayerDisplayPhaseKind.preAdhan,
            prayerNameKey: item.prayerName,
            focusTime: item.adhanTime,
          );
        }
        break;
      }
    }
  }

  // 3. Default: next upcoming adhan
  for (final item in timeline) {
    if (now.isBefore(item.adhanTime)) {
      return PrayerDisplayPhase(
        kind: PrayerDisplayPhaseKind.nextAdhan,
        prayerNameKey: item.prayerName,
        focusTime: item.adhanTime,
      );
    }
  }

  return PrayerDisplayPhase(
    kind: PrayerDisplayPhaseKind.nextAdhan,
    prayerNameKey: 'FAJR',
    focusTime: now.add(const Duration(hours: 1)),
  );
}
```

- [ ] **Step 4: Update callers that pass phase.kind to handle new values**

In `lib/features/display/presentation/widgets/prayer/prayer_card_next_strip.dart`, update the switch statement to handle the new phase kinds:

```dart
switch (phase.kind) {
  case PrayerDisplayPhaseKind.iqama:
    subLine = s.display_remaining_to_iqama_line(pAr);
    break;
  case PrayerDisplayPhaseKind.graceAfterIqama:
    subLine = '';
    break;
  case PrayerDisplayPhaseKind.nextAdhan:
  case PrayerDisplayPhaseKind.preAdhan:
    subLine = s.display_remaining_to_adhan_line(pAr);
    break;
  case PrayerDisplayPhaseKind.adhanMoment:
    subLine = '';
    break;
}
```

- [ ] **Step 5: Verify compilation**

Run: `flutter analyze`
Expected: No issues (or only pre-existing ones)

- [ ] **Step 6: Commit**

```
feat: add pre-adhan and adhan moment phases to prayer time system
```

---

## Task 3: Create Display Layer Controller

**Files:**
- Create: `lib/features/display/controller/display_layer_controller.dart`
- Create: `lib/data/models/display/display_layer_state.dart`

- [ ] **Step 1: Create the layer state model**

```dart
// lib/data/models/display/display_layer_state.dart
import 'package:equatable/equatable.dart';
import '../../../core/enums/display/display_layer_kind.dart';

class DisplayLayerState extends Equatable {
  final DisplayLayerKind activeLayer;
  final DisplayLayerKind? previousLayer;

  const DisplayLayerState({
    this.activeLayer = DisplayLayerKind.prayerTimes,
    this.previousLayer,
  });

  DisplayLayerState copyWith({
    DisplayLayerKind? activeLayer,
    DisplayLayerKind? previousLayer,
  }) {
    return DisplayLayerState(
      activeLayer: activeLayer ?? this.activeLayer,
      previousLayer: previousLayer ?? this.previousLayer,
    );
  }

  @override
  List<Object?> get props => [activeLayer, previousLayer];
}
```

- [ ] **Step 2: Create the layer controller**

```dart
// lib/features/display/controller/display_layer_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/enums/display/prayer_display_phase_kind.dart';
import '../../../core/utils/prayer_display_phase.dart';
import '../../../data/models/display/display_layer_state.dart';
import '../../../data/models/mosque/announcement_model.dart';

/// Determines which display layer should be active based on priority.
///
/// Priority order: alert > photoStudio > iqamaAdhan > religious > prayerTimes.
/// Only one layer is visible at a time.
class DisplayLayerController extends ChangeNotifier {
  DisplayLayerState _state = const DisplayLayerState();
  DisplayLayerState get state => _state;

  // --- External inputs ---
  List<AnnouncementModel> _alerts = [];
  PrayerDisplayPhase? _prayerPhase;
  bool _photoStudioActive = false;
  String? _photoStudioUrl;

  // --- Religious content timing ---
  Timer? _religiousTimer;
  bool _religiousVisible = false;
  int _religiousWaitSeconds = 120;
  int _religiousDisplaySeconds = 30;
  int _religiousSlideIndex = 0;
  int get religiousSlideIndex => _religiousSlideIndex;
  bool get religiousVisible => _religiousVisible;

  // --- Photo Studio ---
  String? get photoStudioUrl => _photoStudioUrl;

  void configure({
    required int religiousWaitSeconds,
    required int religiousDisplaySeconds,
  }) {
    final changed = _religiousWaitSeconds != religiousWaitSeconds ||
        _religiousDisplaySeconds != religiousDisplaySeconds;
    _religiousWaitSeconds = religiousWaitSeconds;
    _religiousDisplaySeconds = religiousDisplaySeconds;
    if (changed) _restartReligiousTimer();
  }

  void updateAlerts(List<AnnouncementModel> alerts) {
    _alerts = alerts;
    _resolve();
  }

  void updatePrayerPhase(PrayerDisplayPhase phase) {
    _prayerPhase = phase;
    _resolve();
  }

  void showPhotoStudio(String imageUrl) {
    _photoStudioActive = true;
    _photoStudioUrl = imageUrl;
    _resolve();
  }

  void hidePhotoStudio() {
    _photoStudioActive = false;
    _photoStudioUrl = null;
    _resolve();
  }

  // --- Religious content cycle ---

  void startReligiousCycle() {
    _restartReligiousTimer();
  }

  void _restartReligiousTimer() {
    _religiousTimer?.cancel();
    _religiousVisible = false;
    _scheduleReligiousWait();
    _resolve();
  }

  void _scheduleReligiousWait() {
    _religiousTimer?.cancel();
    _religiousTimer = Timer(Duration(seconds: _religiousWaitSeconds), () {
      _religiousVisible = true;
      _religiousSlideIndex++;
      _resolve();
      _scheduleReligiousDisplay();
    });
  }

  void _scheduleReligiousDisplay() {
    _religiousTimer?.cancel();
    _religiousTimer = Timer(Duration(seconds: _religiousDisplaySeconds), () {
      _religiousVisible = false;
      _resolve();
      _scheduleReligiousWait();
    });
  }

  // --- Active alert check ---

  AnnouncementModel? get activeAlert {
    if (_alerts.isEmpty) return null;
    final now = DateTime.now();
    for (final a in _alerts) {
      final expiry = a.startDate.add(Duration(seconds: a.displayDurationSeconds));
      if (now.isAfter(a.startDate) && now.isBefore(expiry)) return a;
    }
    return null;
  }

  // --- Core resolution ---

  void _resolve() {
    final previous = _state.activeLayer;
    DisplayLayerKind next;

    if (activeAlert != null) {
      next = DisplayLayerKind.alert;
    } else if (_photoStudioActive) {
      next = DisplayLayerKind.photoStudio;
    } else if (_isIqamaAdhanActive()) {
      next = DisplayLayerKind.iqamaAdhan;
    } else if (_religiousVisible) {
      next = DisplayLayerKind.religious;
    } else {
      next = DisplayLayerKind.prayerTimes;
    }

    if (next != previous) {
      _state = DisplayLayerState(activeLayer: next, previousLayer: previous);
      notifyListeners();
    }
  }

  bool _isIqamaAdhanActive() {
    if (_prayerPhase == null) return false;
    switch (_prayerPhase!.kind) {
      case PrayerDisplayPhaseKind.preAdhan:
      case PrayerDisplayPhaseKind.adhanMoment:
      case PrayerDisplayPhaseKind.iqama:
        return true;
      case PrayerDisplayPhaseKind.graceAfterIqama:
      case PrayerDisplayPhaseKind.nextAdhan:
        return false;
    }
  }

  @override
  void dispose() {
    _religiousTimer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze lib/features/display/controller/display_layer_controller.dart`

- [ ] **Step 4: Commit**

```
feat: add DisplayLayerController for priority-based content management
```

---

## Task 4: Create Layer Transition Wrapper Widget

**Files:**
- Create: `lib/features/display/presentation/widgets/layers/layer_transition_wrapper.dart`

- [ ] **Step 1: Create animated transition wrapper**

```dart
// lib/features/display/presentation/widgets/layers/layer_transition_wrapper.dart
import 'package:flutter/material.dart';
import '../../../../../core/enums/display/display_layer_kind.dart';

/// Wraps the active layer with smooth fade + slide transitions.
/// Uses AnimatedSwitcher with a unique key per layer kind.
class LayerTransitionWrapper extends StatelessWidget {
  final DisplayLayerKind activeLayer;
  final Widget child;
  final Duration duration;

  const LayerTransitionWrapper({
    super.key,
    required this.activeLayer,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(activeLayer),
        child: child,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```
feat: add LayerTransitionWrapper for smooth layer switching
```

---

## Task 5: Create Iqama/Adhan Fullscreen Layer

**Files:**
- Create: `lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart`

- [ ] **Step 1: Create the iqama/adhan overlay widget**

```dart
// lib/features/display/presentation/widgets/layers/iqama_adhan_layer.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../../core/enums/display/prayer_display_phase_kind.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';

/// Fullscreen overlay shown during pre-adhan countdown, adhan moment, and iqama countdown.
class IqamaAdhanLayer extends StatelessWidget {
  final PrayerDisplayPhase phase;
  final Duration remaining;
  final DesignSettingsModel designSettings;
  final bool isFriday;

  const IqamaAdhanLayer({
    super.key,
    required this.phase,
    required this.remaining,
    required this.designSettings,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = designSettings.colors;
    final fontFamily = designSettings.fontFamily;
    final fmt = designSettings.numeralFormat;

    final slot = PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey);
    String prayerName = slot?.labelAr(s) ?? phase.prayerNameKey;

    // Friday Dhuhr → صلاة الجمعة
    if (isFriday && phase.prayerNameKey.toUpperCase() == 'DHUHR') {
      prayerName = s.prayer_jummah;
    }

    final r = remaining.isNegative ? Duration.zero : remaining;
    final timeStr = PrayerTimesHelper.formatDuration(r).formatNumerals(fmt);

    late String title;
    late String? subtitle;
    late IconData icon;

    switch (phase.kind) {
      case PrayerDisplayPhaseKind.preAdhan:
        title = s.display_remaining_to_adhan_line(prayerName);
        subtitle = timeStr;
        icon = Icons.access_time_rounded;
        break;
      case PrayerDisplayPhaseKind.adhanMoment:
        final isSunrise = phase.isSunrise;
        title = isSunrise
            ? s.display_sunrise_now
            : s.display_adhan_now(prayerName);
        subtitle = null;
        icon = Icons.notifications_active_rounded;
        break;
      case PrayerDisplayPhaseKind.iqama:
        title = s.display_remaining_to_iqama_line(prayerName);
        subtitle = timeStr;
        icon = Icons.mosque_rounded;
        break;
      default:
        title = '';
        subtitle = null;
        icon = Icons.access_time;
    }

    return Scaffold(
      backgroundColor: colors.activeCardValue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: colors.activeCardTextValue.withValues(alpha: 0.7)),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: colors.activeCardTextValue,
                  height: 1.3,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 24),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    color: colors.activeCardTextValue,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add localization keys**

In `lib/core/l10n/intl_ar.arb`, add:
```json
"display_adhan_now": "حان الآن موعد أذان {prayer}",
"display_sunrise_now": "حان الآن موعد الشروق",
"prayer_jummah": "صلاة الجمعة"
```

In `lib/core/l10n/intl_en.arb`, add:
```json
"display_adhan_now": "It is now time for {prayer} Adhan",
"display_sunrise_now": "It is now Sunrise time",
"prayer_jummah": "Jumu'ah Prayer"
```

Run: `dart run intl_utils:generate`

- [ ] **Step 3: Commit**

```
feat: add IqamaAdhanLayer with pre-adhan, adhan moment, and iqama countdown
```

---

## Task 6: Create Religious Content Fullscreen Layer

**Files:**
- Create: `lib/features/display/presentation/widgets/layers/religious_content_layer.dart`

- [ ] **Step 1: Create fullscreen typewriter religious content widget**

```dart
// lib/features/display/presentation/widgets/layers/religious_content_layer.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../../../data/models/mosque/mosque_text_entry_model.dart';
import '../../../../../data/models/mosque_text_list_kind.dart';

/// Fullscreen overlay showing religious content (hadith/verse/dua/adhkar)
/// with typewriter character-by-character animation filling the screen.
class ReligiousContentLayer extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final int slideIndex;

  const ReligiousContentLayer({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.slideIndex,
  });

  @override
  State<ReligiousContentLayer> createState() => _ReligiousContentLayerState();
}

class _ReligiousContentLayerState extends State<ReligiousContentLayer> {
  final math.Random _random = math.Random();
  Timer? _typeTimer;
  int _charCount = 0;
  late _ContentSlide _slide;

  @override
  void initState() {
    super.initState();
    _slide = _pickSlide();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant ReligiousContentLayer old) {
    super.didUpdateWidget(old);
    if (old.slideIndex != widget.slideIndex) {
      _slide = _pickSlide();
      _charCount = 0;
      _startTyping();
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    super.dispose();
  }

  _ContentSlide _pickSlide() {
    final pool = <_ContentSlide>[];
    void add(MosqueTextListKind kind, List<MosqueTextEntryModel> list) {
      for (final e in list.where((e) => e.isActive && e.text.trim().isNotEmpty)) {
        pool.add(_ContentSlide(kind: kind, item: e));
      }
    }
    add(MosqueTextListKind.hadith, widget.mosque.hadiths);
    add(MosqueTextListKind.verse, widget.mosque.verses);
    add(MosqueTextListKind.dua, widget.mosque.duas);
    add(MosqueTextListKind.adhkar, widget.mosque.adhkar);
    if (pool.isEmpty) {
      return _ContentSlide(
        kind: MosqueTextListKind.hadith,
        item: MosqueTextEntryModel(id: '', narrator: '', text: '', source: '', isActive: true, order: 0),
      );
    }
    return pool[_random.nextInt(pool.length)];
  }

  void _startTyping() {
    _typeTimer?.cancel();
    final fullText = _slide.fullText;
    if (fullText.isEmpty) return;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 35), (_) {
      if (!mounted) return;
      if (_charCount >= fullText.length) {
        _typeTimer?.cancel();
        return;
      }
      setState(() => _charCount++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = widget.designSettings.colors;
    final fontFamily = widget.designSettings.fontFamily;
    final fmt = widget.designSettings.numeralFormat;

    final fullText = _slide.fullText.formatNumerals(fmt);
    final visibleText = fullText.substring(0, _charCount.clamp(0, fullText.length));

    final kindLabel = _labelForKind(_slide.kind, s);

    return Scaffold(
      backgroundColor: colors.primaryValue,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.secondaryValue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                kindLabel,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.secondaryValue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  visibleText,
                  textAlign: TextAlign.start,
                  style: AppFontLoader.getStyle(
                    fontFamily,
                    baseStyle: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: colors.secondaryValue,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            if (_slide.item.source.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Text(
                    _slide.item.source.formatNumerals(fmt),
                    style: AppFontLoader.getStyle(
                      fontFamily,
                      baseStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colors.secondaryValue.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _labelForKind(MosqueTextListKind kind, S s) {
    switch (kind) {
      case MosqueTextListKind.hadith:
        return s.display_ticker_hadith;
      case MosqueTextListKind.verse:
        return s.display_ticker_verse;
      case MosqueTextListKind.dua:
        return s.display_ticker_dua;
      case MosqueTextListKind.adhkar:
        return s.display_ticker_adhkar;
    }
  }
}

class _ContentSlide {
  final MosqueTextListKind kind;
  final MosqueTextEntryModel item;

  const _ContentSlide({required this.kind, required this.item});

  String get fullText {
    final b = StringBuffer();
    if (item.narrator.isNotEmpty) {
      b.write(item.narrator);
      b.write(' — ');
    }
    b.write(item.text);
    return b.toString();
  }
}
```

- [ ] **Step 2: Commit**

```
feat: add ReligiousContentLayer with fullscreen typewriter animation
```

---

## Task 7: Create Alert Layer (Refined)

**Files:**
- Create: `lib/features/display/presentation/widgets/layers/alert_layer.dart`

- [ ] **Step 1: Create refined alert layer with smaller icon**

```dart
// lib/features/display/presentation/widgets/layers/alert_layer.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../core/enums/app_numeral_format.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../data/models/mosque/announcement_model.dart';

/// Fullscreen alert overlay - highest priority layer.
/// Refined design: smaller icon, cleaner typography, better spacing.
class AlertLayer extends StatefulWidget {
  final List<AnnouncementModel> alerts;
  final Color primaryColor;
  final Color backgroundColor;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;
  final VoidCallback onExpired;

  const AlertLayer({
    super.key,
    required this.alerts,
    required this.primaryColor,
    required this.backgroundColor,
    required this.numeralFormat,
    required this.fontFamily,
    required this.onExpired,
  });

  @override
  State<AlertLayer> createState() => _AlertLayerState();
}

class _AlertLayerState extends State<AlertLayer> {
  Timer? _timer;
  AnnouncementModel? _activeAlert;

  @override
  void initState() {
    super.initState();
    _updateActiveAlert();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateActiveAlert());
  }

  @override
  void didUpdateWidget(covariant AlertLayer old) {
    super.didUpdateWidget(old);
    if (old.alerts != widget.alerts) _updateActiveAlert();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateActiveAlert() {
    if (widget.alerts.isEmpty) {
      if (_activeAlert != null) {
        setState(() => _activeAlert = null);
        widget.onExpired();
      }
      return;
    }
    final now = DateTime.now();
    AnnouncementModel? found;
    for (final a in widget.alerts) {
      final expiry = a.startDate.add(Duration(seconds: a.displayDurationSeconds));
      if (now.isAfter(a.startDate) && now.isBefore(expiry)) {
        found = a;
        break;
      }
    }
    if (found?.id != _activeAlert?.id) {
      setState(() => _activeAlert = found);
      if (found == null) widget.onExpired();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _activeAlert;
    if (alert == null) return const SizedBox.shrink();

    final title = alert.title.formatNumerals(widget.numeralFormat);
    final subtitle = alert.subtitle?.formatNumerals(widget.numeralFormat);

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: 64,
                  color: widget.primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontLoader.getStyle(
                  widget.fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: widget.primaryColor,
                    height: 1.2,
                  ),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppFontLoader.getStyle(
                    widget.fontFamily,
                    baseStyle: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w500,
                      color: widget.primaryColor.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```
feat: add AlertLayer with refined smaller icon and cleaner layout
```

---

## Task 8: Create Photo Studio Layer

**Files:**
- Create: `lib/features/display/presentation/widgets/layers/photo_studio_layer.dart`

- [ ] **Step 1: Create fullscreen photo display layer**

```dart
// lib/features/display/presentation/widgets/layers/photo_studio_layer.dart
import 'package:flutter/material.dart';

/// Fullscreen photo display overlay (priority 2).
/// Shows a single image from URL with configurable fit.
class PhotoStudioLayer extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Color backgroundColor;

  const PhotoStudioLayer({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Image.network(
          imageUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                color: Colors.white70,
              ),
            );
          },
          errorBuilder: (context, error, stack) {
            return const Center(
              child: Icon(Icons.broken_image_rounded, size: 80, color: Colors.white38),
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```
feat: add PhotoStudioLayer for fullscreen mosque photo display
```

---

## Task 9: Refactor Prayer Cards - Remove Remaining Time, Add Slider Sizing

**Files:**
- Rewrite: `lib/features/display/presentation/widgets/prayer/display_prayer_card.dart`
- Create: `lib/features/display/presentation/widgets/prayer/prayer_cards_row.dart`
- Modify: `lib/features/display/presentation/widgets/content/display_beige_area.dart`
- Delete old: `lib/features/display/presentation/widgets/prayer/prayer_card_next_strip.dart`
- Delete old: `lib/features/display/presentation/widgets/content/display_spiritual_strip.dart`
- Delete old: `lib/features/display/presentation/widgets/content/typing_text_column.dart`

- [ ] **Step 1: Rewrite DisplayPrayerCard - clean, centered, no remaining time**

The new prayer card shows ONLY: icon + Arabic name + English name + time. No countdown strip. All content is centered vertically and horizontally.

```dart
// lib/features/display/presentation/widgets/prayer/display_prayer_card.dart
import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/app_time_format.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';
import 'prayer_card_background.dart';

class DisplayPrayerCard extends StatefulWidget {
  final PrayerDisplaySlot slot;
  final DateTime azanTime;
  final bool isFocusCard;
  final bool isBlinking;
  final DesignSettingsModel designSettings;
  final double prayersFontSize;
  final bool isFriday;

  const DisplayPrayerCard({
    super.key,
    required this.slot,
    required this.azanTime,
    required this.isFocusCard,
    required this.isBlinking,
    required this.designSettings,
    required this.prayersFontSize,
    this.isFriday = false,
  });

  @override
  State<DisplayPrayerCard> createState() => _DisplayPrayerCardState();
}

class _DisplayPrayerCardState extends State<DisplayPrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCirc,
    );
    if (widget.isBlinking) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant DisplayPrayerCard old) {
    super.didUpdateWidget(old);
    if (widget.isBlinking != old.isBlinking) {
      if (widget.isBlinking) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = widget.designSettings.colors;

    return LayoutBuilder(builder: (context, constraints) {
      final maxH = constraints.maxHeight;
      final maxW = constraints.maxWidth;
      final compactFactor = ((maxH / 275.0).clamp(0.02, 1.0).clamp(0.0, 1.0) * 1.06).clamp(0.0, 1.0);

      final gap = (12.0 * compactFactor).clamp(0.0, maxH * 0.07);
      final iconSize = (42.0 * compactFactor).clamp(0.0, maxH * 0.30);
      final arSize = (widget.prayersFontSize * 1.88 * compactFactor).clamp(9.0, 36.0);
      final enSize = (widget.prayersFontSize * 1.22 * compactFactor).clamp(8.0, 26.0);
      final timeSize = (widget.prayersFontSize * 2.1 * compactFactor).clamp(10.0, 48.0);

      final cardColor = widget.isFocusCard ? colors.activeCardValue : colors.prayerOverlayValue;
      final textColor = widget.isFocusCard ? colors.activeCardTextValue : colors.inactiveCardTextValue;

      final fmt = widget.designSettings.numeralFormat;
      final formattedTime = AppTimeFormat.time12h(context, widget.azanTime).formatNumerals(fmt);
      final fontFamily = widget.designSettings.fontFamily;

      // Friday Dhuhr → صلاة الجمعة
      String arLabel = widget.slot.labelAr(s);
      String enLabel = widget.slot.labelEn(s);
      if (widget.isFriday && widget.slot == PrayerDisplaySlot.dhuhr) {
        arLabel = s.prayer_jummah;
        enLabel = "Jumu'ah";
      }

      final column = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.slot.icon, size: iconSize, color: textColor.withValues(alpha: 0.85)),
          SizedBox(height: gap),
          Text(
            arLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: arSize, fontWeight: FontWeight.bold, color: textColor)),
          ),
          Text(
            enLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: enSize, color: textColor.withValues(alpha: 0.72))),
          ),
          SizedBox(height: gap),
          Text(
            formattedTime,
            maxLines: 1,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: timeSize, fontWeight: FontWeight.bold, color: textColor)),
          ),
        ],
      );

      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulseVal = _pulseAnimation.value;
          final glowColor = Colors.white.withValues(alpha: 0.45 * pulseVal);
          final animatedCardColor = Color.lerp(cardColor, Colors.white, 0.12 * pulseVal)!;

          return Stack(
            children: [
              PrayerCardBackground(
                prayerCardColor: animatedCardColor,
                child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: child)),
              ),
              if (widget.isBlinking)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: glowColor, width: 3.5 * pulseVal),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.3 * pulseVal),
                            blurRadius: 15 * pulseVal,
                            spreadRadius: 2 * pulseVal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: column,
      );
    });
  }
}
```

- [ ] **Step 2: Create PrayerCardsRow with slider-based sizing for next prayer**

```dart
// lib/features/display/presentation/widgets/prayer/prayer_cards_row.dart
import 'package:flutter/material.dart';

import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';
import 'display_prayer_card.dart';

/// A row of 6 prayer cards where the "focus" card (next prayer) is proportionally
/// larger than the rest. The size ratio is controlled by [focusScale].
class PrayerCardsRow extends StatelessWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final PrayerTimesHelper helper;
  final DateTime now;
  final double focusScale;

  const PrayerCardsRow({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.helper,
    required this.now,
    this.focusScale = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    final today = helper.buildAdjustedPrayerTimes(now);
    final preAdhanMin = designSettings.preAdhanMinutes;
    final phase = helper.getPrayerDisplayPhase(now, preAdhanMinutes: preAdhanMin);
    final slots = PrayerDisplaySlot.values;
    final isFriday = now.weekday == DateTime.friday;

    return LayoutBuilder(builder: (context, outer) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: slots.map((slot) {
          final azanTime = _azanTimeForSlot(now, today, slot, helper);
          final isFocusCard = _cardMatchesPhase(slot, phase);
          final isBlinking = (now.hour == azanTime.hour &&
                  now.minute == azanTime.minute &&
                  now.day == azanTime.day) ||
              (isFocusCard && phase.kind == PrayerDisplayPhaseKind.graceAfterIqama);

          final flex = isFocusCard ? (focusScale * 10).round() : 10;

          return Expanded(
            flex: flex,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (outer.maxWidth * 0.006).clamp(3.0, 10.0),
              ),
              child: DisplayPrayerCard(
                slot: slot,
                azanTime: azanTime,
                isFocusCard: isFocusCard,
                isBlinking: isBlinking,
                designSettings: designSettings,
                prayersFontSize: designSettings.fontSizes.prayers,
                isFriday: isFriday,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  static bool _cardMatchesPhase(PrayerDisplaySlot slot, PrayerDisplayPhase phase) {
    return PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey) == slot;
  }

  static DateTime _azanTimeForSlot(
    DateTime now,
    AdjustedPrayerTimes today,
    PrayerDisplaySlot slot,
    PrayerTimesHelper helper,
  ) {
    final todayItem = today.getByPrayerName(slot.name.toUpperCase());
    if (todayItem == null) return now;
    final cutoff = todayItem.iqamaTime.add(const Duration(minutes: 1));
    if (now.isAfter(cutoff)) {
      final tomorrow = helper.buildAdjustedPrayerTimes(now.add(const Duration(days: 1)));
      return tomorrow.getByPrayerName(slot.name.toUpperCase())?.adhanTime ?? todayItem.adhanTime;
    }
    return todayItem.adhanTime;
  }
}
```

- [ ] **Step 3: Delete old files that are no longer needed**

Delete these files:
- `lib/features/display/presentation/widgets/prayer/prayer_card_next_strip.dart`
- `lib/features/display/presentation/widgets/content/display_spiritual_strip.dart`
- `lib/features/display/presentation/widgets/content/typing_text_column.dart`
- `lib/features/display/presentation/widgets/alerts/display_alert_view.dart`

- [ ] **Step 4: Rewrite DisplayBeigeArea - only prayer cards, no spiritual strip**

```dart
// lib/features/display/presentation/widgets/content/display_beige_area.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/mosque/mosque_model.dart';
import '../prayer/prayer_cards_row.dart';

class DisplayBeigeArea extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;

  const DisplayBeigeArea({
    super.key,
    required this.mosque,
    required this.designSettings,
  });

  @override
  State<DisplayBeigeArea> createState() => _DisplayBeigeAreaState();
}

class _DisplayBeigeAreaState extends State<DisplayBeigeArea> {
  late Timer _timer;
  late PrayerTimesHelper _helper;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _helper = PrayerTimesHelper(widget.mosque);
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _helper = PrayerTimesHelper(widget.mosque);
      });
    });
  }

  @override
  void didUpdateWidget(covariant DisplayBeigeArea old) {
    super.didUpdateWidget(old);
    if (old.mosque != widget.mosque) _helper = PrayerTimesHelper(widget.mosque);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.designSettings;
    return LayoutBuilder(builder: (context, outer) {
      final hPad = (outer.maxWidth * 0.012).clamp(6.0, 22.0);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Center(
          child: PrayerCardsRow(
            mosque: widget.mosque,
            designSettings: design,
            helper: _helper,
            now: _now,
            focusScale: 1.3,
          ),
        ),
      );
    });
  }
}
```

- [ ] **Step 5: Commit**

```
feat: refactor prayer cards - remove countdown strip, add slider sizing, center content
```

---

## Task 10: Rewrite Display Screen with Layer System

**Files:**
- Rewrite: `lib/features/display/presentation/display_screen.dart`

- [ ] **Step 1: Rewrite the display screen to use DisplayLayerController**

```dart
// lib/features/display/presentation/display_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/display/display_layer_kind.dart';
import '../../../core/enums/display_background_preset.dart';
import '../../../core/enums/display_background_type.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_theme.dart';
import '../../../core/utils/prayer_times_helper.dart';
import '../../../core/widgets/media/media_widgets.dart';
import '../../../data/models/mosque/mosque_model.dart';
import '../../../core/enums/app_mode.dart';
import '../../auth/repository/auth_repository.dart';
import '../bloc/display_bloc.dart';
import '../controller/display_layer_controller.dart';
import 'widgets/background/background_widgets.dart';
import 'widgets/content/content_widgets.dart';
import 'widgets/header/header_widgets.dart';
import 'widgets/layers/alert_layer.dart';
import 'widgets/layers/iqama_adhan_layer.dart';
import 'widgets/layers/layer_transition_wrapper.dart';
import 'widgets/layers/photo_studio_layer.dart';
import 'widgets/layers/religious_content_layer.dart';
import 'widgets/ticker/ticker_widgets.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  Timer? _tickTimer;
  final DisplayLayerController _layerController = DisplayLayerController();
  late PrayerTimesHelper _helper;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _layerController.addListener(_onLayerChange);
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _now = DateTime.now();
      _updateLayerInputs();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _layerController.removeListener(_onLayerChange);
    _layerController.dispose();
    super.dispose();
  }

  void _onLayerChange() {
    if (mounted) setState(() {});
  }

  void _updateLayerInputs() {
    final state = context.read<DisplayBloc>().state;
    if (state is! DisplayLoaded) return;
    final mosque = state.mosque;
    final design = mosque.designSettings;

    _helper = PrayerTimesHelper(mosque);
    final phase = _helper.getPrayerDisplayPhase(_now, preAdhanMinutes: design.preAdhanMinutes);

    _layerController.configure(
      religiousWaitSeconds: design.religiousContentWaitSeconds,
      religiousDisplaySeconds: design.religiousContentDisplaySeconds,
    );
    _layerController.updateAlerts(mosque.activeAlerts);
    _layerController.updatePrayerPhase(phase);
  }

  void _backToSettings(BuildContext context) async {
    await AuthRepository.setAppModeOverride(AppMode.mobileSettings);
    if (!context.mounted) return;
    context.go(Routes.settingsPath);
  }

  void _precacheBackgrounds(MosqueModel mosque) {
    final d = mosque.designSettings;
    if (d.background.type == DisplayBackgroundType.image) {
      final path = DisplayBackgroundPreset.fromStorageId(d.background.value).assetPath;
      final media = MediaQuery.of(context);
      final cappedWidth = (media.size.width * media.devicePixelRatio).round().clamp(0, 1920);
      precacheOptimizedAsset(context, path, cacheWidth: cappedWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DisplayBloc, DisplayState>(
        builder: (context, state) {
          if (state is DisplayLoading || state is DisplayInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DisplayError) {
            final s = S.of(context);
            final msg = state.message == 'no_mosque' ? s.display_error_no_mosque : state.message;
            return Center(child: Text(msg, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center));
          }
          if (state is! DisplayLoaded) return const SizedBox.shrink();

          final mosque = state.mosque;
          final design = mosque.designSettings;
          final colors = design.colors;
          final activeLayer = _layerController.state.activeLayer;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _precacheBackgrounds(mosque);
              _updateLayerInputs();
              _layerController.startReligiousCycle();
            }
          });

          final theme = AppTheme.light(context, fontFamily: design.fontFamily);

          return Theme(
            data: theme,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base: Background + Prayer Times (always rendered)
                _buildBaseLayer(context, mosque, state),

                // Overlay: Active higher-priority layer
                if (activeLayer != DisplayLayerKind.prayerTimes)
                  LayerTransitionWrapper(
                    activeLayer: activeLayer,
                    child: _buildOverlayLayer(activeLayer, mosque, design, colors),
                  ),

                _buildSettingsShortcut(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseLayer(BuildContext context, MosqueModel mosque, DisplayLoaded state) {
    final design = mosque.designSettings;
    final colors = design.colors;
    final media = MediaQuery.sizeOf(context);
    final padH = (media.width * 0.028).clamp(14.0, 64.0);
    final padV = (media.height * 0.022).clamp(8.0, 36.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DisplayBackgroundImage(
            fallbackColor: colors.primaryValue,
            settings: design.background,
          ),
        ),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                        child: TopHeaderWidget(mosque: mosque, designSettings: design),
                      ),
                      Expanded(
                        child: DisplayBeigeArea(mosque: mosque, designSettings: design),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                minimum: EdgeInsets.zero,
                child: DisplayTickerBar(
                  mosque: mosque,
                  platformAnnouncements: state.platformAnnouncements,
                  appSettings: state.appSettings,
                  currentVersion: state.currentVersion,
                  primaryColor: colors.secondaryValue,
                  fontSize: design.fontSizes.announcements,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayLayer(
    DisplayLayerKind layer,
    MosqueModel mosque,
    dynamic design,
    dynamic colors,
  ) {
    switch (layer) {
      case DisplayLayerKind.alert:
        return AlertLayer(
          alerts: mosque.activeAlerts,
          primaryColor: colors.activeCardTextValue,
          backgroundColor: colors.activeCardValue,
          numeralFormat: design.numeralFormat,
          fontFamily: design.fontFamily,
          onExpired: () => setState(() {}),
        );
      case DisplayLayerKind.photoStudio:
        return PhotoStudioLayer(
          imageUrl: _layerController.photoStudioUrl ?? '',
          backgroundColor: colors.primaryValue,
        );
      case DisplayLayerKind.iqamaAdhan:
        final helper = PrayerTimesHelper(mosque);
        final phase = helper.getPrayerDisplayPhase(_now, preAdhanMinutes: design.preAdhanMinutes);
        final remaining = phase.focusTime.difference(_now);
        return IqamaAdhanLayer(
          phase: phase,
          remaining: remaining,
          designSettings: design,
          isFriday: _now.weekday == DateTime.friday,
        );
      case DisplayLayerKind.religious:
        return ReligiousContentLayer(
          mosque: mosque,
          designSettings: design,
          slideIndex: _layerController.religiousSlideIndex,
        );
      case DisplayLayerKind.prayerTimes:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSettingsShortcut() {
    return Positioned(
      top: 10,
      right: 10,
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.transparent),
        onPressed: () => _backToSettings(context),
        tooltip: S.of(context).sign_out_tooltip,
      ),
    );
  }
}
```

- [ ] **Step 2: Update barrel files if any exist for the widgets directories**

Check and update any exports in `content_widgets.dart`, `alerts_widgets.dart`, etc.

- [ ] **Step 3: Verify compilation**

Run: `flutter analyze`

- [ ] **Step 4: Commit**

```
feat: rewrite display screen with priority-based layer system
```

---

## Task 11: Add Remote Background Support

**Files:**
- Modify: `lib/data/models/design/design_background_settings.dart`
- Modify: `lib/core/enums/display_background_type.dart`
- Modify: `lib/features/display/presentation/widgets/background/display_background_image.dart`

- [ ] **Step 1: Add `remoteUrl` background type**

In `lib/core/enums/display_background_type.dart`, add:

```dart
enum DisplayBackgroundType {
  image,     // Local asset preset
  color,     // Solid color hex
  remoteUrl; // URL from Firebase/Drive or user custom

  // Update fromCode to handle 'remote_url'
}
```

- [ ] **Step 2: Update DesignBackgroundSettings**

The `value` field already holds the relevant data. For `remoteUrl`, it will hold the URL string.

- [ ] **Step 3: Update DisplayBackgroundImage to handle remote URLs**

Add a branch for `remoteUrl` type that uses `Image.network` with caching via the `cacheWidth`/`cacheHeight` parameters and error handling.

- [ ] **Step 4: Commit**

```
feat: add remote URL background support with network image fallback
```

---

## Task 12: Add Photo Studio Data to Mosque Model

**Files:**
- Modify: `lib/data/models/mosque/mosque_model.dart`

- [ ] **Step 1: Add photo studio URLs list to MosqueModel**

Add to the class:
```dart
final List<String> photoStudioUrls;
```

Add to constructor with default `const []`, add to `fromMap`:
```dart
photoStudioUrls: (map['photo_studio_urls'] as List<dynamic>?)
    ?.map((e) => e.toString())
    .toList() ?? [],
```

Add to `toMap`, `copyWith`, and `props`.

- [ ] **Step 2: Commit**

```
feat: add photo studio URLs to mosque model
```

---

## Task 13: Add Settings Events and UI for New Configurations

**Files:**
- Modify: `lib/features/settings/bloc/settings/settings_event.dart`
- Modify: `lib/features/settings/bloc/settings/handlers/design_settings_handler.dart`
- Modify: `lib/features/settings/presentation/sections/design_section.dart`

- [ ] **Step 1: Add new settings events**

In `settings_event.dart`, add:

```dart
class SettingsPreAdhanMinutesChanged extends SettingsEvent {
  final int minutes;
  const SettingsPreAdhanMinutesChanged(this.minutes);
  @override
  List<Object?> get props => [minutes];
}

class SettingsAdhanMomentDurationChanged extends SettingsEvent {
  final int seconds;
  const SettingsAdhanMomentDurationChanged(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class SettingsReligiousContentWaitChanged extends SettingsEvent {
  final int seconds;
  const SettingsReligiousContentWaitChanged(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class SettingsReligiousContentDisplayChanged extends SettingsEvent {
  final int seconds;
  const SettingsReligiousContentDisplayChanged(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class SettingsPhotoStudioUrlAdded extends SettingsEvent {
  final String url;
  const SettingsPhotoStudioUrlAdded(this.url);
  @override
  List<Object?> get props => [url];
}

class SettingsPhotoStudioUrlRemoved extends SettingsEvent {
  final String url;
  const SettingsPhotoStudioUrlRemoved(this.url);
  @override
  List<Object?> get props => [url];
}

class SettingsBackgroundCustomUrlChanged extends SettingsEvent {
  final String url;
  const SettingsBackgroundCustomUrlChanged(this.url);
  @override
  List<Object?> get props => [url];
}
```

- [ ] **Step 2: Handle new events in design settings handler**

Update `design_settings_handler.dart` to handle the new events by updating the relevant fields in `DesignSettingsModel` via `copyWith`.

- [ ] **Step 3: Add UI controls in design_section.dart**

Add sliders/number fields for:
- Pre-adhan countdown minutes (1-30)
- Adhan moment display duration (30-120 seconds)
- Religious content wait interval (30-600 seconds)
- Religious content display duration (10-120 seconds)
- Custom background URL text field

- [ ] **Step 4: Commit**

```
feat: add settings for timing controls and custom background URL
```

---

## Task 14: Update Logo and App Name

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/styles/app_theme.dart` (if app name is defined there)
- Update: `assets/logo.png` (already exists as the new logo)

- [ ] **Step 1: Update pubspec.yaml launcher icon path and app name**

Change:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/logo.png
```

- [ ] **Step 2: Update any hardcoded app name references to "تبيان"**

Search for "mounir" or old app name references and replace with "تبيان" / "Tebyan".

- [ ] **Step 3: Update color scheme from gold to green**

In `lib/data/models/design/design_color_settings.dart`, update default colors to use green tones matching the logo (the dark teal `#1B5E3B` or similar flat green):

```dart
const DesignColorSettings({
  this.primary = '#1B5E3B',      // Dark green (flat, from logo)
  this.secondary = '#E8F5E9',    // Light green tint
  this.activeCard = '#C8E6C9',   // Soft green card
  this.activeCardText = '#1B5E3B', // Dark green text
  this.prayerOverlay = '#E8F5E9', // Light green overlay
  this.inactiveCardText = '#2E7D32', // Medium green
});
```

- [ ] **Step 4: Run icon generation**

Run: `dart run flutter_launcher_icons`

- [ ] **Step 5: Commit**

```
feat: update logo to تبيان, rename app, switch to green color scheme
```

---

## Task 15: Update Barrel Files and Clean Up Imports

**Files:**
- Modify: Various barrel/export files
- Delete: Unused files

- [ ] **Step 1: Update content_widgets.dart barrel**

Remove exports for `display_spiritual_strip.dart` and `typing_text_column.dart`.

- [ ] **Step 2: Update alerts_widgets.dart barrel**

Remove export for `display_alert_view.dart`.

- [ ] **Step 3: Create layers barrel file**

```dart
// lib/features/display/presentation/widgets/layers/layers_widgets.dart
export 'alert_layer.dart';
export 'iqama_adhan_layer.dart';
export 'layer_transition_wrapper.dart';
export 'photo_studio_layer.dart';
export 'religious_content_layer.dart';
```

- [ ] **Step 4: Run flutter analyze and fix any import issues**

Run: `flutter analyze`
Fix any broken imports.

- [ ] **Step 5: Commit**

```
refactor: clean up barrel files, remove dead code, fix imports
```

---

## Task 16: Final Integration Test

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 2: Run the app**

Run: `flutter run`
Verify:
1. Prayer times display correctly centered with no countdown strip
2. Focus card is slightly larger than others
3. Religious content appears after wait period with typewriter animation
4. Friday Dhuhr shows "صلاة الجمعة"
5. Layer transitions are smooth fade in/out
6. Settings icon still works to navigate back

- [ ] **Step 3: Commit final**

```
feat: complete Tebyan major refactor with priority layer system
```

---

## Summary of Changes

| Area | Before | After |
|------|--------|-------|
| **Architecture** | Flat Stack with alert override | Priority-based layer controller |
| **Religious Content** | Small strip below prayers | Fullscreen typewriter with timed intervals |
| **Prayer Cards** | Countdown in focus card | Clean centered cards, focus via flex sizing |
| **Iqama/Adhan** | Countdown inside prayer card | Fullscreen overlay with large timer |
| **Pre-Adhan** | None | Configurable fullscreen countdown |
| **Adhan Moment** | Blinking card | Fullscreen "حان الآن موعد أذان X" |
| **Friday Dhuhr** | "الظهر" | "صلاة الجمعة" |
| **Alerts** | Icon 140px | Icon 64px, cleaner layout |
| **Backgrounds** | Local assets only | Remote URLs + local cache |
| **Photo Studio** | None | Fullscreen photo display from URLs |
| **Logo** | logo.jpg gold | logo.png green flat "تبيان" |
| **Settings** | Limited | Timing controls for all layers |
