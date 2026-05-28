import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../bloc/login/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode(debugLabel: 'login_email');
  final _passwordFocusNode = FocusNode(debugLabel: 'login_password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, S s) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return s.validation_email_required;
    final emailOk = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v);
    if (!emailOk) return s.validation_email_invalid;
    return null;
  }

  String? _validatePassword(String? value, S s) {
    final v = value ?? '';
    if (v.isEmpty) return s.validation_password_required;
    if (v.length < 6) return s.validation_password_short;
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<LoginBloc>();
    bloc.add(UpdateEmail(_emailController.text.trim()));
    bloc.add(UpdatePassword(_passwordController.text));
    bloc.add(SendLoginRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.loginBackgroundGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: context.responsive(5.h, tablet: 4, desktop: 4),
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                  ),
                ),
              ),
              SafeArea(
                child: BlocConsumer<LoginBloc, LoginState>(
                  listenWhen: (prev, curr) =>
                      curr is LoginSuccess || curr is LoginFailure,
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      context.go(Routes.settingsPath);
                    } else if (state is LoginFailure) {
                      UnifiedSnackbar.error(context, message: state.error);
                    }
                  },
                  builder: (context, state) {
                    final loading = state is LoginLoading;
                    final s = S.of(context);

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(
                          20.w,
                          tablet: 48,
                          desktop: 48,
                        ),
                        vertical: context.responsive(
                          12.h,
                          tablet: 12,
                          desktop: 12,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.sizeOf(context).height -
                                MediaQuery.paddingOf(context).vertical -
                                24,
                            maxWidth: context.responsive(
                              double.infinity,
                              tablet: 500,
                              desktop: 480,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: context.responsive(
                                  30.h,
                                  tablet: 30,
                                  desktop: 24,
                                ),
                              ),
                              
                              Center(
                                child: Container(
                                  width: context.responsive(
                                    120.w,
                                    tablet: 130,
                                    desktop: 120,
                                  ),
                                  padding: EdgeInsets.all(
                                    context.responsive(
                                      14.w,
                                      tablet: 14,
                                      desktop: 14,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      context.responsive(
                                        20.r,
                                        tablet: 20,
                                        desktop: 20,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.10,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: context.responsive(
                                  24.h,
                                  tablet: 24,
                                  desktop: 20,
                                ),
                              ),
                              Text(
                                s.login_title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: context.adaptiveFont(24.sp),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(
                                height: context.responsive(
                                  8.h,
                                  tablet: 8,
                                  desktop: 8,
                                ),
                              ),
                              Text(
                                s.login_subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: context.adaptiveFont(14.sp),
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              SizedBox(
                                height: context.responsive(
                                  28.h,
                                  tablet: 28,
                                  desktop: 24,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(
                                  context.responsive(
                                    20.w,
                                    tablet: 24,
                                    desktop: 24,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    context.responsive(
                                      22.r,
                                      tablet: 22,
                                      desktop: 22,
                                    ),
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryWhisper.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryDark.withValues(
                                        alpha: 0.07,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      CustomTextField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        nextFocusNode: _passwordFocusNode,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        label: s.email_label,
                                        hintText: s.email_hint,
                                        labelColor: AppColors.primaryText,
                                        textColor: AppColors.primaryText,
                                        focusBorderColor: AppColors.primary,
                                        fillColor: AppColors.creamWhite,
                                        enabled: !loading,
                                        onChanged: (v) => context
                                            .read<LoginBloc>()
                                            .add(UpdateEmail(v)),
                                        validator: (v) => _validateEmail(v, s),
                                        prefixIcon: Icon(
                                          Icons.alternate_email_rounded,
                                          color: AppColors.primaryDark
                                              .withValues(alpha: 0.85),
                                          size: context.adaptiveIcon(22.sp),
                                        ),
                                      ),
                                      SizedBox(
                                        height: context.responsive(
                                          18.h,
                                          tablet: 18,
                                          desktop: 16,
                                        ),
                                      ),
                                      CustomTextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
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
                                        onChanged: (v) => context
                                            .read<LoginBloc>()
                                            .add(UpdatePassword(v)),
                                        validator: (v) =>
                                            _validatePassword(v, s),
                                        onFieldSubmitted: (_) => _submit(),
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.primaryDark
                                              .withValues(alpha: 0.85),
                                          size: context.adaptiveIcon(22.sp),
                                        ),
                                      ),
                                      SizedBox(
                                        height: context.responsive(
                                          28.h,
                                          tablet: 28,
                                          desktop: 24,
                                        ),
                                      ),
                                      AppButton.elevated(
                                        label: s.login_button,
                                        isLoading: loading,
                                        disabled: loading,
                                        onPressed: _submit,
                                        icon: Icons.login_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: context.responsive(
                                  24.h,
                                  tablet: 24,
                                  desktop: 20,
                                ),
                              ),
                              Text(
                                s.tawakkul_quote,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: context.adaptiveFont(12.sp),
                                  height: 1.7,
                                  color: AppColors.secondaryText.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
