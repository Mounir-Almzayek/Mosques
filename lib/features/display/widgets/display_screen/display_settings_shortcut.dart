import 'package:flutter/material.dart';

class DisplaySettingsShortcut extends StatelessWidget {
  const DisplaySettingsShortcut({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.transparent),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
