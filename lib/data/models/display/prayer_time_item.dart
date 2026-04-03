import 'package:adhan/adhan.dart';

class PrayerTimeItem {
  final Prayer prayer;
  final String prayerName;
  final DateTime adhanTime;
  final DateTime iqamaTime;
  final int offset;

  PrayerTimeItem({
    required this.prayer,
    required this.prayerName,
    required this.adhanTime,
    required this.iqamaTime,
    required this.offset,
  });

  bool get isSunrise => prayer == Prayer.sunrise;
  bool get isIqamaApplicable => prayer != Prayer.sunrise;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimeItem &&
          runtimeType == other.runtimeType &&
          prayer == other.prayer &&
          adhanTime == other.adhanTime &&
          iqamaTime == other.iqamaTime;

  @override
  int get hashCode => prayer.hashCode ^ adhanTime.hashCode ^ iqamaTime.hashCode;
}

