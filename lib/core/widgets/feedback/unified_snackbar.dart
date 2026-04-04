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
    final palette = _palette;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: palette.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withOpacityCompat(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacityCompat(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                color: palette.text,
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
    final palette = _palette;
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: palette.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        palette.icon,
        size: context.adaptiveIcon(16.sp),
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final palette = _palette;
    return GestureDetector(
      onTap: onActionTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: palette.accent,
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
    final palette = _palette;
    return GestureDetector(
      onTap:
          onClose ?? () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: palette.text.withOpacityCompat(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: context.adaptiveIcon(10.sp),
          color: palette.text.withOpacityCompat(0.6),
        ),
      ),
    );
  }

  _SnackbarPalette get _palette {
    switch (type) {
      case SnackbarType.success:
        return const _SnackbarPalette(
          background: Color(0xFFF4FBF7),
          border: Color(0xFFCFE9DA),
          text: Color(0xFF214E3C),
          accent: AppColors.success,
          icon: Icons.check_rounded,
        );
      case SnackbarType.error:
        return const _SnackbarPalette(
          background: Color(0xFFFFF5F4),
          border: Color(0xFFF2CFCA),
          text: Color(0xFF7F2B26),
          accent: AppColors.error,
          icon: Icons.error_outline_rounded,
        );
      case SnackbarType.warning:
        return const _SnackbarPalette(
          background: Color(0xFFFFFAF1),
          border: Color(0xFFEEDFB2),
          text: Color(0xFF7B5A12),
          accent: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case SnackbarType.info:
        return const _SnackbarPalette(
          background: Color(0xFFFFFAF1),
          border: Color(0xFFE7D3A0),
          text: Color(0xFF6C5110),
          accent: AppColors.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _SnackbarPalette {
  final Color background;
  final Color border;
  final Color text;
  final Color accent;
  final IconData icon;

  const _SnackbarPalette({
    required this.background,
    required this.border,
    required this.text,
    required this.accent,
    required this.icon,
  });
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
