import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../data/models/design_settings_model.dart';
import '../../../../data/models/prayer_display_slot.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import 'prayer_card_background.dart';
import 'prayer_card_next_strip.dart';

/// Individual prayer card used in the beige area.
/// Displays prayer icon, names, and time with dynamic scaling.
class DisplayPrayerCard extends StatelessWidget {
  final PrayerDisplaySlot slot;
  final DateTime azanTime;
  final bool isFocusCard;
  final PrayerDisplayPhase phase;
  final Duration remaining;
  final DesignSettingsModel designSettings;
  final double baseFontSize;
  final Animation<double>? graceAnim;

  const DisplayPrayerCard({
    super.key,
    required this.slot,
    required this.azanTime,
    required this.isFocusCard,
    required this.phase,
    required this.remaining,
    required this.designSettings,
    required this.baseFontSize,
    this.graceAnim,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final maxW = constraints.maxWidth;
        
        final compactFactorH = (maxH / 275.0).clamp(0.02, 1.0);
        final compactFactorW = (maxW / 110.0).clamp(0.22, 1.0);
        var compactFactor = (compactFactorH < compactFactorW ? compactFactorH : compactFactorW);
        
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        if (textScale > 1.0) {
          compactFactor /= 1.0 + 0.35 * (textScale - 1.0);
        }
        compactFactor = (compactFactor * 1.06).clamp(0.0, 1.0);

        final verticalPad = (20.0 * compactFactor).clamp(0.0, maxH * 0.14);
        final gap = (12.0 * compactFactor).clamp(0.0, maxH * 0.07);
        final iconSize = (42.0 * compactFactor).clamp(0.0, maxH * 0.30);
        final arSize = (baseFontSize * 1.88 * compactFactor).clamp(9.0, 36.0);
        final enSize = (baseFontSize * 1.22 * compactFactor).clamp(8.0, 26.0);
        final timeDisplaySize = (baseFontSize * 2.1 * compactFactor).clamp(10.0, 48.0);

        final numeralFormat = designSettings.numeralFormat;
        final formattedTime = AppTimeFormat.time12h(context, azanTime).formatNumerals(numeralFormat);

        final mainColumn = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.icon,
              size: iconSize,
              color: designSettings.primaryColorValue.withValues(alpha: 0.85),
            ),
            SizedBox(height: gap),
            Text(
              slot.labelAr(s),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: arSize,
                fontWeight: FontWeight.bold,
                color: designSettings.primaryColorValue,
              ),
            ),
            Text(
              slot.labelEn(s),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: enSize,
                color: designSettings.primaryColorValue.withValues(alpha: 0.72),
              ),
            ),
            SizedBox(height: gap),
            Text(
              formattedTime,
              maxLines: 1,
              style: TextStyle(
                fontSize: timeDisplaySize,
                fontWeight: FontWeight.bold,
                color: designSettings.primaryColorValue,
              ),
            ),
          ],
        );

        final padded = EdgeInsets.symmetric(vertical: verticalPad, horizontal: 4);

        return PrayerCardBackground(
          prayerCardColor: designSettings.prayerCardColorValue,
          child: Padding(
            padding: padded,
            child: isFocusCard
                ? Column(
                    children: [
                      Expanded(
                        flex: 62,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: mainColumn,
                        ),
                      ),
                      Expanded(
                        flex: 38,
                        child: PrayerCardNextStrip(
                          phase: phase,
                          remaining: remaining,
                          designSettings: designSettings,
                          baseFontSize: baseFontSize * compactFactor,
                          graceOpacityAnimation: graceAnim,
                        ),
                      ),
                    ],
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: mainColumn,
                  ),
          ),
        );
      },
    );
  }
}
