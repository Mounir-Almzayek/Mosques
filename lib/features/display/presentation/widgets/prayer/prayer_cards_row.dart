import 'package:flutter/material.dart';

import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/mosque/mosque_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';
import 'display_prayer_card.dart';

class PrayerCardsRow extends StatelessWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;
  final PrayerTimesHelper helper;
  final DateTime now;
  final double focusScale;

  const PrayerCardsRow({
    super.key,
    required this.mosque,
    required this.designSettings,
    required this.helper,
    required this.now,
    this.focusScale = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    final today = helper.buildAdjustedPrayerTimes(now);
    final preAdhanMin = designSettings.preAdhanMinutes;
    final phase = helper.getPrayerDisplayPhase(now, preAdhanMinutes: preAdhanMin);
    final slots = PrayerDisplaySlot.values;
    final isFriday = now.weekday == DateTime.friday;

    return LayoutBuilder(builder: (context, outer) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: slots.map((slot) {
          final azanTime = _azanTimeForSlot(now, today, slot, helper);
          final isFocusCard = _cardMatchesPhase(slot, phase);
          final isBlinking = (now.hour == azanTime.hour &&
                  now.minute == azanTime.minute &&
                  now.day == azanTime.day) ||
              (isFocusCard && phase.kind == PrayerDisplayPhaseKind.graceAfterIqama);

          final flex = isFocusCard ? (focusScale * 10).round() : 10;

          return Expanded(
            flex: flex,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (outer.maxWidth * 0.006).clamp(3.0, 10.0),
              ),
              child: DisplayPrayerCard(
                slot: slot,
                azanTime: azanTime,
                isFocusCard: isFocusCard,
                isBlinking: isBlinking,
                designSettings: designSettings,
                prayersFontSize: designSettings.fontSizes.prayers,
                isFriday: isFriday,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  static bool _cardMatchesPhase(PrayerDisplaySlot slot, PrayerDisplayPhase phase) {
    return PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey) == slot;
  }

  static DateTime _azanTimeForSlot(
    DateTime now,
    AdjustedPrayerTimes today,
    PrayerDisplaySlot slot,
    PrayerTimesHelper helper,
  ) {
    final todayItem = today.getByPrayerName(slot.name.toUpperCase());
    if (todayItem == null) return now;
    final cutoff = todayItem.iqamaTime.add(const Duration(minutes: 1));
    if (now.isAfter(cutoff)) {
      final tomorrow = helper.buildAdjustedPrayerTimes(now.add(const Duration(days: 1)));
      return tomorrow.getByPrayerName(slot.name.toUpperCase())?.adhanTime ?? todayItem.adhanTime;
    }
    return todayItem.adhanTime;
  }
}
