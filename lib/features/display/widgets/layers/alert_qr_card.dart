import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AlertQrCard extends StatelessWidget {
  final String data;
  final Color accent;
  final String fontFamily;
  final String caption;
  final double alertsFontSize;

  const AlertQrCard({
    super.key,
    required this.data,
    required this.accent,
    required this.fontFamily,
    required this.caption,
    required this.alertsFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final qrSize = (alertsFontSize * 9).clamp(160.0, 320.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: qrSize,
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
