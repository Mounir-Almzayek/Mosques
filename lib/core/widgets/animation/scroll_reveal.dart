import 'package:flutter/material.dart';

import '../../enums/animation/reveal_direction.dart';
import 'scroll_visibility_detector.dart';

export '../../enums/animation/reveal_direction.dart';

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
    return ScrollVisibilityDetector(
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
