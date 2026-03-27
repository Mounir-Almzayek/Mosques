import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque_model.dart';
import '../../../../data/models/prayer_display_slot.dart';
import 'display_prayer_card.dart';
import 'display_spiritual_strip.dart';

/// The central content area of the display screen, containing prayer cards
/// and the spiritual announcement strip.
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

  static DateTime _azanFor(AdjustedPrayerTimes prayers, PrayerDisplaySlot slot) {
    switch (slot) {
      case PrayerDisplaySlot.fajr:
        return prayers.getByPrayer(Prayer.fajr)!.adhanTime;
      case PrayerDisplaySlot.sunrise:
        return prayers.getByPrayer(Prayer.sunrise)!.adhanTime;
      case PrayerDisplaySlot.dhuhr:
        return prayers.getByPrayer(Prayer.dhuhr)!.adhanTime;
      case PrayerDisplaySlot.asr:
        return prayers.getByPrayer(Prayer.asr)!.adhanTime;
      case PrayerDisplaySlot.maghrib:
        return prayers.getByPrayer(Prayer.maghrib)!.adhanTime;
      case PrayerDisplaySlot.isha:
        return prayers.getByPrayer(Prayer.isha)!.adhanTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayers = _helper.getTodayAdjustedTimes();
    final phase = _helper.getPrayerDisplayPhase(_now);
    final remaining = phase.focusTime.difference(_now);
    final slots = PrayerDisplaySlot.values;

    return LayoutBuilder(
      builder: (context, outer) {
        final isLandscape = outer.maxWidth > outer.maxHeight;
        final hPad = (outer.maxWidth * 0.012).clamp(6.0, 22.0);
        final gapTop = isLandscape
            ? (outer.maxHeight * 0.012).clamp(4.0, 16.0)
            : (outer.maxHeight * 0.028).clamp(8.0, 28.0);
        final gapMid = isLandscape
            ? (outer.maxHeight * 0.012).clamp(4.0, 14.0)
            : (outer.maxHeight * 0.022).clamp(8.0, 22.0);
        final gapBottom = isLandscape
            ? (outer.maxHeight * 0.018).clamp(6.0, 22.0)
            : (outer.maxHeight * 0.038).clamp(12.0, 44.0);

        final prayerRow = Padding(
          padding: EdgeInsets.only(
            bottom: isLandscape ? gapMid * 0.35 : gapMid * 0.45,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: slots.map((slot) {
              final azanTime = _azanFor(prayers, slot);
              final isFocusCard = _cardMatchesPhase(slot, phase);
              final graceAnim =
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
                    scale: isFocusCard ? 1.03 : 1.0,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: DisplayPrayerCard(
                      slot: slot,
                      azanTime: azanTime,
                      isFocusCard: isFocusCard,
                      phase: phase,
                      remaining: remaining,
                      designSettings: widget.designSettings,
                      baseFontSize: widget.baseFontSize,
                      graceAnim: graceAnim,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );

        final stripChild = SizedBox(
          width: 1200,
          child: DisplaySpiritualStrip(
            mosque: widget.mosque,
            primaryColor: widget.designSettings.inactiveCardTextColorValue,
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

              Expanded(flex: 10, child: Center(child: prayerRow)),
              SizedBox(height: gapMid),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.center,
                  child: FittedBox(fit: BoxFit.scaleDown, child: stripChild),
                ),
              ),

              SizedBox(height: gapBottom),
            ],
          ),
        );
      },
    );
  }
}
