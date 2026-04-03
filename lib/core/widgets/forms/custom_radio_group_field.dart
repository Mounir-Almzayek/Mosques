// RadioListTile groupValue/onChanged: stable replacement (RadioGroup) not adopted yet.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../utils/color_extensions.dart';
import '../../utils/responsive_layout.dart';

class CustomRadioGroupField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final bool isRequired;
  final Color? activeColor;

  const CustomRadioGroupField({
    super.key,
    required this.label,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.selectedValue,
    this.isRequired = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = isRequired ? '$label *' : label;
    final color = activeColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              effectiveLabel,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Column(
          children: items.map((item) {
            final isSelected = selectedValue == item;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                color: isSelected
                    ? color.withOpacityCompat(0.05)
                    : AppColors.background.withOpacityCompat(0.5),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  listTileTheme: const ListTileThemeData(horizontalTitleGap: 0),
                ),
                child: RadioListTile<T>(
                  value: item,
                  groupValue: selectedValue,
                  activeColor: color,
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: context.responsive(0, tablet: 2.h, desktop: 4.h),
                  ),
                  title: Text(
                    getLabel(item),
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      color: isSelected ? color : AppColors.primaryText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
