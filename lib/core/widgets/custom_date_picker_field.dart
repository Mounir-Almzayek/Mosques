import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';
import '../l10n/generated/l10n.dart';
import '../utils/responsive_layout.dart';

class CustomDatePickerField extends StatelessWidget {
  final String label;
  final String? selectedDate;
  final Function(String) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool isRequired;
  final bool pickTime;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.onDateSelected,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.isRequired = false,
    this.pickTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: context.responsive(12.h, tablet: 14.h, desktop: 16.h),
            ),
            decoration: BoxDecoration(
              color: AppColors.brightWhite,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate?.isNotEmpty == true
                        ? selectedDate!
                        : S.of(context).select_date,
                    style: TextStyle(
                      fontSize: context.adaptiveFont(14.sp),
                      color: selectedDate?.isNotEmpty == true
                          ? AppColors.primaryText
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: context.adaptiveIcon(18.sp),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime firstDate = minDate ?? DateTime(1900);
    DateTime lastDate = maxDate ?? DateTime(2100);

    if (firstDate.isAfter(lastDate)) {
      lastDate = firstDate;
    }

    DateTime initialDate;
    final parsed = (selectedDate != null && selectedDate!.isNotEmpty)
        ? DateTime.tryParse(selectedDate!)
        : null;
    if (parsed != null) {
      if (parsed.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (parsed.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = parsed;
      }
    } else {
      final now = DateTime.now();
      if (now.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (now.isAfter(lastDate)) {
        initialDate = lastDate;
      } else {
        initialDate = now;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.brightWhite,
              surface: AppColors.brightWhite,
              onSurface: AppColors.primaryText,
            ),
            textTheme: Theme.of(context).textTheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      DateTime finalDateTime = picked;
      if (pickTime) {
        final TimeOfDay initialTime = TimeOfDay.fromDateTime(DateTime.now());
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.brightWhite,
                  surface: AppColors.brightWhite,
                  onSurface: AppColors.primaryText,
                ),
                textTheme: Theme.of(context).textTheme,
              ),
              child: child!,
            );
          },
        );
        if (pickedTime != null) {
          finalDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }

      if (context.mounted) {
        String two(int v) => v.toString().padLeft(2, '0');
        final String formatted = pickTime
            ? '${finalDateTime.year}-${two(finalDateTime.month)}-${two(finalDateTime.day)} ${two(finalDateTime.hour)}:${two(finalDateTime.minute)}:00'
            : '${finalDateTime.year}-${two(finalDateTime.month)}-${two(finalDateTime.day)}';
        onDateSelected(formatted);
      }
    }
  }
}
