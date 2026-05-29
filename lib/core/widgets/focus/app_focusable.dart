import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'focus_highlight_box.dart';

/// A focusable, tappable control for TV remote / keyboard navigation.
///
/// Replaces bare [GestureDetector]s so the control is reachable by D-pad and
/// activatable by OK/center/Enter/Select/Space, while preserving pointer taps.
/// Shows the standard [FocusHighlightBox] when focused via D-pad/keyboard.
class AppFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final String? semanticLabel;

  const AppFocusable({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  State<AppFocusable> createState() => _AppFocusableState();
}

class _AppFocusableState extends State<AppFocusable> {
  bool _showHighlight = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: active,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: active,
        onShowFocusHighlight: (v) {
          if (v == _showHighlight) return;
          setState(() => _showHighlight = v);
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (active) widget.onPressed!.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: active ? widget.onPressed : null,
          child: FocusHighlightBox(
            active: _showHighlight,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
