import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../data/models/mosque/announcement_model.dart';
import 'alert_qr_card.dart';
import 'alert_text_block.dart';

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
    final qrUrl = alert.qrCodeUrl;
    final hasQr = qrUrl != null && qrUrl.trim().isNotEmpty;

    final bg = widget.backgroundColor;
    final accent = widget.primaryColor;

    return Scaffold(
      backgroundColor: bg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(Colors.white.withValues(alpha: 0.04), bg),
              bg,
              Color.alphaBlend(Colors.black.withValues(alpha: 0.10), bg),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
            child: Builder(
              builder: (context) {
                final textBlock = AlertTextBlock(
                  title: title,
                  subtitle: subtitle,
                  accent: accent,
                  fontFamily: widget.fontFamily,
                  alertsFontSize: widget.alertsFontSize,
                  badgeLabel: S.of(context).alert_urgent_badge,
                  center: !hasQr,
                );

                if (!hasQr) {
                  return Center(child: textBlock);
                }

                // QR anchored to the trailing edge of the screen, text fills
                // the remaining space and is vertically centered next to it.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: textBlock,
                      ),
                    ),
                    const SizedBox(width: 48),
                    AlertQrCard(
                      data: qrUrl,
                      accent: accent,
                      fontFamily: widget.fontFamily,
                      caption: S.of(context).scan_qr_hint,
                      alertsFontSize: widget.alertsFontSize,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
