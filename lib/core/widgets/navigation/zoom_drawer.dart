import 'package:flutter/material.dart';

/// Controller for [ZoomDrawer] that manages open/closed state.
class ZoomDrawerController extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }
}

/// A slide-and-scale drawer widget.
///
/// The [menuScreen] slides in from the side while the [mainScreen]
/// scales down and translates to reveal the menu beneath it.
class ZoomDrawer extends StatefulWidget {
  const ZoomDrawer({
    super.key,
    required this.controller,
    required this.menuScreen,
    required this.mainScreen,
    this.scale = 0.85,
    this.slideWidth = 265.0,
    this.borderRadius = 24.0,
    this.duration = const Duration(milliseconds: 300),
  });

  final ZoomDrawerController controller;
  final Widget menuScreen;
  final Widget mainScreen;
  final double scale;
  final double slideWidth;
  final double borderRadius;
  final Duration duration;

  @override
  State<ZoomDrawer> createState() => _ZoomDrawerState();
}

class _ZoomDrawerState extends State<ZoomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _radiusAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    widget.controller.addListener(_onControllerChanged);
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale).animate(curved);
    _slideAnim =
        Tween<double>(begin: 0.0, end: widget.slideWidth).animate(curved);
    _radiusAnim =
        Tween<double>(begin: 0.0, end: widget.borderRadius).animate(curved);
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void didUpdateWidget(ZoomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }

    if (oldWidget.duration != widget.duration) {
      _animController.duration = widget.duration;
    }

    if (oldWidget.scale != widget.scale ||
        oldWidget.slideWidth != widget.slideWidth ||
        oldWidget.borderRadius != widget.borderRadius) {
      final curved = CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
      );
      _scaleAnim =
          Tween<double>(begin: 1.0, end: widget.scale).animate(curved);
      _slideAnim =
          Tween<double>(begin: 0.0, end: widget.slideWidth).animate(curved);
      _radiusAnim =
          Tween<double>(begin: 0.0, end: widget.borderRadius).animate(curved);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      children: [
        // Menu screen behind
        widget.menuScreen,

        // Main screen on top with animation
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final slide = isRTL ? -_slideAnim.value : _slideAnim.value;
            final scale = _scaleAnim.value;
            final radius = _radiusAnim.value;

            return Transform(
              transform: Matrix4.identity()
                ..translateByDouble(slide, 0, 0, 1)
                ..scaleByDouble(scale, scale, 1, 1),
              alignment:
                  isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  children: [
                    child!,
                    // Tap-to-close overlay when drawer is open
                    if (_animController.value > 0)
                      GestureDetector(
                        onTap: widget.controller.close,
                        child: Container(
                          color: Colors.black.withValues(
                            alpha: 0.15 * _animController.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          child: widget.mainScreen,
        ),
      ],
    );
  }
}
