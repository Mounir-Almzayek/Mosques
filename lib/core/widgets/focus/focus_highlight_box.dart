import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';

/// Presentational focus highlight — the single source of truth for what a
/// focused control looks like (ring + subtle scale). Pure visual; owns no
/// focus node. [active] is driven by the focusable parent.
class FocusHighlightBox extends StatelessWidget {
  final bool active;
  final BorderRadius borderRadius;
  final Widget child;

  const FocusHighlightBox({
    super.key,
    required this.active,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      scale: active ? 1.04 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        key: active ? const ValueKey('focus_ring_highlight') : null,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: active ? AppColors.focusRing : Colors.transparent,
            width: 3,
          ),
        ),
        child: child,
      ),
    );
  }
}
