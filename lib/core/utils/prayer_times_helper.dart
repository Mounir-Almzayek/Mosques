import 'package:adhan/adhan.dart';

import '../../data/models/mosque_model.dart';
import 'next_prayer_event.dart';
import 'prayer_display_phase.dart';

export 'next_prayer_event.dart';
export 'prayer_display_phase.dart';

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

  PrayerTimes getTodayPrayerTimes() {
    final coordinates = Coordinates(mosque.latitude, mosque.longitude);
    final params = _getParams();
    return PrayerTimes.today(coordinates, params);
  }

  DateTime? _getAdjustedTime(DateTime? t, Prayer prayer) {
    if (t == null) return null;
    final offsets = mosque.prayerOffsets;
    int offset = 0;
    switch (prayer) {
      case Prayer.fajr:
        offset = offsets.fajr;
        break;
      case Prayer.dhuhr:
        offset = offsets.dhuhr;
        break;
      case Prayer.asr:
        offset = offsets.asr;
        break;
      case Prayer.maghrib:
        offset = offsets.maghrib;
        break;
      case Prayer.isha:
        offset = offsets.isha;
        break;
      default:
        offset = 0;
    }
    if (offset == 0) return t;
    return t.add(Duration(minutes: offset));
  }

  /// Get Iqama offset for a specific prayer in minutes.
  int getIqamaOffset(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return mosque.iqamaSettings.fajrOffset;
      case Prayer.dhuhr:
        return mosque.iqamaSettings.dhuhrOffset;
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

  static const List<Prayer> _iqamaPrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  /// Determines the current UI display phase (Next Adhan, Iqama countdown, etc.).
  PrayerDisplayPhase getPrayerDisplayPhase(DateTime now) {
    final prayers = getTodayPrayerTimes();

    // Check if we are between adhan and iqama for any prayer.
    for (final p in _iqamaPrayers) {
      final azan = _getAdjustedTime(prayers.timeForPrayer(p), p);
      if (azan == null) continue;
      final iqamaTime = azan.add(Duration(minutes: getIqamaOffset(p)));
      if (now.isAfter(azan) && now.isBefore(iqamaTime)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.iqama,
          prayerNameKey: p.name.toUpperCase(),
          focusTime: iqamaTime,
        );
      }
    }

    // Check if we are in the 1-minute grace period after iqama.
    for (final p in _iqamaPrayers) {
      final azan = _getAdjustedTime(prayers.timeForPrayer(p), p);
      if (azan == null) continue;
      final iqamaTime = azan.add(Duration(minutes: getIqamaOffset(p)));
      final graceEnd = iqamaTime.add(const Duration(minutes: 1));
      if (now.isAfter(iqamaTime) && now.isBefore(graceEnd)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.graceAfterIqama,
          prayerNameKey: p.name.toUpperCase(),
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
    final prayers = getTodayPrayerTimes();

    // Check if we are between an adhan and its iqama.
    final currentPrayer = prayers.currentPrayer();
    if (currentPrayer != Prayer.none && currentPrayer != Prayer.sunrise) {
      final azanTime =
          _getAdjustedTime(prayers.timeForPrayer(currentPrayer), currentPrayer)!;
      final iqamaOffset = getIqamaOffset(currentPrayer);
      final iqamaTime = azanTime.add(Duration(minutes: iqamaOffset));

      if (now.isAfter(azanTime) && now.isBefore(iqamaTime)) {
        return NextPrayerEvent(
          isIqama: true,
          targetTime: iqamaTime,
          prayerName: currentPrayer.name.toUpperCase(),
        );
      }
    }

    // Find the next adhan.
    final nextPrayer = prayers.nextPrayer();
    if (nextPrayer != Prayer.none && nextPrayer != Prayer.sunrise) {
      return NextPrayerEvent(
        isIqama: false,
        targetTime:
            _getAdjustedTime(prayers.timeForPrayer(nextPrayer), nextPrayer)!,
        prayerName: nextPrayer.name.toUpperCase(),
      );
    }

    // After Isha → tomorrow's Fajr.
    final tomorrowPrayers = PrayerTimes(
      Coordinates(mosque.latitude, mosque.longitude),
      DateComponents.from(now.add(const Duration(days: 1))),
      _getParams(),
    );
    return NextPrayerEvent(
      isIqama: false,
      targetTime: _getAdjustedTime(tomorrowPrayers.fajr, Prayer.fajr)!,
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
