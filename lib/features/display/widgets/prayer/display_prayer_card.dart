import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/design/design_settings_model.dart';
import '../../../../data/models/prayer_display_slot.dart';
import 'prayer_card_background.dart';

class DisplayPrayerCard extends StatelessWidget {
  final PrayerDisplaySlot slot;
  final DateTime azanTime;
  final bool isFocusCard;
  final DesignSettingsModel designSettings;
  final double prayersFontSize;
  final bool isFriday;

  const DisplayPrayerCard({
    super.key,
    required this.slot,
    required this.azanTime,
    required this.isFocusCard,
    required this.designSettings,
    required this.prayersFontSize,
    this.isFriday = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = designSettings.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final compactFactor = ((maxH / 275.0).clamp(0.02, 1.0) * 1.06).clamp(
          0.0,
          1.0,
        );

        // Upcoming (focused) prayer gets a larger font than the others.
        final focusFactor = isFocusCard ? 1.28 : 1.0;

        final gap = (12.0 * compactFactor).clamp(0.0, maxH * 0.07);
        final iconSize = (42.0 * compactFactor * focusFactor).clamp(
          0.0,
          maxH * 0.30 * focusFactor,
        );
        // Upper bounds track the settings slider's full range (max 56). The
        // surrounding FittedBox(scaleDown) guards against overflow, so the
        // ceilings only need to be high enough that the chosen font size is
        // honoured and the focus card can grow into its extra space.
        final arSize = (prayersFontSize * 1.88 * compactFactor * focusFactor)
            .clamp(9.0, 110.0 * focusFactor);
        final enSize = (prayersFontSize * 1.22 * compactFactor * focusFactor)
            .clamp(8.0, 72.0 * focusFactor);
        final timeSize = (prayersFontSize * 2.1 * compactFactor * focusFactor)
            .clamp(10.0, 124.0 * focusFactor);

        final cardColor = isFocusCard
            ? colors.activeCardValue
            : colors.prayerOverlayValue;
        final textColor = isFocusCard
            ? colors.activeCardTextValue
            : colors.inactiveCardTextValue;

        final fmt = designSettings.numeralFormat;
        final formattedTime = AppTimeFormat.time12h(
          context,
          azanTime,
        ).formatNumerals(fmt);
        final fontFamily = designSettings.fontFamily;

        String arLabel = slot.labelAr(s);
        String enLabel = slot.labelEn(s);
        if (isFriday && slot == PrayerDisplaySlot.dhuhr) {
          arLabel = s.prayer_jummah;
          enLabel = "Jumu'ah";
        }

        final column = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.icon,
              size: iconSize,
              color: textColor.withValues(alpha: 0.85),
            ),
            SizedBox(height: gap),
            Text(
              arLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: arSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Text(
              enLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: enSize,
                  color: textColor.withValues(alpha: 0.72),
                ),
              ),
            ),
            SizedBox(height: gap),
            Text(
              formattedTime,
              maxLines: 1,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: timeSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        );

        return PrayerCardBackground(
          prayerCardColor: cardColor,
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: column),
          ),
        );
      },
    );
  }
}
