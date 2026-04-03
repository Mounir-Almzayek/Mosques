import '../enums/display/prayer_display_phase_kind.dart';

export '../enums/display/prayer_display_phase_kind.dart';

/// Current display phase: which prayer is in focus, the kind of countdown,
/// and the target time for the countdown.
class PrayerDisplayPhase {
  final PrayerDisplayPhaseKind kind;

  /// Uppercase prayer key from the adhan package, e.g. `FAJR`, `DHUHR`.
  final String prayerNameKey;

  /// The time the countdown is targeting (iqama time or next adhan time).
  final DateTime focusTime;

  const PrayerDisplayPhase({
    required this.kind,
    required this.prayerNameKey,
    required this.focusTime,
  });

  bool get isSunrise => prayerNameKey.toUpperCase().contains('SUNRISE');
}
