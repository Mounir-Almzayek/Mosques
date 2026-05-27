import 'package:flutter/material.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';

/// Fullscreen overlay displayed during pre-adhan countdown, adhan moment,
/// and iqama countdown phases.
///
/// - **Pre-Adhan**: title line + prayer name + large countdown timer.
/// - **Adhan Moment**: announcement text, no timer.
/// - **Iqama**: title line + prayer name + large countdown timer.
///
/// On Fridays, Dhuhr is displayed as "Jummah".
class IqamaAdhanLayer extends StatelessWidget {
  final PrayerDisplayPhase phase;
  final Duration remaining;
  final DesignSettingsModel designSettings;
  final bool isFriday;
  final double countdownFontSize;

  const IqamaAdhanLayer({
    super.key,
    required this.phase,
    required this.remaining,
    required this.designSettings,
    required this.isFriday,
    required this.countdownFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = designSettings.colors;
    final bgColor = colors.activeCardValue;
    final textColor = colors.activeCardTextValue;
    final fmt = designSettings.numeralFormat;

    final slot = PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey);
    final prayerLabel = _resolvePrayerLabel(slot, s);

    final baseStyle = AppFontLoader.getStyle(
      designSettings.fontFamily,
      baseStyle: TextStyle(color: textColor),
    );

    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prayer icon
            if (slot != null)
              Icon(slot.icon, size: (countdownFontSize * 4.0).clamp(28.0, 150.0), color: textColor),
            if (slot != null) const SizedBox(height: 24),

            // Title / announcement line
            Text(
              _buildTitle(slot, prayerLabel, s),
              style: baseStyle.copyWith(fontSize: (countdownFontSize * 2.4).clamp(16.0, 90.0)),
              textAlign: TextAlign.center,
            ),

            // Countdown timer (not shown during adhan moment)
            if (phase.kind != PrayerDisplayPhaseKind.adhanMoment) ...[
              const SizedBox(height: 32),
              Text(
                PrayerTimesHelper.formatDuration(remaining)
                    .formatNumerals(fmt),
                style: baseStyle.copyWith(
                  fontSize: (countdownFontSize * 4.8).clamp(32.0, 180.0),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Resolves the human-readable prayer name, substituting Jummah for
  /// Friday Dhuhr.
  String _resolvePrayerLabel(PrayerDisplaySlot? slot, S s) {
    if (slot == null) return '';
    if (isFriday && slot == PrayerDisplaySlot.dhuhr) {
      return s.prayer_jummah;
    }
    return slot.labelAr(s);
  }

  /// Builds the main title text depending on the current phase.
  String _buildTitle(PrayerDisplaySlot? slot, String prayerLabel, S s) {
    switch (phase.kind) {
      case PrayerDisplayPhaseKind.preAdhan:
        if (slot != null && slot.isSunrise) {
          return s.display_remaining_to_sunrise_line;
        }
        return s.display_remaining_to_adhan_line(prayerLabel);

      case PrayerDisplayPhaseKind.adhanMoment:
        if (slot != null && slot.isSunrise) {
          return s.display_sunrise_now;
        }
        return s.display_adhan_now(prayerLabel);

      case PrayerDisplayPhaseKind.iqama:
        return s.display_remaining_to_iqama_line(prayerLabel);

      case PrayerDisplayPhaseKind.graceAfterIqama:
      case PrayerDisplayPhaseKind.nextAdhan:
        // These phases are not expected to use this layer, but handle
        // gracefully by falling back to a generic countdown label.
        return s.display_remaining_to_adhan_line(prayerLabel);
    }
  }
}
