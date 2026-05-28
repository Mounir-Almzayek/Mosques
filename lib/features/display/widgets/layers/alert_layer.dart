import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../data/models/mosque/announcement_model.dart';

/// Fullscreen alert overlay -- the highest-priority display layer.
///
/// Iterates through [alerts] and shows whichever one is currently active
/// (i.e. `now` is between `startDate` and `startDate + displayDurationSeconds`).
/// Calls [onExpired] once no alert is active any longer.
class AlertLayer extends StatefulWidget {
  final List<AnnouncementModel> alerts;
  final Color primaryColor;
  final Color backgroundColor;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;
  final VoidCallback onExpired;
  final double alertsFontSize;

  const AlertLayer({
    super.key,
    required this.alerts,
    required this.primaryColor,
    required this.backgroundColor,
    required this.numeralFormat,
    required this.fontFamily,
    required this.onExpired,
    required this.alertsFontSize,
  });

  @override
  State<AlertLayer> createState() => _AlertLayerState();
}

class _AlertLayerState extends State<AlertLayer> {
  Timer? _timer;
  AnnouncementModel? _activeAlert;

  @override
  void initState() {
    super.initState();
    _updateActiveAlert();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AlertLayer oldWidget) {
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

    for (final alert in widget.alerts) {
      if (!alert.isPublished || alert.publishedAt == null) continue;
      final expiry = alert.publishedAt!.add(
        Duration(seconds: alert.publishDurationSeconds),
      );
      if (now.isBefore(expiry)) {
        found = alert;
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
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontLoader.getStyle(
                  widget.fontFamily,
                  baseStyle: TextStyle(
                    fontSize: (widget.alertsFontSize * 3.2).clamp(24.0, 120.0),
                    fontWeight: FontWeight.w900,
                    color: widget.primaryColor,
                    height: 1.2,
                  ),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppFontLoader.getStyle(
                    widget.fontFamily,
                    baseStyle: TextStyle(
                      fontSize: (widget.alertsFontSize * 1.9).clamp(14.0, 72.0),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.campaign_rounded, size: (widget.alertsFontSize * 3.2).clamp(24.0, 120.0), color: color),
    );
  }
}
