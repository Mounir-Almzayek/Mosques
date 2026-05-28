import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/design/design_settings_model.dart';
import '../../../../data/models/prayer_display_slot.dart';
import 'prayer_card_background.dart';

class DisplayPrayerCard extends StatefulWidget {
  final PrayerDisplaySlot slot;
  final DateTime azanTime;
  final bool isFocusCard;
  final bool isBlinking;
  final DesignSettingsModel designSettings;
  final double prayersFontSize;
  final bool isFriday;

  const DisplayPrayerCard({
    super.key,
    required this.slot,
    required this.azanTime,
    required this.isFocusCard,
    required this.isBlinking,
    required this.designSettings,
    required this.prayersFontSize,
    this.isFriday = false,
  });

  @override
  State<DisplayPrayerCard> createState() => _DisplayPrayerCardState();
}

class _DisplayPrayerCardState extends State<DisplayPrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCirc,
    );
    if (widget.isBlinking) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant DisplayPrayerCard old) {
    super.didUpdateWidget(old);
    if (widget.isBlinking != old.isBlinking) {
      if (widget.isBlinking) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = widget.designSettings.colors;

    return LayoutBuilder(builder: (context, constraints) {
      final maxH = constraints.maxHeight;
      final compactFactor = ((maxH / 275.0).clamp(0.02, 1.0) * 1.06).clamp(0.0, 1.0);

      final gap = (12.0 * compactFactor).clamp(0.0, maxH * 0.07);
      final iconSize = (42.0 * compactFactor).clamp(0.0, maxH * 0.30);
      final arSize = (widget.prayersFontSize * 1.88 * compactFactor).clamp(9.0, 36.0);
      final enSize = (widget.prayersFontSize * 1.22 * compactFactor).clamp(8.0, 26.0);
      final timeSize = (widget.prayersFontSize * 2.1 * compactFactor).clamp(10.0, 48.0);

      final cardColor = widget.isFocusCard ? colors.activeCardValue : colors.prayerOverlayValue;
      final textColor = widget.isFocusCard ? colors.activeCardTextValue : colors.inactiveCardTextValue;

      final fmt = widget.designSettings.numeralFormat;
      final formattedTime = AppTimeFormat.time12h(context, widget.azanTime).formatNumerals(fmt);
      final fontFamily = widget.designSettings.fontFamily;

      String arLabel = widget.slot.labelAr(s);
      String enLabel = widget.slot.labelEn(s);
      if (widget.isFriday && widget.slot == PrayerDisplaySlot.dhuhr) {
        arLabel = s.prayer_jummah;
        enLabel = "Jumu'ah";
      }

      final column = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.slot.icon, size: iconSize, color: textColor.withValues(alpha: 0.85)),
          SizedBox(height: gap),
          Text(
            arLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: arSize, fontWeight: FontWeight.bold, color: textColor)),
          ),
          Text(
            enLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: enSize, color: textColor.withValues(alpha: 0.72))),
          ),
          SizedBox(height: gap),
          Text(
            formattedTime,
            maxLines: 1,
            style: AppFontLoader.getStyle(fontFamily,
                baseStyle: TextStyle(fontSize: timeSize, fontWeight: FontWeight.bold, color: textColor)),
          ),
        ],
      );

      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulseVal = _pulseAnimation.value;
          final glowColor = Colors.white.withValues(alpha: 0.45 * pulseVal);
          final animatedCardColor = Color.lerp(cardColor, Colors.white, 0.12 * pulseVal)!;

          return Stack(
            children: [
              PrayerCardBackground(
                prayerCardColor: animatedCardColor,
                child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: child)),
              ),
              if (widget.isBlinking)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: glowColor, width: 3.5 * pulseVal),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.3 * pulseVal),
                            blurRadius: 15 * pulseVal,
                            spreadRadius: 2 * pulseVal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: column,
      );
    });
  }
}
