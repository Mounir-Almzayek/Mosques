import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/app_colors.dart';
import '../utils/color_extensions.dart';
import '../utils/responsive_layout.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStart.withOpacityCompat(0.1),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_rounded,
          size: context.adaptiveIcon(18.sp),
          color: AppColors.primary,
        ),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
