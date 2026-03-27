import 'package:adhan/adhan.dart';

import '../../data/models/adjusted_prayer_times.dart';
import '../../data/models/mosque_model.dart';
import 'next_prayer_event.dart';
import 'prayer_display_phase.dart';

export 'next_prayer_event.dart';
export 'prayer_display_phase.dart';
export '../../data/models/adjusted_prayer_times.dart';

/// Optimized helper for prayer time calculations and display phase management.
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

  /// The only way to get prayer times. This applies all offsets and iqama 
  /// configurations to return a final, centralized set of data.
  AdjustedPrayerTimes buildAdjustedPrayerTimes(DateTime date) {
    final coordinates = Coordinates(mosque.latitude, mosque.longitude);
    final params = _getParams();
    final prayers = PrayerTimes(
      coordinates,
      DateComponents.from(date),
      params,
    );

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
      
      // Iqama calculation (handles Friday specialization)
      final iqamaOffset = getIqamaOffset(p, isFriday: date.weekday == DateTime.friday);
      final iqamaTime = adhanTime.add(Duration(minutes: iqamaOffset));

      items.add(PrayerTimeItem(
        prayer: p,
        prayerName: p.name.toUpperCase(),
        adhanTime: adhanTime,
        iqamaTime: iqamaTime,
        offset: offset,
      ));
    }

    return AdjustedPrayerTimes(items: items, date: date);
  }

  AdjustedPrayerTimes getTodayAdjustedTimes() {
    return buildAdjustedPrayerTimes(DateTime.now());
  }

  int _getOffsetFor(Prayer prayer) {
    final offsets = mosque.prayerOffsets;
    switch (prayer) {
      case Prayer.fajr:
        return offsets.fajr;
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

  /// Get Iqama offset for a specific prayer in minutes.
  /// Handles Friday (Jummah) specialization for the Dhuhr slot.
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

  /// Determines the current UI display phase (Next Adhan, Iqama countdown, etc.).
  PrayerDisplayPhase getPrayerDisplayPhase(DateTime now) {
    final adjusted = getTodayAdjustedTimes();

    // Check if we are between adhan and iqama for any prayer.
    for (final item in adjusted.items) {
      if (item.prayer == Prayer.sunrise) continue; // No iqama for sunrise.
      
      if (now.isAfter(item.adhanTime) && now.isBefore(item.iqamaTime)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.iqama,
          prayerNameKey: item.prayerName,
          focusTime: item.iqamaTime,
        );
      }
    }

    // Check if we are in the 1-minute grace period after iqama.
    for (final item in adjusted.items) {
      if (item.prayer == Prayer.sunrise) continue;
      
      final graceEnd = item.iqamaTime.add(const Duration(minutes: 1));
      if (now.isAfter(item.iqamaTime) && now.isBefore(graceEnd)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.graceAfterIqama,
          prayerNameKey: item.prayerName,
          focusTime: graceEnd,
        );
      }
    }

    // Default: counting down to the next adhan.
    final ev = getNextEvent();
    final key = ev.prayerName.split('(').first.trim();
    return PrayerDisplayPhase(
      kind: PrayerDisplayPhaseKind.nextAdhan,
      prayerNameKey: key,
      focusTime: ev.targetTime,
    );
  }

  /// Returns the single most relevant upcoming "Event" (Next Adhan or next Iqama).
  NextPrayerEvent getNextEvent() {
    final now = DateTime.now();
    final today = getTodayAdjustedTimes();

    // 1. Are we in an iqama countdown right now?
    for (final item in today.items) {
      if (item.prayer == Prayer.sunrise) continue;
      if (now.isAfter(item.adhanTime) && now.isBefore(item.iqamaTime)) {
        return NextPrayerEvent(
          isIqama: true,
          targetTime: item.iqamaTime,
          prayerName: item.prayerName,
        );
      }
    }

    // 2. Find the next adhan today.
    for (final item in today.items) {
      if (now.isBefore(item.adhanTime)) {
        return NextPrayerEvent(
          isIqama: false,
          targetTime: item.adhanTime,
          prayerName: item.prayerName,
        );
      }
    }

    // 3. If after all today's prayers, next is tomorrow's Fajr.
    final tomorrow = buildAdjustedPrayerTimes(now.add(const Duration(days: 1)));
    final fajrTomorrow = tomorrow.getByPrayer(Prayer.fajr)!;

    return NextPrayerEvent(
      isIqama: false,
      targetTime: fajrTomorrow.adhanTime,
      prayerName: tomorrowFajrPrayerName,
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

