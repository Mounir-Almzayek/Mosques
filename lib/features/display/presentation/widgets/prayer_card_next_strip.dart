import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/design_settings_model.dart';
import '../../../../data/models/prayer_display_slot.dart';

/// شريط مضغوط داخل بطاقة صلاة واحدة — «التالية» + العدّ التنازلي.
/// لا يُعرض أثناء [PrayerDisplayPhaseKind.graceAfterIqama] (الدقيقة الصامتة بعد الإقامة).
class PrayerCardNextStrip extends StatelessWidget {
  final PrayerDisplayPhase phase;
  final Duration remaining;
  final DesignSettingsModel designSettings;
  final double baseFontSize;
  final Animation<double>? graceOpacityAnimation;

  const PrayerCardNextStrip({
    super.key,
    required this.phase,
    required this.remaining,
    required this.designSettings,
    required this.baseFontSize,
    this.graceOpacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final r = remaining.isNegative ? Duration.zero : remaining;
    final timeStr = PrayerTimesHelper.formatDuration(r);
    final slot = PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey);
    final pAr = slot?.labelAr(s) ?? phase.prayerNameKey;
    final pEn = slot?.labelEn(s) ?? phase.prayerNameKey;

    late final String subLine;
    switch (phase.kind) {
      case PrayerDisplayPhaseKind.iqama:
        subLine = s.display_remaining_to_iqama_line(pAr);
        break;
      case PrayerDisplayPhaseKind.graceAfterIqama:
        subLine = '';
        break;
      case PrayerDisplayPhaseKind.nextAdhan:
        subLine = s.display_remaining_to_adhan_line(pAr);
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // [FittedBox] with [BoxFit.scaleDown] lays out its child with unbounded
        // constraints; [Column] + [CrossAxisAlignment.stretch] then hits
        // "BoxConstraints forces an infinite width". Use a finite width when
        // only the height is bounded (e.g. [SizedBox] height under FittedBox).
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (constraints.maxHeight * 4.0).clamp(120.0, 800.0);

        final compact = (constraints.maxHeight / 96.0).clamp(0.66, 1.0);
        final dividerHeight = 14.0 * compact;
        final topGap = 3.0 * compact;
        final middleGap = 5.0 * compact;
        final subFont = (baseFontSize * 1.50 * compact).clamp(9.0, 24.0);
        final timeFont = (baseFontSize * 1.55 * compact).clamp(9.0, 22.0);
        final enFont = (baseFontSize * 0.78 * compact).clamp(8.0, 16.0);
        final showEnglish = constraints.maxHeight >= 74;

        final fontFamily = designSettings.fontFamily;
        final numeralFormat = designSettings.numeralFormat;

        return SizedBox(
          width: maxW,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(
                height: dividerHeight,
                thickness: 1,
                color: designSettings.activeCardTextColorValue.withValues(
                  alpha: 0.22,
                ),
              ),
              SizedBox(height: topGap),
              Text(
                subLine.formatNumerals(numeralFormat),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: subFont,
                    color: designSettings.activeCardTextColorValue.withValues(
                      alpha: 0.78,
                    ),
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(height: middleGap),
              Text(
                timeStr.formatNumerals(numeralFormat),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: timeFont,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4 * compact,
                    color: designSettings.activeCardTextColorValue,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.0,
                  ),
                ),
              ),
              if (showEnglish)
                Flexible(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      pEn,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontLoader.getStyle(
                        fontFamily,
                        baseStyle: TextStyle(
                          fontSize: enFont,
                          color: designSettings.activeCardTextColorValue
                              .withValues(alpha: 0.5),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
