import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollVisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool visible) onVisibilityChanged;

  const ScrollVisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<ScrollVisibilityDetector> createState() =>
      _ScrollVisibilityDetectorState();
}

class _ScrollVisibilityDetectorState extends State<ScrollVisibilityDetector> {
  bool _isCurrentlyVisible = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: widget.child,
    );
  }

  // A more robust way to detect visibility
  void _checkVisibility() {
    if (!mounted || _isCurrentlyVisible) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    // Use a slightly more aggressive check:
    // Is any part of this widget potentially reachable or near the viewport?
    final viewport = RenderAbstractViewport.of(renderObject);
    final revealOffset = viewport.getOffsetToReveal(renderObject, 0.0).offset;
    final scrollOffset = Scrollable.of(context).position.pixels;
    final viewportHeight = Scrollable.of(context).position.viewportDimension;

    // Trigger reveal when the item is more strictly within the viewport (0.9 to make it visible while animating)
    final isVisible = (revealOffset - scrollOffset) < viewportHeight * 0.9;

    if (isVisible) {
      _reveal();
    }
  }

  void _reveal() {
    if (_isCurrentlyVisible) return;
    _isCurrentlyVisible = true;
    widget.onVisibilityChanged(true);
  }

  @override
  void initState() {
    super.initState();
    // Check initial visibility after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
      // Fail-safe: Reveal after 2 seconds no matter what to ensure content isn't lost
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isCurrentlyVisible) {
          _reveal();
        }
      });
    });
  }
}
