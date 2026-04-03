import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../data/models/mosque_model.dart';
import 'top_header_clock_block.dart';
import 'top_header_date_block.dart';
import 'top_header_mosque_block.dart';

class TopHeaderWidget extends StatefulWidget {
  final MosqueModel mosque;
  final DesignSettingsModel designSettings;

  const TopHeaderWidget({
    super.key,
    required this.mosque,
    required this.designSettings,
  });

  @override
  State<TopHeaderWidget> createState() => _TopHeaderWidgetState();
}

class _TopHeaderWidgetState extends State<TopHeaderWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = Localizations.localeOf(context).languageCode;
    HijriCalendar.language = loc == 'ar' ? 'ar' : 'en';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final lang = Localizations.localeOf(context).languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final h = HijriCalendar.fromDate(_now);
    final weekday = DateFormat('EEEE', locale).format(_now);

    final numeralFormat = widget.designSettings.numeralFormat;
    final gregorianLong = DateFormat('d MMMM yyyy', locale)
        .format(_now)
        .formatNumerals(numeralFormat);
    final hijriSuffix = lang == 'ar' ? 'هـ' : 'AH';
    final hijriLine =
        '${h.hDay} ${h.getLongMonthName()} ${h.hYear} $hijriSuffix'
            .formatNumerals(numeralFormat);

    final headerColor = widget.designSettings.colors.primaryValue;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = (constraints.maxWidth / 1100).clamp(0.48, 1.0);
        
        final fontSizes = widget.designSettings.fontSizes;
        final mosqueBase = fontSizes.mosqueInfo * 1.28 * widthScale;
        final clockBase = fontSizes.clock * 1.28 * widthScale;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: TopHeaderMosqueBlock(
                  mosqueName: widget.mosque.name,
                  cityName: widget.mosque.city,
                  textColor: headerColor,
                  isRtl: isRtl,
                  base: mosqueBase,
                  numeralFormat: numeralFormat,
                  fontFamily: widget.designSettings.fontFamily,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: math.max(4.0, clockBase * 1.1),
              ),
              child: TopHeaderClockBlock(
                now: _now,
                textColor: headerColor,
                base: clockBase,
                numeralFormat: numeralFormat,
                fontFamily: widget.designSettings.fontFamily,
              ),
            ),
            Expanded(
              child: Align(
                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: TopHeaderDateBlock(
                  weekday: weekday,
                  gregorianLong: gregorianLong,
                  hijriLine: hijriLine,
                  textColor: headerColor,
                  isRtl: isRtl,
                  base: mosqueBase,
                  fontFamily: widget.designSettings.fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
