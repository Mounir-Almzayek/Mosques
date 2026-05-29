import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/feedback/snackbar_type.dart';
import 'overlay_snackbar_widget.dart';
import 'snackbar_config.dart';
export '../../enums/feedback/snackbar_type.dart';
export 'snackbar_config.dart';

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
        builder: (context) => OverlaySnackbarWidget(
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
