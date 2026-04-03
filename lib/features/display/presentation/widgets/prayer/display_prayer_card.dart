import 'package:flutter/material.dart';
import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../core/utils/app_time_format.dart';
import '../../../../../data/models/design/design_settings_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';
import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../core/utils/app_font_loader.dart';
import 'prayer_card_background.dart';
import 'prayer_card_next_strip.dart';

/// Individual prayer card used in the beige area.
/// Displays prayer icon, names, and time with dynamic scaling.
/// Includes support for a stronger "pulse" animation with a white glow during prayer.
class DisplayPrayerCard extends StatefulWidget {
  final PrayerDisplaySlot slot;
  final DateTime azanTime;
  final bool isFocusCard;
  final PrayerDisplayPhase phase;
  final Duration remaining;
  final DesignSettingsModel designSettings;
  final double prayersFontSize;
  final Animation<double>? graceAnim;
  final bool isBlinking;

  const DisplayPrayerCard({
    super.key,
    required this.slot,
    required this.azanTime,
    required this.isFocusCard,
    required this.phase,
    required this.remaining,
    required this.designSettings,
    required this.prayersFontSize,
    this.graceAnim,
    this.isBlinking = false,
  });

  @override
  State<DisplayPrayerCard> createState() => _DisplayPrayerCardState();
}

class _DisplayPrayerCardState extends State<DisplayPrayerCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slightly faster
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutCirc, // Stronger, more explosive curve
    );

    if (widget.isBlinking) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant DisplayPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking != oldWidget.isBlinking) {
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
        final arSize = (widget.prayersFontSize * 1.88 * compactFactor).clamp(9.0, 36.0);
        final enSize = (widget.prayersFontSize * 1.22 * compactFactor).clamp(8.0, 26.0);
        final timeDisplaySize = (widget.prayersFontSize * 2.1 * compactFactor).clamp(10.0, 48.0);

        final baseCardColor = widget.isFocusCard ? colors.activeCardValue : colors.prayerOverlayValue;
        final textColor = widget.isFocusCard ? colors.activeCardTextValue : colors.inactiveCardTextValue;

        final numeralFormat = widget.designSettings.numeralFormat;
        final formattedTime = AppTimeFormat.time12h(context, widget.azanTime).formatNumerals(numeralFormat);

        final mainColumn = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.slot.icon,
              size: iconSize,
              color: textColor.withValues(alpha: 0.85),
            ),
            SizedBox(height: gap),
            Text(
              widget.slot.labelAr(s),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontLoader.getStyle(
                widget.designSettings.fontFamily,
                baseStyle: TextStyle(
                  fontSize: arSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Text(
              widget.slot.labelEn(s),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontLoader.getStyle(
                widget.designSettings.fontFamily,
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
                widget.designSettings.fontFamily,
                baseStyle: TextStyle(
                  fontSize: timeDisplaySize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        );

        final padded = EdgeInsets.symmetric(vertical: verticalPad, horizontal: 4);

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final pulseVal = _pulseAnimation.value;
            
            // STRONG PULSE: Glow and white overlay
            final glowColor = Colors.white.withValues(alpha: 0.45 * pulseVal);
            final cardColor = Color.lerp(baseCardColor, Colors.white, 0.12 * pulseVal)!;

            return Stack(
              children: [
                // Inner Card with background pulse
                PrayerCardBackground(
                  prayerCardColor: cardColor,
                  child: Padding(
                    padding: padded,
                    child: widget.isFocusCard
                        ? Column(
                            children: [
                              Expanded(
                                flex: 62,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: child,
                                ),
                              ),
                              Expanded(
                                flex: 38,
                                child: PrayerCardNextStrip(
                                  phase: widget.phase,
                                  remaining: widget.remaining,
                                  designSettings: widget.designSettings,
                                  prayersFontSize: widget.prayersFontSize * compactFactor,
                                  graceOpacityAnimation: widget.graceAnim,
                                ),
                              ),
                            ],
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: child,
                          ),
                  ),
                ),
                
                // Outer Pulse Overlay (Glow)
                if (widget.isBlinking)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: glowColor,
                            width: 3.5 * pulseVal,
                          ),
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
          child: mainColumn,
        );
      },
    );
  }
}

