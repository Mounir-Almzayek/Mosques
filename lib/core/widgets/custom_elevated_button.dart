import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/app_colors.dart';
import '../utils/responsive_layout.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final bool disabled;
  final bool useGradient;
  final bool useShadow;
  /// When set, used instead of [AppColors.primaryGradient] when [useGradient] is true.
  final LinearGradient? gradient;
  final Color? shadowColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.disabled = false,
    this.useGradient = true,
    this.useShadow = true,
    this.gradient,
    this.shadowColor,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = disabled || isLoading;
    final borderRadius = BorderRadius.circular(14.r);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? 120.0 : 0),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? context.responsive(48.h, tablet: 52.h, desktop: 40.h),
        decoration: BoxDecoration(
          gradient: (isButtonDisabled || !useGradient)
              ? null
              : (gradient ?? AppColors.primaryGradient),
          color: isButtonDisabled
              ? AppColors.muted
              : (useGradient ? null : AppColors.primary),
          borderRadius: borderRadius,
          boxShadow: (isButtonDisabled || !useShadow)
              ? null
              : [
                  BoxShadow(
                    color: (shadowColor ?? AppColors.primaryStart)
                        .withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isButtonDisabled ? null : onPressed,
            borderRadius: borderRadius,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: context.isDesktop ? 24.0 : 24.r,
                      height: context.isDesktop ? 24.0 : 24.r,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: fontSize ?? context.adaptiveFont(14.sp),
                            fontWeight: FontWeight.bold,
                            color: isButtonDisabled
                                ? AppColors.mutedForeground
                                : Colors.white,
                          ),
                        ),
                        if (icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            icon,
                            color: isButtonDisabled
                                ? AppColors.mutedForeground
                                : Colors.white,
                            size: context.adaptiveIcon(16.sp),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
