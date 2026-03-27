import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/utils/app_font_loader.dart';

import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../core/utils/color_extensions.dart';
import '../../../../core/utils/next_prayer_event.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque_model.dart';

/// Full-screen clock with a countdown to the next adhan or iqama.
class MosqueClockWidget extends StatefulWidget {
  final MosqueModel mosque;
  final Color primaryColor;

  const MosqueClockWidget({
    super.key,
    required this.mosque,
    required this.primaryColor,
  });

  @override
  State<MosqueClockWidget> createState() => _MosqueClockWidgetState();
}

class _MosqueClockWidgetState extends State<MosqueClockWidget> {
  late Timer _timer;
  late PrayerTimesHelper _helper;
  late NextPrayerEvent _nextEvent;
  late Duration _countdown;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _helper = PrayerTimesHelper(widget.mosque);
    _now = DateTime.now();
    _nextEvent = _helper.getNextEvent();
    _countdown = _nextEvent.targetTime.difference(_now);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        // The helper logic is internally cached/calculated based on widget.mosque.
        _helper = PrayerTimesHelper(widget.mosque);

        final newEvent = _helper.getNextEvent();
        if (newEvent.prayerName != _nextEvent.prayerName ||
            newEvent.isIqama != _nextEvent.isIqama) {
          _nextEvent = newEvent;
        }

        _countdown = _nextEvent.targetTime.difference(_now);
        if (_countdown.isNegative) {
          _countdown = Duration.zero;
          _nextEvent = _helper.getNextEvent();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant MosqueClockWidget oldWidget) {
    if (oldWidget.mosque != widget.mosque) {
      _helper = PrayerTimesHelper(widget.mosque);
      _nextEvent = _helper.getNextEvent();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Resolves a raw prayer key (e.g. `FAJR`, `FAJR_TOMORROW`) to a
  /// localized display name.
  String _localizedPrayerName(BuildContext context, String raw) {
    final s = S.of(context);
    if (raw == PrayerTimesHelper.tomorrowFajrPrayerName) {
      return s.prayer_fajr_tomorrow;
    }
    final key = raw.split('(').first.trim().toUpperCase();
    switch (key) {
      case 'FAJR':
        return s.prayer_fajr;
      case 'SUNRISE':
        return s.prayer_sunrise;
      case 'DHUHR':
        return s.prayer_dhuhr;
      case 'ASR':
        return s.prayer_asr;
      case 'MAGHRIB':
        return s.prayer_maghrib;
      case 'ISHA':
        return s.prayer_isha;
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final numeralFormat = widget.mosque.designSettings.numeralFormat;
    final fontFamily = widget.mosque.designSettings.fontFamily;
    final clock = AppTimeFormat.clockParts12h(context, _now);

    // Apply numerical formatting to time strings.
    final hourMinute = clock.hourMinute.formatNumerals(numeralFormat);
    final seconds = clock.seconds.formatNumerals(numeralFormat);
    final period = ' ${clock.period}'.formatNumerals(numeralFormat);
    final secondsAndPeriodStr = '$seconds$period';
    final countdownStr = PrayerTimesHelper.formatDuration(
      _countdown,
    ).formatNumerals(numeralFormat);

    final prayerName = _localizedPrayerName(context, _nextEvent.prayerName);
    final s = S.of(context);
    final countdownTitle =
        (_nextEvent.isIqama
                ? s.display_time_until_iqama_for(prayerName)
                : s.display_time_until_adhan_for(prayerName))
            .formatNumerals(numeralFormat);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hourMinute,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              secondsAndPeriodStr,
              style: AppFontLoader.getStyle(
                fontFamily,
                baseStyle: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: widget.primaryColor.withOpacityCompat(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          decoration: BoxDecoration(
            color: _nextEvent.isIqama
                ? Colors.red.withOpacityCompat(0.12)
                : Colors.green.withOpacityCompat(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _nextEvent.isIqama
                  ? Colors.red.withOpacityCompat(0.4)
                  : Colors.green.withOpacityCompat(0.4),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                countdownTitle,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 24,
                    letterSpacing: 2.0,
                    color: widget.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                countdownStr,
                style: AppFontLoader.getStyle(
                  fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
