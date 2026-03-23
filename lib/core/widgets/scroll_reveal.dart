import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum RevealDirection { up, down, left, right, none }

class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final RevealDirection direction;
  final double offset;
  final Curve curve;

  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.direction = RevealDirection.up,
    this.offset = 50.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case RevealDirection.up:
        return Offset(0, widget.offset / 100);
      case RevealDirection.down:
        return Offset(0, -widget.offset / 100);
      case RevealDirection.left:
        return Offset(widget.offset / 100, 0);
      case RevealDirection.right:
        return Offset(-widget.offset / 100, 0);
      case RevealDirection.none:
        return Offset.zero;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(bool visible) {
    if (visible && !_isVisible) {
      setState(() => _isVisible = true);
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(
                _slideAnimation.value.dx * 100,
                _slideAnimation.value.dy * 100,
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool visible) onVisibilityChanged;

  const _VisibilityDetector({
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
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
