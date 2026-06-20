import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/utils/prayer_times_helper.dart';
import 'preadhan_countdown_inline.dart';
import '../../../../data/models/mosque/mosque_bootstrap.dart';
import '../prayer/prayer_cards_row.dart';
import 'religious_content_inline.dart';

class DisplayBeigeArea extends StatefulWidget {
  final MosqueBootstrap mosque;
  final DisplaySettings designSettings;
  final bool showReligiousContent;
  final int slideIndex;

  const DisplayBeigeArea({
    super.key,
    required this.mosque,
    required this.designSettings,
    this.showReligiousContent = false,
    this.slideIndex = 0,
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _helper = PrayerTimesHelper(widget.mosque);
      });
    });
  }

  @override
  void didUpdateWidget(covariant DisplayBeigeArea old) {
    super.didUpdateWidget(old);
    if (old.mosque != widget.mosque) _helper = PrayerTimesHelper(widget.mosque);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.designSettings;
    return LayoutBuilder(
      builder: (context, outer) {
        final hPad = (outer.maxWidth * 0.012).clamp(6.0, 22.0);
        final vPad = (outer.maxHeight * 0.02).clamp(6.0, 22.0);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: widget.showReligiousContent
                ? (() {
                    final phase = _helper.getPrayerDisplayPhase(
                      _now,
                      preAdhanMinutes: widget.mosque.prayerSettings.preAdhanMinutes,
                      adhanMomentDurationSeconds:
                          widget.mosque.prayerSettings.adhanMomentDurationSeconds,
                    );
                    if (phase.kind == PrayerDisplayPhaseKind.preAdhan ||
                        phase.kind == PrayerDisplayPhaseKind.iqama) {
                      return PreAdhanCountdownInline(
                        key: const ValueKey('preAdhan'),
                        helper: _helper,
                        now: _now,
                        designSettings: design,
                      );
                    }
                    return ReligiousContentInline(
                      key: const ValueKey('religious'),
                      mosque: widget.mosque,
                      designSettings: design,
                      slideIndex: widget.slideIndex,
                      religiousContentFontSize:
                          design.contentFontSize,
                    );
                  })()
                : PrayerCardsRow(
                    key: const ValueKey('prayers'),
                    mosque: widget.mosque,
                    designSettings: design,
                    helper: _helper,
                    now: _now,
                    focusScale: design.prayerCardScale,
                  ),
          ),
        );
      },
    );
  }
}
