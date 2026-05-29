import 'package:flutter/material.dart';

import 'focus_highlight_box.dart';

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
