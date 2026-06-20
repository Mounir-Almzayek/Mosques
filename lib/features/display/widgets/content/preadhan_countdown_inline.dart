import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque/display_settings.dart';
import '../../../../data/models/prayer_display_slot.dart';

/// Inline pre-Adhan countdown displayed inside the beige area during the
/// religious-content cycle when the UI phase is `preAdhan`.
class PreAdhanCountdownInline extends StatelessWidget {
  final PrayerTimesHelper helper;
  final DateTime now;
  final DisplaySettings designSettings;

  const PreAdhanCountdownInline({
    super.key,
    required this.helper,
    required this.now,
    required this.designSettings,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final textColor = designSettings.inactiveCardTextColorValue;

    final phase = helper.getPrayerDisplayPhase(
      now,
      preAdhanMinutes: helper.mosque.prayerSettings.preAdhanMinutes,
      adhanMomentDurationSeconds:
          helper.mosque.prayerSettings.adhanMomentDurationSeconds,
    );
    if (phase.kind != PrayerDisplayPhaseKind.preAdhan &&
        phase.kind != PrayerDisplayPhaseKind.iqama) {
      return const SizedBox.shrink();
    }

    final remaining = phase.focusTime.difference(now);
    final slot = PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey);
    final prayerLabel = _resolvePrayerLabel(slot, s);

    final baseStyle = AppFontLoader.getStyle(
      designSettings.fontFamily,
      baseStyle: TextStyle(color: textColor),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (slot != null) Icon(slot.icon, size: 48, color: textColor),
                  if (slot != null) const SizedBox(height: 12),

                  Text(
                    phase.kind == PrayerDisplayPhaseKind.iqama
                        ? s.display_remaining_to_iqama_line(prayerLabel)
                        : s.display_remaining_to_adhan_line(prayerLabel),
                    style: baseStyle.copyWith(
                      fontSize: (designSettings.countdownFontSize * 1.6)
                          .clamp(14.0, 40.0),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    PrayerTimesHelper.formatDuration(remaining),
                    style: baseStyle.copyWith(
                      fontSize: (designSettings.countdownFontSize * 2.8)
                          .clamp(20.0, 80.0),
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolvePrayerLabel(PrayerDisplaySlot? slot, S s) {
    if (slot == null) return '';
    return slot.labelAr(s);
  }
}
