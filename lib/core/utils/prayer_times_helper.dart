import 'package:adhan/adhan.dart';
import '../../../data/models/mosque_model.dart';

class PrayerTimesHelper {
  /// Sentinel for [getNextEvent] when the next adhan is tomorrow's Fajr.
  static const String tomorrowFajrPrayerName = 'FAJR_TOMORROW';

  final MosqueModel mosque;

  PrayerTimesHelper(this.mosque);

  CalculationParameters _getParams() {
    switch (mosque.prayerCalculationMethod) {
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
      case 'NorthAmerica':
        return CalculationMethod.north_america.getParameters();
      case 'MuslimWorldLeague':
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  PrayerTimes getTodayPrayerTimes() {
    final coordinates = Coordinates(mosque.latitude, mosque.longitude);
    final params = _getParams();
    return PrayerTimes.today(coordinates, params);
  }

  /// Get Iqama offset for a specific prayer in minutes
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
      case Prayer.none:
      case Prayer.sunrise:
        return 0;
    }
  }

  static const _iqamaPrayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  /// مراحل العرض: إقامة حالية، دقيقة انتقال بعد الإقامة، ثم العدّ لأذان القادم.
  PrayerDisplayPhase getPrayerDisplayPhase([DateTime? now]) {
    now ??= DateTime.now();
    final prayers = getTodayPrayerTimes();

    for (final p in _iqamaPrayers) {
      final azan = prayers.timeForPrayer(p);
      if (azan == null) continue;
      final offsetMin = getIqamaOffset(p);
      final iqamaTime = azan.add(Duration(minutes: offsetMin));
      if (now.isAfter(azan) && now.isBefore(iqamaTime)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.iqama,
          prayerNameKey: p.name.toUpperCase(),
          focusTime: iqamaTime,
        );
      }
    }

    for (final p in _iqamaPrayers) {
      final azan = prayers.timeForPrayer(p);
      if (azan == null) continue;
      final offsetMin = getIqamaOffset(p);
      final iqamaTime = azan.add(Duration(minutes: offsetMin));
      final graceEnd = iqamaTime.add(const Duration(minutes: 1));
      if (!now.isBefore(iqamaTime) && now.isBefore(graceEnd)) {
        return PrayerDisplayPhase(
          kind: PrayerDisplayPhaseKind.graceAfterIqama,
          prayerNameKey: p.name.toUpperCase(),
          focusTime: graceEnd,
        );
      }
    }

    final ev = getNextEvent();
    final rawName = ev['prayerName'] as String;
    final key = rawName.split(' ').first;
    return PrayerDisplayPhase(
      kind: PrayerDisplayPhaseKind.nextAdhan,
      prayerNameKey: key,
      focusTime: ev['targetTime'] as DateTime,
    );
  }

  /// Calculates upcoming event (Next Azan OR Iqama Countdown)
  Map<String, dynamic> getNextEvent() {
    final prayers = getTodayPrayerTimes();
    final now = DateTime.now();

    // First, check if we are currently BETWEEN an Azan and its Iqama
    final currentPrayer = prayers.currentPrayer();
    if (currentPrayer != Prayer.none && currentPrayer != Prayer.sunrise) {
      final azanTime = prayers.timeForPrayer(currentPrayer)!;
      final iqamaOffset = getIqamaOffset(currentPrayer);
      final iqamaTime = azanTime.add(Duration(minutes: iqamaOffset));

      // If now is after Azan, but before Iqama, we are in Iqama countdown
      if (now.isAfter(azanTime) && now.isBefore(iqamaTime)) {
        return {
          'isIqama': true,
          'targetTime': iqamaTime,
          'prayerName': currentPrayer.name.toUpperCase(),
        };
      }
    }

    // Otherwise, find the next Azan
    final nextPrayer = prayers.nextPrayer();
    if (nextPrayer != Prayer.none && nextPrayer != Prayer.sunrise) {
      return {
        'isIqama': false,
        'targetTime': prayers.timeForPrayer(nextPrayer),
        'prayerName': nextPrayer.name.toUpperCase(),
      };
    } else {
      // It's after Isha, so next is tomorrow's Fajr
      final tomorrowPrayers = PrayerTimes(
        Coordinates(mosque.latitude, mosque.longitude),
        DateComponents.from(now.add(const Duration(days: 1))),
        _getParams(),
      );
      return {
        'isIqama': false,
        'targetTime': tomorrowPrayers.fajr,
        'prayerName': tomorrowFajrPrayerName,
      };
    }
  }

  static String formatDuration(Duration d) {
    if (d.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

enum PrayerDisplayPhaseKind { iqama, graceAfterIqama, nextAdhan }

class PrayerDisplayPhase {
  final PrayerDisplayPhaseKind kind;
  final String prayerNameKey;
  final DateTime focusTime;

  const PrayerDisplayPhase({
    required this.kind,
    required this.prayerNameKey,
    required this.focusTime,
  });
}
