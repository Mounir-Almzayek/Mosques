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

/// Wraps a child so it shows the standard focus highlight when it gains
/// directional/keyboard (traditional) focus. Highlight-only — does not handle
/// activation; use [AppFocusable] for tappable controls.
class FocusRing extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<bool>? onFocusChange;

  const FocusRing({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.onFocusChange,
  });

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _showHighlight = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onShowFocusHighlight: (v) {
        if (v == _showHighlight) return;
        setState(() => _showHighlight = v);
        widget.onFocusChange?.call(v);
      },
      child: FocusHighlightBox(
        active: _showHighlight,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}
