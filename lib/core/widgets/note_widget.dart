import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/app_colors.dart';
import '../utils/color_extensions.dart';
import '../utils/responsive_layout.dart';

class NoteWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final EdgeInsets? padding;

  const NoteWidget({super.key, required this.text, this.icon, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primaryStart.withOpacityCompat(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primaryStart,
              size: context.adaptiveIcon(18.sp),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
                fontFamily: 'Beiruti',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
