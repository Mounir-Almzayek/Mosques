import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/color_extensions.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_time_format.dart';
import '../../../../core/utils/prayer_times_helper.dart';
import '../../../../data/models/mosque_model.dart';

class MosqueClockWidget extends StatefulWidget {
  final MosqueModel mosque;
  final Color primaryColor;

  const MosqueClockWidget({super.key, required this.mosque, required this.primaryColor});

  @override
  State<MosqueClockWidget> createState() => _MosqueClockWidgetState();
}

String _localizedPrayerName(BuildContext context, String raw) {
  final s = S.of(context);
  if (raw == PrayerTimesHelper.tomorrowFajrPrayerName) {
    return s.prayer_fajr_tomorrow;
  }
  final key = raw.split(' ').first;
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

class _MosqueClockWidgetState extends State<MosqueClockWidget> {
  late Timer _timer;
  late PrayerTimesHelper _helper;
  late Map<String, dynamic> _nextEvent;
  late Duration _countdown;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _helper = PrayerTimesHelper(widget.mosque);
    _now = DateTime.now();
    _nextEvent = _helper.getNextEvent();
    _countdown = (_nextEvent['targetTime'] as DateTime).difference(_now);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        // Update helper if coordinates or method change dynamically
        _helper = PrayerTimesHelper(widget.mosque);
        
        final newEvent = _helper.getNextEvent();
        // Recalculate if event changed (e.g. from Azan to Iqama)
        if (newEvent['prayerName'] != _nextEvent['prayerName'] || newEvent['isIqama'] != _nextEvent['isIqama']) {
          _nextEvent = newEvent;
        }

        final target = _nextEvent['targetTime'] as DateTime;
        _countdown = target.difference(_now);
        if (_countdown.isNegative) {
           _countdown = Duration.zero; // Brief pause before refresh
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

  @override
  Widget build(BuildContext context) {
    final clock = AppTimeFormat.clockParts12h(context, _now);
    final countdownStr = PrayerTimesHelper.formatDuration(_countdown);
    final isIqama = _nextEvent['isIqama'] as bool;
    final prayerNameRaw = _nextEvent['prayerName'] as String;
    final prayerName = _localizedPrayerName(context, prayerNameRaw);
    final s = S.of(context);
    final countdownTitle = isIqama
        ? s.display_time_until_iqama_for(prayerName)
        : s.display_time_until_adhan_for(prayerName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Real-time Clock
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              clock.hourMinute,
              style: TextStyle(fontSize: 140, fontWeight: FontWeight.bold, color: widget.primaryColor, height: 1.0),
            ),
            Text(
              clock.secondsAndPeriod,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: widget.primaryColor.withOpacityCompat(0.7)),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Countdown Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          decoration: BoxDecoration(
            color: isIqama ? Colors.red.withOpacityCompat(0.2) : Colors.green.withOpacityCompat(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isIqama ? Colors.red.withOpacityCompat(0.5) : Colors.green.withOpacityCompat(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                countdownTitle,
                style: TextStyle(fontSize: 24, letterSpacing: 2.0, color: widget.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                countdownStr,
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: widget.primaryColor, fontFamily: 'Courier'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
