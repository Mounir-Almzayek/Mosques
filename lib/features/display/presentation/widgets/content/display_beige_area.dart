import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../core/utils/prayer_times_helper.dart';
import '../../../../../data/models/mosque_model.dart';
import '../../../../../data/models/prayer_display_slot.dart';
import '../prayer/display_prayer_card.dart';
import 'display_spiritual_strip.dart';

/// The central content area of the display screen, containing prayer cards
/// and the spiritual announcement strip.
class DisplayBeigeArea extends StatefulWidget {
  final MosqueModel mosque;
  final List<AnnouncementModel> platformAnnouncements;
  final DesignSettingsModel designSettings;
  final double prayersFontSize;
  final double contentFontSize;

  const DisplayBeigeArea({
    super.key,
    required this.mosque,
    this.platformAnnouncements = const [],
    required this.designSettings,
    required this.prayersFontSize,
    required this.contentFontSize,
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
        // The helper instance is cheap; re-syncing to ensure it handles mosque updates
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

  /// Finds the correct adhan time for a card slot.
  /// If today's time for this slot is already past (and it's not the focused card in iqama mode),
  /// we show tomorrow's time to keep the UI relevant.
  DateTime _azanTimeForSlot(
    DateTime now,
    AdjustedPrayerTimes today,
    PrayerDisplaySlot slot,
  ) {
    final todayItem = today.getByPrayerName(slot.name.toUpperCase());
    if (todayItem == null) return now;

    // Determine if we should show tomorrow's time.
    // Logic: If Today's Adhan + Grace (e.g. 1 min) is in the past, and it's NOT the current focus,
    // then this card is "Done" for today and should show tomorrow's time.
    final cutoff = todayItem.iqamaTime.add(const Duration(minutes: 1));
    if (now.isAfter(cutoff)) {
      final tomorrow = _helper.buildAdjustedPrayerTimes(
        now.add(const Duration(days: 1)),
      );
      final tomItem = tomorrow.getByPrayerName(slot.name.toUpperCase());
      return tomItem?.adhanTime ?? todayItem.adhanTime;
    }

    return todayItem.adhanTime;
  }

  @override
  Widget build(BuildContext context) {
    final today = _helper.buildAdjustedPrayerTimes(_now);
    final phase = _helper.getPrayerDisplayPhase(_now);
    final remaining = phase.focusTime.difference(_now);
    final slots = PrayerDisplaySlot.values;
    final colors = widget.designSettings.colors;

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
              final azanTime = _azanTimeForSlot(_now, today, slot);
              final isFocusCard = _cardMatchesPhase(slot, phase);

              // Blinking logic: Matches hour/minute AND matches day for Adhan, 
              // OR is currently in the active grace period after iqama.
              final isBlinking = (_now.hour == azanTime.hour && 
                                 _now.minute == azanTime.minute &&
                                 _now.day == azanTime.day) ||
                                 (isFocusCard && 
                                  phase.kind == PrayerDisplayPhaseKind.graceAfterIqama);

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
                      prayersFontSize: widget.prayersFontSize,
                      graceAnim: graceAnim,
                      isBlinking: isBlinking,
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
            primaryColor: colors.inactiveCardTextValue,
            cardColor: colors.prayerOverlayValue,
            contentFontSize: widget.contentFontSize,
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
