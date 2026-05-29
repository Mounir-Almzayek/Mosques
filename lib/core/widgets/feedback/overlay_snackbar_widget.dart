import 'package:flutter/material.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../utils/responsive_layout.dart';
import 'snackbar_config.dart';
import 'snackbar_content.dart';

/// Hosts a single toast in the root overlay.
///
/// The toast is anchored to the top of the screen and animates in with a
/// smooth slide-down + fade + subtle scale (ease-out). It can be flung
/// upward to dismiss. Top placement keeps it clear of the keyboard and
/// bottom navigation that the settings forms rely on.
class OverlaySnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final SnackbarConfig config;
  final VoidCallback onDismiss;

  const OverlaySnackbarWidget({
    super.key,
    required this.message,
    required this.type,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<OverlaySnackbarWidget> createState() => _OverlaySnackbarWidgetState();
}

class _OverlaySnackbarWidgetState extends State<OverlaySnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: widget.config.margin.left,
      right: widget.config.margin.right,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.responsive(
                        double.infinity,
                        tablet: 480,
                        desktop: 560,
                      ),
                    ),
                    child: Dismissible(
                      key: const ValueKey('unified_snackbar'),
                      direction: DismissDirection.up,
                      onDismissed: (_) => widget.onDismiss(),
                      child: SnackbarContent(
                        message: widget.message,
                        type: widget.type,
                        duration: widget.config.duration,
                        showCloseButton: widget.config.showCloseButton,
                        actionLabel: widget.config.actionLabel,
                        onActionTap: widget.config.onActionTap,
                        onClose: widget.onDismiss,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
