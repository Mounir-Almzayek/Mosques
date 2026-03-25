import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/models/prayer_display_slot.dart';
import 'display_spiritual_strip.dart';
import 'prayer_card_background.dart';
import 'prayer_card_next_strip.dart';

class DisplayBeigeArea extends StatefulWidget {
  final MosqueModel mosque;
  final List<AnnouncementModel> platformAnnouncements;
  final DesignSettingsModel designSettings;
  final double baseFontSize;

  const DisplayBeigeArea({
    super.key,
    required this.mosque,
    this.platformAnnouncements = const [],
    required this.designSettings,
    required this.baseFontSize,
  });

  @override
  State<DisplayBeigeArea> createState() => _DisplayBeigeAreaState();
}

class _DisplayBeigeAreaState extends State<DisplayBeigeArea> {
  late Timer _timer;
  late PrayerTimesHelper _helper;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _helper = PrayerTimesHelper(widget.mosque);
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _helper = PrayerTimesHelper(widget.mosque);
      });
    });
  }

  @override
  void didUpdateWidget(covariant DisplayBeigeArea oldWidget) {
    if (oldWidget.mosque != widget.mosque) {
      _helper = PrayerTimesHelper(widget.mosque);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static bool _cardMatchesPhase(
    PrayerDisplaySlot slot,
    PrayerDisplayPhase phase,
  ) {
    final parsed = PrayerDisplaySlot.tryParsePhaseKey(phase.prayerNameKey);
    return parsed == slot;
  }

  static DateTime _azanFor(PrayerTimes prayers, PrayerDisplaySlot slot) {
    switch (slot) {
      case PrayerDisplaySlot.fajr:
        return prayers.fajr;
      case PrayerDisplaySlot.sunrise:
        return prayers.sunrise;
      case PrayerDisplaySlot.dhuhr:
        return prayers.dhuhr;
      case PrayerDisplaySlot.asr:
        return prayers.asr;
      case PrayerDisplaySlot.maghrib:
        return prayers.maghrib;
      case PrayerDisplaySlot.isha:
        return prayers.isha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final prayers = _helper.getTodayPrayerTimes();
    final phase = _helper.getPrayerDisplayPhase(_now);
    final remaining = phase.focusTime.difference(_now);

    final slots = PrayerDisplaySlot.values;

    return LayoutBuilder(
      builder: (context, outer) {
        final isLandscape = outer.maxWidth > outer.maxHeight;
        // In landscape, reserve a bounded share for the spiritual strip so prayer
        // cards keep enough height; typography stays readable without tiny FittedBox.
        final gapTop = isLandscape
            ? (outer.maxHeight * 0.012).clamp(4.0, 16.0)
            : (outer.maxHeight * 0.028).clamp(8.0, 28.0);
        final gapMid = isLandscape
            ? (outer.maxHeight * 0.012).clamp(4.0, 14.0)
            : (outer.maxHeight * 0.022).clamp(8.0, 22.0);
        final gapBottom = isLandscape
            ? (outer.maxHeight * 0.018).clamp(6.0, 22.0)
            : (outer.maxHeight * 0.038).clamp(12.0, 44.0);
        final hPad = (outer.maxWidth * 0.012).clamp(6.0, 22.0);
        final stripMaxW = math.min(outer.maxWidth * 0.94, 980.0);

        final prayerRow = Padding(
          padding: EdgeInsets.only(
            bottom: isLandscape ? gapMid * 0.35 : gapMid * 0.45,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...slots.map((slot) {
                final String arName = slot.labelAr(s);
                final String enName = slot.labelEn(s);
                final DateTime azanTime = _azanFor(prayers, slot);

                final bool isFocusCard = _cardMatchesPhase(slot, phase);
                final Animation<double>? graceAnim =
                    isFocusCard &&
                        phase.kind == PrayerDisplayPhaseKind.graceAfterIqama
                    ? const AlwaysStoppedAnimation<double>(1.0)
                    : null;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (outer.maxWidth * 0.006).clamp(3.0, 10.0),
                    ),
                    child: AnimatedScale(
                      scale: isFocusCard
                          ? (outer.maxHeight < 420 ? 1.02 : 1.035)
                          : 1.0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        child: PrayerCardBackground(
                          prayerCardColor:
                              widget.designSettings.prayerCardColorValue,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Use true height ratio — a minimum floor (e.g. 0.48) made
                              // fonts too large vs actual space in landscape.
                              final maxH = constraints.maxHeight;
                              final maxW = constraints.maxWidth;
                              // Slightly lower reference than 320 → larger type at same
                              // pixel height; width ref 110 → a bit more room per card.
                              final compactFactorH = (maxH / 275.0).clamp(
                                0.02,
                                1.0,
                              );
                              final compactFactorW = (maxW / 110.0).clamp(
                                0.22,
                                1.0,
                              );
                              var compactFactor = math.min(
                                compactFactorH,
                                compactFactorW,
                              );
                              final textScale = MediaQuery.textScalerOf(
                                context,
                              ).scale(1.0);
                              if (textScale > 1.0) {
                                compactFactor /= 1.0 + 0.35 * (textScale - 1.0);
                              }
                              compactFactor = math.min(
                                compactFactor * 1.06,
                                1.0,
                              );
                              final verticalPad = math
                                  .min(20.0 * compactFactor, maxH * 0.11)
                                  .clamp(0.0, maxH * 0.14);
                              final gap = math.min(
                                12.0 * compactFactor,
                                maxH * 0.07,
                              );
                              final iconSize = math.min(
                                42.0 * compactFactor,
                                maxH * 0.30,
                              );
                              final arSize =
                                  (widget.baseFontSize * 1.88 * compactFactor)
                                      .clamp(9.0, 36.0);
                              final enSize =
                                  (widget.baseFontSize * 1.22 * compactFactor)
                                      .clamp(8.0, 26.0);
                              final timeSize =
                                  (widget.baseFontSize * 2.2 * compactFactor)
                                      .clamp(10.0, 42.0);
                              final timeDisplaySize =
                                  timeSize * (1.0 + 0.14 * compactFactor);

                              // Main block only — must not sit in the same [FittedBox] as
                              // [PrayerCardNextStrip], or the strip's height makes the
                              // whole card scale down and shrinks icon/text (next-prayer card).
                              final mainColumn = Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    slot.icon,
                                    size: iconSize,
                                    color: widget
                                        .designSettings
                                        .primaryColorValue
                                        .withValues(alpha: 0.85),
                                  ),
                                  SizedBox(height: gap),
                                  Text(
                                    arName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: arSize,
                                      fontWeight: FontWeight.bold,
                                      color: widget
                                          .designSettings
                                          .primaryColorValue,
                                    ),
                                  ),
                                  Text(
                                    enName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: enSize,
                                      color: widget
                                          .designSettings
                                          .primaryColorValue
                                          .withValues(alpha: 0.72),
                                    ),
                                  ),
                                  SizedBox(height: gap),
                                  Text(
                                    AppTimeFormat.time12h(context, azanTime),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: timeDisplaySize,
                                      fontWeight: FontWeight.bold,
                                      color: widget
                                          .designSettings
                                          .primaryColorValue,
                                    ),
                                  ),
                                ],
                              );

                              final padded = EdgeInsets.symmetric(
                                vertical: verticalPad,
                                horizontal: 5,
                              );

                              if (isFocusCard) {
                                return Padding(
                                  padding: padded,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 62,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.center,
                                          child: mainColumn,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 38,
                                        child: PrayerCardNextStrip(
                                          phase: phase,
                                          remaining: remaining,
                                          designSettings:
                                              widget.designSettings,
                                          baseFontSize: widget.baseFontSize *
                                              compactFactor,
                                          graceOpacityAnimation: graceAnim,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Padding(
                                padding: padded,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: mainColumn,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );

        final stripChild = SizedBox(
          width: stripMaxW,
          child: DisplaySpiritualStrip(
            mosque: widget.mosque,
            primaryColor: widget.designSettings.primaryColorValue,
            cardColor: widget.designSettings.prayerCardColorValue,
            baseFontSize: widget.baseFontSize,
          ),
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: gapTop),
              if (isLandscape) ...[
                Expanded(flex: 10, child: Center(child: prayerRow)),
                SizedBox(height: gapMid),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: stripChild,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(child: Center(child: prayerRow)),
                SizedBox(height: gapMid),
                Align(alignment: Alignment.center, child: stripChild),
              ],
              SizedBox(height: gapBottom),
            ],
          ),
        );
      },
    );
  }
}
