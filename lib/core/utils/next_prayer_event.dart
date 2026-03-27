/// Typed model for the next prayer event (replaces `Map<String, dynamic>`).
///
/// Used by [PrayerTimesHelper.getNextEvent] and the display/clock widgets
/// to determine what countdown to show.
class NextPrayerEvent {
  /// Whether this event is an iqama countdown (vs. next adhan countdown).
  final bool isIqama;

  /// The time the countdown is targeting.
  final DateTime targetTime;

  /// Uppercase prayer key, e.g. `FAJR`, `DHUHR`, or `FAJR_TOMORROW`.
  final String prayerName;

  const NextPrayerEvent({
    required this.isIqama,
    required this.targetTime,
    required this.prayerName,
  });
}
