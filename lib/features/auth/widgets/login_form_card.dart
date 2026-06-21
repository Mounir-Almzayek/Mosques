import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../bloc/login/login_bloc.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.loading,
    required this.onSubmit,
    required this.validateEmail,
    required this.validatePassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool loading;
  final VoidCallback onSubmit;
  final FormFieldValidator<String> validateEmail;
  final FormFieldValidator<String> validatePassword;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      padding: EdgeInsets.all(context.responsive(20, tablet: 24, desktop: 28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryWhisper.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: emailController,
              focusNode: emailFocusNode,
              nextFocusNode: passwordFocusNode,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              label: s.email_label,
              hintText: s.email_hint,
              labelColor: AppColors.primaryText,
              textColor: AppColors.primaryText,
              focusBorderColor: AppColors.primary,
              fillColor: AppColors.creamWhite,
              enabled: !loading,
              onChanged: (value) =>
                  context.read<LoginBloc>().add(UpdateEmail(value)),
              validator: validateEmail,
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
                color: AppColors.primaryDark.withValues(alpha: 0.85),
                size: context.adaptiveIcon(22),
              ),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              isPassword: true,
              obscureText: true,
              textInputAction: TextInputAction.done,
              label: s.password_label,
              hintText: s.password_hint,
              labelColor: AppColors.primaryText,
              textColor: AppColors.primaryText,
              focusBorderColor: AppColors.primary,
              fillColor: AppColors.creamWhite,
              enabled: !loading,
              onChanged: (value) =>
                  context.read<LoginBloc>().add(UpdatePassword(value)),
              validator: validatePassword,
              onFieldSubmitted: (_) => onSubmit(),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryDark.withValues(alpha: 0.85),
                size: context.adaptiveIcon(22),
              ),
            ),
            const SizedBox(height: 28),
            AppButton.elevated(
              label: s.login_button,
              isLoading: loading,
              disabled: loading,
              onPressed: onSubmit,
              icon: Icons.login_rounded,
              expand: false,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
