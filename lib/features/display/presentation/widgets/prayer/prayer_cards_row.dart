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

  /// Ratio of the focused card width to an inactive card width.
  /// 1.0 = all equal, 2.0 = active card is 2× wider.
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
    final slotCount = slots.length;

    // Clamp focusScale to sensible range (at least 1.0)
    final effectiveScale = focusScale.clamp(1.0, 5.0);

    // Calculate width fractions:
    // denominator = effectiveScale + (slotCount - 1) * 1.0
    // activeWidth  = effectiveScale / denominator
    // inactiveWidth = 1.0 / denominator
    final denominator = effectiveScale + (slotCount - 1);
    final activeFraction = effectiveScale / denominator;
    final inactiveFraction = 1.0 / denominator;

    return LayoutBuilder(builder: (context, outer) {
      final totalWidth = outer.maxWidth;
      final hPad = (totalWidth * 0.006).clamp(3.0, 10.0);
      // Total padding consumed by all cards
      final totalPadding = hPad * 2 * slotCount;
      final usableWidth = totalWidth - totalPadding;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: slots.map((slot) {
          final azanTime = _azanTimeForSlot(now, today, slot, helper);
          final isFocusCard = _cardMatchesPhase(slot, phase);
          final isBlinking = (now.hour == azanTime.hour &&
                  now.minute == azanTime.minute &&
                  now.day == azanTime.day) ||
              (isFocusCard && phase.kind == PrayerDisplayPhaseKind.graceAfterIqama);

          final targetWidth = isFocusCard
              ? usableWidth * activeFraction
              : usableWidth * inactiveFraction;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              width: targetWidth,
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
