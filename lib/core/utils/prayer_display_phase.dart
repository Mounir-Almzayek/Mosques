/// Represents the three display phases during a prayer cycle.
enum PrayerDisplayPhaseKind {
  /// Between adhan and iqama — counting down to iqama.
  iqama,

  /// 1-minute grace period after iqama (silent/dimmed UI).
  graceAfterIqama,

  /// Counting down to the next adhan.
  nextAdhan,
}

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
}
