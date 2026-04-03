import 'package:adhan/adhan.dart';
import 'prayer_time_item.dart';

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
