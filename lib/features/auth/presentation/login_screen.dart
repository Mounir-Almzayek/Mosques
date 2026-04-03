import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/forms/custom_elevated_button.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../data/repositories/app_settings_repository.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  height: 5.h,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldHairlineGradient,
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
                        horizontal: context.responsive(20.w, tablet: 48.w),
                        vertical: 12.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              MediaQuery.sizeOf(context).height -
                              MediaQuery.paddingOf(context).vertical -
                              24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 30.h),
                            Text(
                              s.bismillah,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(13.sp),
                                fontWeight: FontWeight.w500,
                                color: AppColors.goldDeep.withValues(
                                  alpha: 0.85,
                                ),
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            _BrandMark(
                              size: context.responsive(88.r, tablet: 100.r),
                            ),
                            SizedBox(height: 24.h),
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
                            SizedBox(height: 8.h),
                            Text(
                              s.login_subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(14.sp),
                                color: AppColors.secondaryText,
                              ),
                            ),
                            SizedBox(height: 28.h),
                            Container(
                              padding: EdgeInsets.all(
                                context.responsive(20.w, tablet: 28.w),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22.r),
                                border: Border.all(
                                  color: AppColors.goldWhisper.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldDeep.withValues(
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
                                      keyboardType: TextInputType.emailAddress,
                                      label: s.email_label,
                                      hintText: s.email_hint,
                                      labelColor: AppColors.primaryText,
                                      textColor: AppColors.primaryText,
                                      focusBorderColor: AppColors.goldRich,
                                      fillColor: AppColors.creamWhite,
                                      enabled: !loading,
                                      onChanged: (v) => context
                                          .read<LoginBloc>()
                                          .add(UpdateEmail(v)),
                                      validator: (v) => _validateEmail(v, s),
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                        color: AppColors.goldDeep.withValues(
                                          alpha: 0.85,
                                        ),
                                        size: context.adaptiveIcon(22.sp),
                                      ),
                                    ),
                                    SizedBox(height: 18.h),
                                    CustomTextField(
                                      controller: _passwordController,
                                      isPassword: true,
                                      obscureText: true,
                                      label: s.password_label,
                                      hintText: s.password_hint,
                                      labelColor: AppColors.primaryText,
                                      textColor: AppColors.primaryText,
                                      focusBorderColor: AppColors.goldRich,
                                      fillColor: AppColors.creamWhite,
                                      enabled: !loading,
                                      onChanged: (v) => context
                                          .read<LoginBloc>()
                                          .add(UpdatePassword(v)),
                                      validator: (v) => _validatePassword(v, s),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.goldDeep.withValues(
                                          alpha: 0.85,
                                        ),
                                        size: context.adaptiveIcon(22.sp),
                                      ),
                                    ),
                                    SizedBox(height: 28.h),
                                    CustomElevatedButton(
                                      title: s.login_button,
                                      isLoading: loading,
                                      disabled: loading,
                                      onPressed: _submit,
                                      icon: Icons.login_rounded,
                                      useGradient: false,
                                      useShadow: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
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
                            SizedBox(height: 24.h),
                            FutureBuilder(
                              future: AppSettingsRepository.getAppSettings(),
                              builder: (context, snapshot) {
                                final canOpenRegistration =
                                    snapshot.data?.allowRegistration ?? true;
                                if (!canOpenRegistration) {
                                  return const SizedBox.shrink();
                                }
                                return TextButton(
                                  onPressed: () =>
                                      context.push(Routes.registrationPath),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.goldDeep,
                                  ),
                                  child: Text(
                                    s.register_link,
                                    style: TextStyle(
                                      fontSize: context.adaptiveFont(14.sp),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.goldLuxuryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.goldRich.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.14),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.mosque_outlined,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        ),
      ),
    );
  }
}
