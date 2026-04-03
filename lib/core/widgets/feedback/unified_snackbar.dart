import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../styles/app_colors.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';
export '../../enums/feedback/snackbar_type.dart';

/// Snackbar Configuration
class SnackbarConfig {
  final Duration duration;
  final SnackBarBehavior behavior;
  final EdgeInsets margin;
  final double? width;
  final bool showCloseButton;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SnackbarConfig({
    this.duration = const Duration(seconds: 3),
    this.behavior = SnackBarBehavior.floating,
    this.margin = const EdgeInsets.all(16),
    this.width,
    this.showCloseButton = false,
    this.onTap,
    this.actionLabel,
    this.onActionTap,
  });
}

/// Unified Snackbar Service
class UnifiedSnackbar {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _currentOverlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    SnackbarConfig? config,
  }) {
    final snackbarConfig =
        config ??
        const SnackbarConfig(
          duration: Duration(seconds: 2),
          showCloseButton: false,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlaySnackbar(
        context,
        message: message,
        type: type,
        config: snackbarConfig,
      );
    });
  }

  static void _showOverlaySnackbar(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    required SnackbarConfig config,
  }) {
    _removeOverlay();

    try {
      if (!context.mounted) return;

      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) return;

      _currentOverlayEntry = OverlayEntry(
        builder: (context) => _OverlaySnackbarWidget(
          message: message,
          type: type,
          config: config,
          onDismiss: _removeOverlay,
        ),
      );

      overlay.insert(_currentOverlayEntry!);

      Future.delayed(config.duration, () {
        _removeOverlay();
      });
    } catch (e) {
      _removeOverlay();
    }
  }

  static void _removeOverlay() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }

  static void showGlobal({
    required String message,
    SnackbarType type = SnackbarType.info,
    SnackbarConfig? config,
  }) {
    final snackbarConfig = config ?? const SnackbarConfig();
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle()),
        behavior: snackbarConfig.behavior,
        duration: snackbarConfig.duration,
        margin: snackbarConfig.margin,
        width: snackbarConfig.width,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    SnackbarConfig? config,
  }) {
    show(context, message: message, type: SnackbarType.success, config: config);
  }

  static void error(
    BuildContext context, {
    required String message,
    SnackbarConfig? config,
  }) {
    show(context, message: message, type: SnackbarType.error, config: config);
  }

  static void info(
    BuildContext context, {
    required String message,
    SnackbarConfig? config,
  }) {
    show(context, message: message, type: SnackbarType.info, config: config);
  }

  static void warning(
    BuildContext context, {
    required String message,
    SnackbarConfig? config,
  }) {
    show(context, message: message, type: SnackbarType.warning, config: config);
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final bool showCloseButton;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onClose;

  const _SnackbarContent({
    required this.message,
    required this.type,
    required this.showCloseButton,
    this.actionLabel,
    this.onActionTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _getBorderColor(), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityCompat(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(context),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            SizedBox(width: 8.w),
            _buildActionButton(context),
          ],
          if (showCloseButton) ...[
            SizedBox(width: 8.w),
            _buildCloseButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(),
        size: context.adaptiveIcon(16.sp),
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GestureDetector(
      onTap: onActionTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _getActionButtonColor(),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          actionLabel!,
          style: TextStyle(
            fontSize: context.adaptiveFont(11.sp),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap:
          onClose ?? () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: _getTextColor().withOpacityCompat(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: context.adaptiveIcon(10.sp),
          color: _getTextColor().withOpacityCompat(0.6),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFFF0F9F4);
      case SnackbarType.error:
        return const Color(0xFFFEF2F2);
      case SnackbarType.warning:
        return const Color(0xFFFEFBF0);
      case SnackbarType.info:
        return const Color(0xFFF0F8FF);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFFD1FAE5);
      case SnackbarType.error:
        return const Color(0xFFFECACA);
      case SnackbarType.warning:
        return const Color(0xFFFDE68A);
      case SnackbarType.info:
        return const Color(0xFFBFDBFE);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF065F46);
      case SnackbarType.error:
        return const Color(0xFF991B1B);
      case SnackbarType.warning:
        return const Color(0xFF92400E);
      case SnackbarType.info:
        return const Color(0xFF1E40AF);
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case SnackbarType.success:
        return AppColors.success;
      case SnackbarType.error:
        return AppColors.error;
      case SnackbarType.warning:
        return AppColors.warning;
      case SnackbarType.info:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_rounded;
      case SnackbarType.error:
        return Icons.error_outline_rounded;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  Color _getActionButtonColor() {
    return _getIconBackgroundColor();
  }
}

class _OverlaySnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final SnackbarConfig config;
  final VoidCallback onDismiss;

  const _OverlaySnackbarWidget({
    required this.message,
    required this.type,
    required this.config,
    required this.onDismiss,
  });

  @override
  State<_OverlaySnackbarWidget> createState() => _OverlaySnackbarWidgetState();
}

class _OverlaySnackbarWidgetState extends State<_OverlaySnackbarWidget>
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
                  child: _SnackbarContent(
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
