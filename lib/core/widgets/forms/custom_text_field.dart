import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? labelColor;
  final Color? textColor;
  final Color? fillColor;
  final Color? focusBorderColor;

  const CustomTextField({
    super.key,
    required this.controller,
    this.validator,
    this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isPassword = false,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.labelColor,
    this.textColor,
    this.fillColor,
    this.focusBorderColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _currentObscure;

  @override
  void initState() {
    super.initState();
    _currentObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: context.adaptiveFont(13.sp),
                fontWeight: FontWeight.w600,
                color: widget.labelColor ?? AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          enabled: widget.enabled,
          obscureText: widget.isPassword ? _currentObscure : false,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: context.adaptiveFont(14.sp),
            color: widget.textColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: context.adaptiveFont(14.sp),
              color: AppColors.mutedForeground,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _currentObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.mutedForeground,
                      size: context.adaptiveIcon(18.sp),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentObscure = !_currentObscure;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: context.responsive(14.h, tablet: 16.h, desktop: 18.h),
            ),
            fillColor: widget.fillColor ??
                (widget.enabled ? Colors.white : AppColors.muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.input),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.input),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: widget.focusBorderColor ?? AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
