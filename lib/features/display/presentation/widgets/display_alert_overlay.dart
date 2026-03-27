import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/enums/app_numeral_format.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/utils/app_font_loader.dart';
import '../../../../data/models/announcement_model.dart';

/// Full-screen priority alert overlay.
/// Displays a high-priority message, hiding all other UI until dismissed.
class DisplayAlertOverlay extends StatefulWidget {
  final List<AnnouncementModel> alerts;
  final Color primaryColor;
  final Color backgroundColor;
  final AppNumeralFormat numeralFormat;
  final String fontFamily;

  const DisplayAlertOverlay({
    super.key,
    required this.alerts,
    required this.primaryColor,
    required this.backgroundColor,
    required this.numeralFormat,
    required this.fontFamily,
  });

  @override
  State<DisplayAlertOverlay> createState() => _DisplayAlertOverlayState();
}

class _DisplayAlertOverlayState extends State<DisplayAlertOverlay> {
  AnnouncementModel? _currentAlert;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _checkAlerts();
  }

  @override
  void didUpdateWidget(covariant DisplayAlertOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alerts != widget.alerts) {
      _checkAlerts();
    }
  }

  /// Finds an active alert if one exists.
  void _checkAlerts() {
    if (widget.alerts.isEmpty) {
      setState(() => _currentAlert = null);
      _dismissTimer?.cancel();
      return;
    }
    
    // Pick the first active alert.
    final alert = widget.alerts.first;
    if (_currentAlert?.id != alert.id) {
      setState(() => _currentAlert = alert);
      
      // Auto-dismiss after timeout (defaulting to 30 seconds if unspecified in admin logic).
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 30), () {
        if (!mounted) return;
        setState(() => _currentAlert = null);
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = _currentAlert;
    if (alert == null) return const SizedBox.shrink();

    final title = alert.title.formatNumerals(widget.numeralFormat);
    final subtitle = alert.subtitle?.formatNumerals(widget.numeralFormat);

    return Container(
      color: widget.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 120,
              color: Colors.amber,
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFontLoader.getStyle(
                widget.fontFamily,
                baseStyle: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
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
                    fontSize: 32,
                    color: widget.primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
