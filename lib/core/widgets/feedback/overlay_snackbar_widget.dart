import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../utils/responsive_layout.dart';
import 'snackbar_config.dart';
import 'snackbar_content.dart';

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
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
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
      bottom: MediaQuery.of(context).padding.bottom + 24.h,
      left: widget.config.margin.left,
      right: widget.config.margin.right,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.responsive(
                      double.infinity,
                      tablet: 500.w,
                      desktop: 600.w,
                    ),
                  ),
                  child: SnackbarContent(
                    message: widget.message,
                    type: widget.type,
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
    );
  }
}
