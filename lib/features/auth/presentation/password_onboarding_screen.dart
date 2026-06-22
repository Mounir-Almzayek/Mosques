import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../bloc/password_onboarding/password_onboarding_bloc.dart';

class PasswordOnboardingScreen extends StatefulWidget {
  const PasswordOnboardingScreen({super.key});

  @override
  State<PasswordOnboardingScreen> createState() =>
      _PasswordOnboardingScreenState();
}

class _PasswordOnboardingScreenState extends State<PasswordOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocus = FocusNode(debugLabel: 'current_password');
  final _newPasswordFocus = FocusNode(debugLabel: 'new_password');
  final _confirmPasswordFocus = FocusNode(debugLabel: 'confirm_password');

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value, S s) {
    final text = value ?? '';
    if (text.isEmpty) return s.validation_password_required;
    if (text.length < 6) return s.validation_password_short;
    return null;
  }

  String? _validateConfirmation(String? value, S s) {
    final passwordError = _validatePassword(value, s);
    if (passwordError != null) return passwordError;
    if (value != _newPasswordController.text) {
      return s.password_onboarding_confirm_mismatch;
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordOnboardingBloc>().add(
      SubmitPasswordOnboarding(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  void _logout() {
    context.read<PasswordOnboardingBloc>().add(
      const LogoutPasswordOnboarding(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordOnboardingBloc, PasswordOnboardingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final s = S.of(context);
        switch (state.status) {
          case PasswordOnboardingStatus.success:
            UnifiedSnackbar.success(
              context,
              message: s.password_onboarding_success,
            );
            context.go(Routes.splashPath);
          case PasswordOnboardingStatus.failure:
            UnifiedSnackbar.error(
              context,
              message: state.error ?? s.error_occurred,
            );
          case PasswordOnboardingStatus.loggedOut:
            context.go(Routes.loginPath);
          case PasswordOnboardingStatus.initial:
          case PasswordOnboardingStatus.loading:
            break;
        }
      },
      builder: (context, state) {
        final s = S.of(context);
        final loading = state.status == PasswordOnboardingStatus.loading;

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.loginBackgroundGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(20, tablet: 32, desktop: 40),
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _PasswordOnboardingForm(
                      formKey: _formKey,
                      currentPasswordController: _currentPasswordController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      currentPasswordFocus: _currentPasswordFocus,
                      newPasswordFocus: _newPasswordFocus,
                      confirmPasswordFocus: _confirmPasswordFocus,
                      loading: loading,
                      onSubmit: _submit,
                      onLogout: _logout,
                      validatePassword: (value) => _validatePassword(value, s),
                      validateConfirmation: (value) =>
                          _validateConfirmation(value, s),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordOnboardingForm extends StatelessWidget {
  const _PasswordOnboardingForm({
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.currentPasswordFocus,
    required this.newPasswordFocus,
    required this.confirmPasswordFocus,
    required this.loading,
    required this.onSubmit,
    required this.onLogout,
    required this.validatePassword,
    required this.validateConfirmation,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final FocusNode currentPasswordFocus;
  final FocusNode newPasswordFocus;
  final FocusNode confirmPasswordFocus;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onLogout;
  final FormFieldValidator<String> validatePassword;
  final FormFieldValidator<String> validateConfirmation;

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_reset_rounded,
              size: context.adaptiveIcon(42),
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              s.password_onboarding_title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.password_onboarding_subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: currentPasswordController,
              focusNode: currentPasswordFocus,
              nextFocusNode: newPasswordFocus,
              autofocus: true,
              isPassword: true,
              obscureText: true,
              label: s.password_onboarding_current_password,
              hintText: s.password_onboarding_current_password_hint,
              enabled: !loading,
              validator: validatePassword,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: newPasswordController,
              focusNode: newPasswordFocus,
              nextFocusNode: confirmPasswordFocus,
              isPassword: true,
              obscureText: true,
              label: s.password_onboarding_new_password,
              hintText: s.password_onboarding_new_password_hint,
              enabled: !loading,
              validator: validatePassword,
              prefixIcon: const Icon(Icons.password_rounded),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              focusNode: confirmPasswordFocus,
              isPassword: true,
              obscureText: true,
              textInputAction: TextInputAction.done,
              label: s.password_onboarding_confirm_password,
              hintText: s.password_onboarding_confirm_password_hint,
              enabled: !loading,
              validator: validateConfirmation,
              onFieldSubmitted: (_) => onSubmit(),
              prefixIcon: const Icon(Icons.verified_user_outlined),
            ),
            const SizedBox(height: 26),
            AppButton.elevated(
              label: s.password_onboarding_save_continue,
              icon: Icons.arrow_forward_rounded,
              isLoading: loading,
              disabled: loading,
              onPressed: onSubmit,
              width: double.infinity,
              expand: false,
            ),
            const SizedBox(height: 12),
            AppButton.text(
              label: s.sign_out,
              leadingIcon: Icons.logout_rounded,
              disabled: loading,
              onPressed: onLogout,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}
