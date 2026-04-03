import 'package:flutter/material.dart';

import '../../l10n/generated/l10n.dart';

enum PrayerDisplaySlot {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get phaseKey => name.toUpperCase();

  static PrayerDisplaySlot? tryParsePhaseKey(String raw) {
    final token = raw.split(' ').first;
    for (final s in PrayerDisplaySlot.values) {
      if (s.phaseKey == token) return s;
    }
    return null;
  }

  bool get isSunrise => this == PrayerDisplaySlot.sunrise;
  bool get isPrayer => this != PrayerDisplaySlot.sunrise;
}

extension PrayerDisplaySlotX on PrayerDisplaySlot {
  String labelAr(S s) {
    switch (this) {
      case PrayerDisplaySlot.fajr:
        return s.prayer_fajr_ar;
      case PrayerDisplaySlot.sunrise:
        return s.prayer_sunrise_ar;
      case PrayerDisplaySlot.dhuhr:
        return s.prayer_dhuhr_ar;
      case PrayerDisplaySlot.asr:
        return s.prayer_asr_ar;
      case PrayerDisplaySlot.maghrib:
        return s.prayer_maghrib_ar;
      case PrayerDisplaySlot.isha:
        return s.prayer_isha_ar;
    }
  }

  String labelEn(S s) {
    switch (this) {
      case PrayerDisplaySlot.fajr:
        return s.prayer_fajr_en;
      case PrayerDisplaySlot.sunrise:
        return s.prayer_sunrise_en;
      case PrayerDisplaySlot.dhuhr:
        return s.prayer_dhuhr_en;
      case PrayerDisplaySlot.asr:
        return s.prayer_asr_en;
      case PrayerDisplaySlot.maghrib:
        return s.prayer_maghrib_en;
      case PrayerDisplaySlot.isha:
        return s.prayer_isha_en;
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerDisplaySlot.fajr:
        return Icons.wb_sunny_outlined;
      case PrayerDisplaySlot.sunrise:
        return Icons.wb_twilight;
      case PrayerDisplaySlot.dhuhr:
      case PrayerDisplaySlot.asr:
        return Icons.wb_sunny;
      case PrayerDisplaySlot.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerDisplaySlot.isha:
        return Icons.brightness_3;
    }
  }
}

