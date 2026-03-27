import 'package:adhan/adhan.dart';

/// Represents a single prayer with its final, adjusted times.
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

/// A centralized entity containing all adjusted prayer times for a day.
class AdjustedPrayerTimes {
  final List<PrayerTimeItem> items;
  final DateTime date;

  AdjustedPrayerTimes({
    required this.items,
    required this.date,
  });

  PrayerTimeItem? getByPrayer(Prayer prayer) {
    try {
      return items.firstWhere((element) => element.prayer == prayer);
    } catch (_) {
      return null;
    }
  }

  PrayerTimeItem? getByPrayerName(String name) {
    try {
      final normalized = name.toUpperCase();
      return items.firstWhere((element) => element.prayerName.toUpperCase() == normalized);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdjustedPrayerTimes &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          date == other.date;

  @override
  int get hashCode => items.hashCode ^ date.hashCode;
}
