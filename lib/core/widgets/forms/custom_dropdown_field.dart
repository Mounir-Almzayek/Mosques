import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../l10n/generated/l10n.dart';
import '../../utils/responsive_layout.dart';
import 'searchable_dropdown_dialog.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T) getLabel;
  final bool isRequired;
  final bool Function(T, String)? filterFunction;
  final Color? activeColor;
  final Gradient? activeGradient;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.getLabel,
    this.selectedValue,
    this.isRequired = false,
    this.filterFunction,
    this.activeColor,
    this.activeGradient,
  });

  @override
  Widget build(BuildContext context) {
    final useSearch = items.length > 4;
    final color = activeColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: useSearch ? () => _showSearchDialog(context) : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: context.responsive(10.h, tablet: 12.h, desktop: 14.h),
            ),
            decoration: BoxDecoration(
              color: AppColors.brightWhite,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: useSearch
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedValue != null
                              ? getLabel(selectedValue as T)
                              : S.of(context).please_select,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(14.sp),
                            color: selectedValue != null
                                ? AppColors.primaryText
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: color,
                        size: context.adaptiveIcon(22.sp),
                      ),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: selectedValue,
                      isExpanded: true,
                      isDense: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: color,
                        size: context.adaptiveIcon(22.sp),
                      ),
                      hint: Text(
                        S.of(context).please_select,
                        style: TextStyle(
                          fontSize: context.adaptiveFont(14.sp),
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      items: items.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(
                            getLabel(item),
                            style: TextStyle(
                              fontSize: context.adaptiveFont(14.sp),
                              color: AppColors.primaryText,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final T? result = await showDialog<T>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SearchableDropdownDialog<T>(
          items: items,
          selectedValue: selectedValue,
          getLabel: getLabel,
          filterFunction: filterFunction,
          parentContext: context,
          activeColor: activeColor,
          activeGradient: activeGradient,
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}
