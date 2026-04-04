import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final bool enableTvRemoteSupport;

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
    this.focusNode,
    this.nextFocusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.autofocus = false,
    this.enableTvRemoteSupport = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _currentObscure;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _currentObscure = widget.obscureText;
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'CustomTextField');
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    final next = _focusNode.hasFocus;
    if (next == _hasFocus) return;
    setState(() => _hasFocus = next);
    if (!next) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }
  }

  bool _isRemoteActivationKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.gameButtonA ||
        key == LogicalKeyboardKey.space;
  }

  void _requestKeyboard() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enableTvRemoteSupport || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (_isRemoteActivationKey(key)) {
      _requestKeyboard();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.browserBack) {
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleFieldSubmitted(String value) {
    widget.onFieldSubmitted?.call(value);
    if (widget.textInputAction == TextInputAction.next &&
        widget.nextFocusNode != null) {
      widget.nextFocusNode!.requestFocus();
      return;
    }
    if (widget.textInputAction == TextInputAction.done ||
        widget.textInputAction == TextInputAction.go ||
        widget.textInputAction == TextInputAction.send) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Widget _buildEffectiveSuffixIcon(BuildContext context) {
    if (widget.isPassword) {
      return IconButton(
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
      );
    }
    if (widget.suffixIcon != null) return widget.suffixIcon!;
    if (_hasFocus && widget.enableTvRemoteSupport) {
      return Icon(
        Icons.keyboard_outlined,
        color: (widget.focusBorderColor ?? AppColors.primary).withValues(
          alpha: 0.85,
        ),
        size: context.adaptiveIcon(18.sp),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final activeBorder = widget.focusBorderColor ?? AppColors.primary;

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
        Focus(
          canRequestFocus: false,
          onKeyEvent: _handleKeyEvent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: _hasFocus
                  ? [
                      BoxShadow(
                        color: activeBorder.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              obscureText: widget.isPassword ? _currentObscure : false,
              onChanged: widget.onChanged,
              onTap: _requestKeyboard,
              onTapOutside: (_) => _focusNode.unfocus(),
              onFieldSubmitted: _handleFieldSubmitted,
              onEditingComplete: widget.onEditingComplete,
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
                suffixIcon: _buildEffectiveSuffixIcon(context),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: context.responsive(
                    14.h,
                    tablet: 16.h,
                    desktop: 18.h,
                  ),
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
                    color: activeBorder,
                    width: 1.8,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
