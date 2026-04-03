import 'package:adhan/adhan.dart';

import '../../data/models/display/adjusted_prayer_times.dart';
import '../../data/models/display/prayer_time_item.dart';
import '../../data/models/mosque/mosque_model.dart';
import '../../data/models/prayer_display_slot.dart';
import 'next_prayer_event.dart';
import 'prayer_display_phase.dart';

export 'next_prayer_event.dart';
export 'prayer_display_phase.dart';
export '../../data/models/display/adjusted_prayer_times.dart';

/// Optimized helper for prayer time calculations and display phase management.
/// Uses a continuous timeline approach to handle large offsets and transitions correctly.
class PrayerTimesHelper {
  final MosqueModel mosque;

  static const String tomorrowFajrPrayerName = 'FAJR (TOMORROW)';

  PrayerTimesHelper(this.mosque);

  CalculationParameters _getParams() {
    switch (mosque.prayerCalculationMethod) {
      case 'MuslimWorldLeague':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'Egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'UmmAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'Dubai':
        return CalculationMethod.dubai.getParameters();
      case 'Qatar':
        return CalculationMethod.qatar.getParameters();
      case 'Kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'MoonsightingCommittee':
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 'Singapore':
        return CalculationMethod.singapore.getParameters();
      case 'Turkey':
        return CalculationMethod.turkey.getParameters();
      case 'Tehran':
        return CalculationMethod.tehran.getParameters();
      case 'Isna':
        return CalculationMethod.north_america.getParameters();
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  /// Builds adjusted prayer times for a specific date, applying all offsets.
  AdjustedPrayerTimes buildAdjustedPrayerTimes(DateTime date) {
    final coordinates = Coordinates(mosque.latitude, mosque.longitude);
    final params = _getParams();
    final prayers = PrayerTimes(coordinates, DateComponents.from(date), params);

    final List<PrayerTimeItem> items = [];
    final prayersToProcess = [
      Prayer.fajr,
      Prayer.sunrise,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    for (final p in prayersToProcess) {
      final rawTime = prayers.timeForPrayer(p);
      if (rawTime == null) continue;

      final offset = _getOffsetFor(p);
      final adhanTime = rawTime.add(Duration(minutes: offset));

      final slotKey = _mapPrayerToSlot(p).name.toUpperCase();
      final iqamaOffset = getIqamaOffset(
        p,
        isFriday: date.weekday == DateTime.friday,
      );
      final iqamaTime = adhanTime.add(Duration(minutes: iqamaOffset));

      items.add(
        PrayerTimeItem(
          prayer: p,
          prayerName: slotKey,
          adhanTime: adhanTime,
          iqamaTime: iqamaTime,
          offset: offset,
        ),
      );
    }

    // Sort items chronologically by adhanTime
    items.sort((a, b) => a.adhanTime.compareTo(b.adhanTime));

    return AdjustedPrayerTimes(items: items, date: date);
  }

  PrayerDisplaySlot _mapPrayerToSlot(Prayer p) {
    switch (p) {
      case Prayer.fajr:
        return PrayerDisplaySlot.fajr;
      case Prayer.sunrise:
        return PrayerDisplaySlot.sunrise;
      case Prayer.dhuhr:
        return PrayerDisplaySlot.dhuhr;
      case Prayer.asr:
        return PrayerDisplaySlot.asr;
      case Prayer.maghrib:
        return PrayerDisplaySlot.maghrib;
      case Prayer.isha:
        return PrayerDisplaySlot.isha;
      default:
        return PrayerDisplaySlot.fajr;
    }
  }

  int _getOffsetFor(Prayer prayer) {
    final offsets = mosque.prayerOffsets;
    switch (prayer) {
      case Prayer.fajr:
        return offsets.fajr;
      case Prayer.sunrise:
        return offsets.sunrise;
      case Prayer.dhuhr:
        return offsets.dhuhr;
      case Prayer.asr:
        return offsets.asr;
      case Prayer.maghrib:
        return offsets.maghrib;
      case Prayer.isha:
        return offsets.isha;
      default:
        return 0;
    }
  }

  int getIqamaOffset(Prayer prayer, {bool isFriday = false}) {
    switch (prayer) {
      case Prayer.fajr:
        return mosque.iqamaSettings.fajrOffset;
      case Prayer.dhuhr:
        return isFriday
            ? mosque.iqamaSettings.jummahOffset
            : mosque.iqamaSettings.dhuhrOffset;
      case Prayer.asr:
        return mosque.iqamaSettings.asrOffset;
      case Prayer.maghrib:
        return mosque.iqamaSettings.maghribOffset;
      case Prayer.isha:
        return mosque.iqamaSettings.ishaOffset;
      default:
        return 0;
    }
  }

  /// Returns a combined list of adjusted prayer times for yesterday, today, and tomorrow.
  /// This creates a continuous timeline that survives large offsets and midnight crossings.
  List<PrayerTimeItem> _buildContinuousTimeline(DateTime now) {
    final yesterday = buildAdjustedPrayerTimes(
      now.subtract(const Duration(days: 1)),
    );
    final today = buildAdjustedPrayerTimes(now);
    final tomorrow = buildAdjustedPrayerTimes(now.add(const Duration(days: 1)));

    final combined = [...yesterday.items, ...today.items, ...tomorrow.items];
    combined.sort((a, b) => a.adhanTime.compareTo(b.adhanTime));
    return combined;
  }

  /// Determines the current UI display phase (Adhan, Iqama, or countdown to Next).
  PrayerDisplayPhase getPrayerDisplayPhase(DateTime now) {
    final timeline = _buildContinuousTimeline(now);

    // 1. Check if we are currently in an Iqama window or Grace period.
    for (final item in timeline) {
      if (!item.isIqamaApplicable) {
        // For Sunrise or prayers with no iqama, we stay focused for a "Post-Adhan" grace period.
        final postAdhanGrace = item.adhanTime.add(const Duration(minutes: 10));
        if ((now.isAfter(item.adhanTime) ||
                now.isAtSameMomentAs(item.adhanTime)) &&
            now.isBefore(postAdhanGrace)) {
          return PrayerDisplayPhase(
            kind: PrayerDisplayPhaseKind
                .iqama, // Using iqama kind to indicate high-focus
            prayerNameKey: item.prayerName,
            focusTime: postAdhanGrace,
          );
        }
        continue;
      }

      // Check Iqama countdown
      if ((now.isAfter(item.adhanTime) ||
              now.isAtSameMomentAs(item.adhanTime)) &&
          now.isBefore(item.iqamaTime)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.iqama,
          prayerNameKey: item.prayerName,
          focusTime: item.iqamaTime,
        );
      }

      // Check Grace after iqama
      final graceEnd = item.iqamaTime.add(const Duration(minutes: 1));
      if ((now.isAfter(item.iqamaTime) ||
              now.isAtSameMomentAs(item.iqamaTime)) &&
          now.isBefore(graceEnd)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.graceAfterIqama,
          prayerNameKey: item.prayerName,
          focusTime: graceEnd,
        );
      }
    }

    // 2. Default: Find the next upcoming event (Adhan).
    for (final item in timeline) {
      if (now.isBefore(item.adhanTime)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.nextAdhan,
          prayerNameKey: item.prayerName,
          focusTime: item.adhanTime,
        );
      }
    }

    // Fallback (should never be reached with 3-day timeline)
    return PrayerDisplayPhase(
      kind: PrayerDisplayPhaseKind.nextAdhan,
      prayerNameKey: 'FAJR',
      focusTime: now.add(const Duration(hours: 1)),
    );
  }

  /// Returns the countdown details for the clock and other labels.
  NextPrayerEvent getNextEvent(DateTime now) {
    final phase = getPrayerDisplayPhase(now);

    return NextPrayerEvent(
      isIqama: phase.kind == PrayerDisplayPhaseKind.iqama,
      targetTime: phase.focusTime,
      prayerName: phase.prayerNameKey,
    );
  }

  static String formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
