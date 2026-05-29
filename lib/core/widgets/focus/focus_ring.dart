import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';

/// The single source of truth for "what a focused control looks like" on
/// TV / keyboard navigation. Presentational only — does not handle taps.
///
/// Uses [FocusableActionDetector.onShowFocusHighlight] so the ring appears
/// for directional/keyboard focus but NOT for casual pointer taps.
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

  void _onFocusChange(bool focused) {
    if (focused == _showHighlight) return;
    setState(() => _showHighlight = focused);
    widget.onFocusChange?.call(focused);
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onShowFocusHighlight: (v) {
        // Fired for traditional (keyboard/directional) focus highlighting.
        if (v == _showHighlight) return;
        setState(() => _showHighlight = v);
        widget.onFocusChange?.call(v);
      },
      onFocusChange: (focused) {
        // Also respond to direct focus changes (e.g. programmatic requestFocus),
        // so the ring is visible whenever the node is focused.
        _onFocusChange(focused);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _showHighlight ? 1.04 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          key: _showHighlight ? const ValueKey('focus_ring_highlight') : null,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _showHighlight ? AppColors.focusRing : Colors.transparent,
              width: 3,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
