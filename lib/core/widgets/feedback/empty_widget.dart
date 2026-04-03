import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const EmptyWidget({required this.title, this.subtitle, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacityCompat(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                size: context.adaptiveIcon(48.sp),
                color: AppColors.primary.withOpacityCompat(0.2),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.adaptiveFont(16.sp),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.adaptiveFont(13.sp),
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
