import 'package:flutter/material.dart';
import '../../../../core/enums/display/display_layer_kind.dart';

class LayerTransitionWrapper extends StatelessWidget {
  final DisplayLayerKind activeLayer;
  final Widget child;
  final Duration duration;

  const LayerTransitionWrapper({
    super.key,
    required this.activeLayer,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(activeLayer),
        child: child,
      ),
    );
  }
}
