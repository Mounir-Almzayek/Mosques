import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/enums/app_numeral_format.dart';
import '../../../../../core/utils/app_font_loader.dart';
import '../../../../../core/utils/app_number_format.dart';
import '../../../../../data/models/mosque/announcement_model.dart';

/// صفحة التنبيهات العاجلة - تظهر ملء الشاشة عند وجود تنبيه نشط.
class DisplayAlertView extends StatefulWidget {
  final List<AnnouncementModel> alerts;
  final Color primaryColor;
  final Color backgroundColor;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;
  final VoidCallback onExpired;

  const DisplayAlertView({
    super.key,
    required this.alerts,
    required this.primaryColor,
    required this.backgroundColor,
    required this.numeralFormat,
    required this.fontFamily,
    required this.onExpired,
  });

  @override
  State<DisplayAlertView> createState() => _DisplayAlertViewState();
}

class _DisplayAlertViewState extends State<DisplayAlertView> {
  Timer? _timer;
  AnnouncementModel? _activeAlert;

  @override
  void initState() {
    super.initState();
    _updateActiveAlert();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant DisplayAlertView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerts != widget.alerts) {
      _updateActiveAlert();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateActiveAlert();
    });
  }

  void _updateActiveAlert() {
    if (widget.alerts.isEmpty) {
      if (_activeAlert != null) {
        setState(() => _activeAlert = null);
        widget.onExpired();
      }
      return;
    }

    final now = DateTime.now();
    AnnouncementModel? found;

    // خوارزمية البحث عن التنبيه النشط برمجياً بناءً على وقت الإضافة والمدة
    for (final a in widget.alerts) {
      final expiry = a.startDate.add(
        Duration(seconds: a.displayDurationSeconds),
      );
      if (now.isAfter(a.startDate) && now.isBefore(expiry)) {
        found = a;
        break;
      }
    }

    if (found?.id != _activeAlert?.id) {
      setState(() => _activeAlert = found);
      if (found == null) {
        widget.onExpired();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _activeAlert;
    if (alert == null) return const SizedBox.shrink();

    final title = alert.title.formatNumerals(widget.numeralFormat);
    final subtitle = alert.subtitle?.formatNumerals(widget.numeralFormat);

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(widget.primaryColor),
              const SizedBox(height: 48),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontLoader.getStyle(
                  widget.fontFamily,
                  baseStyle: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: widget.primaryColor,
                    height: 1.2,
                  ),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppFontLoader.getStyle(
                    widget.fontFamily,
                    baseStyle: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w500,
                      color: widget.primaryColor.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.campaign_rounded, size: 140, color: color),
    );
  }
}

