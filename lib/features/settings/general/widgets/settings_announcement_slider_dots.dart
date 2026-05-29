import 'package:flutter/material.dart';

class SettingsAnnouncementSliderDots extends StatelessWidget {
  const SettingsAnnouncementSliderDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsetsDirectional.only(start: 5),
          width: selected ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.42),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
