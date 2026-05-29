import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen-level wrapper that makes a screen remote/keyboard friendly:
/// groups focus traversal and routes Back/Escape to a dismiss action.
///
/// Autofocus is the responsibility of the screen's first control (it sets
/// `autofocus: true`); this scope only owns traversal grouping + dismissal.
class TvNavigationScope extends StatelessWidget {
  final Widget child;

  /// Called when the user presses Back/Escape. Defaults to popping the
  /// current route if one can be popped.
  final VoidCallback? onDismiss;

  const TvNavigationScope({super.key, required this.child, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.goBack): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              final cb = onDismiss;
              if (cb != null) {
                cb();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(child: child),
      ),
    );
  }
}
