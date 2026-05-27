import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';

enum _AppButtonVariant { elevated, outlined, text }

/// A unified button widget with three variants: elevated, outlined, and text.
///
/// Usage:
/// ```dart
/// AppButton.elevated(label: 'Submit', onPressed: _handleSubmit)
/// AppButton.outlined(label: 'Cancel', onPressed: _handleCancel)
/// AppButton.text(label: 'Skip', onPressed: _handleSkip)
/// ```
class AppButton extends StatelessWidget {
  const AppButton.elevated({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = true,
    this.useShadow = true,
  }) : _variant = _AppButtonVariant.elevated;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = true,
    this.useShadow = false,
  }) : _variant = _AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = false,
    this.useShadow = false,
  }) : _variant = _AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;

  /// Trailing icon displayed after the label.
  final IconData? icon;

  /// Leading icon displayed before the label.
  final IconData? leadingIcon;

  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Custom gradient for the elevated variant. Defaults to [AppColors.primaryGradient].
  final LinearGradient? gradient;

  /// Whether the button should expand to fill available width.
  /// Defaults to `true` for elevated/outlined, `false` for text.
  final bool expand;

  /// Whether to show a drop shadow. Defaults to `true` for elevated, `false` for others.
  final bool useShadow;

  final _AppButtonVariant _variant;

  bool get _isDisabled => disabled || isLoading;

  @override
  Widget build(BuildContext context) {
    if (_variant == _AppButtonVariant.text) {
      return _buildTextButton(context);
    }
    return _buildContainerButton(context);
  }

  // ── Text variant ─────────────────────────────────────────────────────────────

  Widget _buildTextButton(BuildContext context) {
    final Color effectiveForeground =
        foregroundColor ?? AppColors.primary;

    return TextButton(
      onPressed: _isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveForeground,
        disabledForegroundColor: AppColors.mutedForeground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.r),
        ),
      ),
      child: _buildContent(context, foreground: effectiveForeground),
    );
  }

  // ── Elevated & Outlined variants ──────────────────────────────────────────────

  Widget _buildContainerButton(BuildContext context) {
    final double effectiveRadius = borderRadius ?? 14.r;
    final borderRadiusObj = BorderRadius.circular(effectiveRadius);
    final double effectiveHeight =
        height ?? context.responsive(48.h, tablet: 52.h, desktop: 40.h);

    final Color effectiveForeground = _isDisabled
        ? AppColors.mutedForeground
        : (foregroundColor ??
            (_variant == _AppButtonVariant.outlined
                ? AppColors.primary
                : Colors.white));

    final Color? bgColor = _variant == _AppButtonVariant.outlined
        ? (backgroundColor ?? Colors.transparent)
        : (_isDisabled
            ? (backgroundColor ?? AppColors.muted)
            : (backgroundColor));

    final LinearGradient? effectiveGradient =
        (_variant == _AppButtonVariant.elevated && !_isDisabled)
            ? (gradient ?? AppColors.primaryGradient)
            : null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 120.0 : 0,
      ),
      child: Container(
        width: expand ? (width ?? double.infinity) : width,
        height: effectiveHeight,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          color: bgColor,
          borderRadius: borderRadiusObj,
          border: _variant == _AppButtonVariant.outlined
              ? Border.all(
                  color: _isDisabled
                      ? AppColors.mutedForeground
                      : AppColors.primary,
                  width: 1.5,
                )
              : null,
          boxShadow: (_isDisabled || !useShadow)
              ? null
              : [
                  BoxShadow(
                    color:
                        AppColors.primaryStart.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: borderRadiusObj,
            child: Center(
              child: isLoading
                  ? _buildLoadingIndicator(context)
                  : _buildContent(context, foreground: effectiveForeground),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared content ────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, {required Color foreground}) {
    final double effectiveFontSize =
        fontSize ?? context.adaptiveFont(14.sp);
    final double iconSize = context.adaptiveIcon(16.sp);

    if (leadingIcon == null && icon == null) {
      return Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: foreground, size: iconSize),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: foreground, size: iconSize),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final double indicatorSize = context.isDesktop ? 24.0 : 24.r;
    final Color indicatorColor = _variant == _AppButtonVariant.elevated
        ? Colors.white
        : AppColors.primary;

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        color: indicatorColor,
        strokeWidth: 3,
      ),
    );
  }
}
