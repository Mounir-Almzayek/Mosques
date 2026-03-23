import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../l10n/generated/l10n.dart';
import '../styles/app_colors.dart';
import '../utils/responsive_layout.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final displayTitle = title ?? s.error_occurred;

    // Check if desktop for different layout
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.responsive(
            1.sw, // Mobile: full width
            tablet: 500.w, // Tablet: max 500px
            desktop:
                800.w, // Desktop: max 800px (increased for horizontal layout)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive(24.w, tablet: 32.w, desktop: 40.w),
            vertical: context.responsive(32.h, tablet: 48.h, desktop: 64.h),
          ),
          child: isDesktop
              ? _buildDesktopLayout(displayTitle, s, context)
              : _buildMobileLayout(displayTitle, s, context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(String displayTitle, S s, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error Icon
        Container(
          padding: EdgeInsets.all(
            context.responsive(20.r, tablet: 24.r, desktop: 28.r),
          ),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.error_outline,
            size: context.adaptiveIcon(
              context.responsive(48.sp, tablet: 56.sp, desktop: 64.sp),
            ),
            color: AppColors.error.withValues(alpha: 0.7),
          ),
        ),

        // Spacing
        SizedBox(
          height: context.responsive(20.h, tablet: 24.h, desktop: 28.h),
        ),

        // Error Title
        Text(
          displayTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.adaptiveFont(
              context.responsive(16.sp, tablet: 18.sp, desktop: 20.sp),
            ),
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Spacing
        SizedBox(
          height: context.responsive(8.h, tablet: 10.h, desktop: 12.h),
        ),

        // Error Message
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: context.adaptiveFont(
              context.responsive(12.sp, tablet: 14.sp, desktop: 16.sp),
            ),
          ),
        ),

        // Retry Button
        if (onRetry != null) ...[
          SizedBox(
            height: context.responsive(24.h, tablet: 28.h, desktop: 32.h),
          ),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  24.w,
                  tablet: 32.w,
                  desktop: 40.w,
                ),
                vertical: context.responsive(12.h, tablet: 14.h, desktop: 16.h),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  context.responsive(12.r, tablet: 14.r, desktop: 16.r),
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              s.retry,
              style: TextStyle(
                fontSize: context.adaptiveFont(
                  context.responsive(14.sp, tablet: 16.sp, desktop: 18.sp),
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(String displayTitle, S s, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Error Icon on the left
        Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.error_outline,
            size: context.adaptiveIcon(80.sp),
            color: AppColors.error.withValues(alpha: 0.7),
          ),
        ),

        // Spacing between icon and content
        SizedBox(width: 40.w),

        // Content (Title, Message, Button) in a column
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Title
              Text(
                displayTitle,
                style: TextStyle(
                  fontSize: context.adaptiveFont(24.sp),
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Spacing
              SizedBox(height: 12.h),

              // Error Message
              Text(
                message,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: context.adaptiveFont(18.sp),
                ),
              ),

              // Retry Button
              if (onRetry != null) ...[
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    s.retry,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(18.sp),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
