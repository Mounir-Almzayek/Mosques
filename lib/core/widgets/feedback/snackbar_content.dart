import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums/feedback/snackbar_type.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';
import 'snackbar_palette.dart';

class SnackbarContent extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final bool showCloseButton;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onClose;

  const SnackbarContent({
    super.key,
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

  SnackbarPalette get _palette => SnackbarPalette.forType(type);
}
