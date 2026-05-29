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
import '../../../core/widgets/focus/focus_widgets.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../../../core/widgets/media/logo_rectangle.dart';
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

  /// Wide layouts (desktop / tablet-landscape) get a two-pane split; narrow
  /// layouts (phones / portrait tablets) get a single centered column.
  bool _useSplitLayout(BuildContext context) =>
      context.isDesktop || (context.isTablet && context.isLandscape);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: TvNavigationScope(
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
              return _useSplitLayout(context)
                  ? _SplitLayout(
                      brandPanel: _brandPanel(context, s),
                      formPanel: _formPanel(context, s, loading),
                    )
                  : _compactLayout(context, s, loading);
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Compact (phone / portrait) — single centered, scrollable column.
  // ─────────────────────────────────────────────────────────────────────
  Widget _compactLayout(BuildContext context, S s, bool loading) {
    return Container(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(20.w, tablet: 48),
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                      maxWidth: context.responsive(double.infinity, tablet: 500),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: LogoRectangle(
                              big: false,
                              width: 180,
                              height: 96,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _titleBlock(context, s, onDark: false),
                          const SizedBox(height: 26),
                          _formCard(context, s, loading),
                          const SizedBox(height: 22),
                          _quote(context, s, onDark: false),
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Wide layout panels
  // ─────────────────────────────────────────────────────────────────────

  /// Left branding pane shown on wide screens — gradient background, logo,
  /// title and quote in light-on-dark styling.
  Widget _brandPanel(BuildContext context, S s) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LogoRectangle(big: true, width: 240, height: 120),
                  const SizedBox(height: 32),
                  _titleBlock(context, s, onDark: true),
                  const SizedBox(height: 28),
                  _quote(context, s, onDark: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Right pane on wide screens — the form on a soft surface, centered.
  Widget _formPanel(BuildContext context, S s, bool loading) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.loginBackgroundGradient,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _formCard(context, s, loading),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Shared building blocks
  // ─────────────────────────────────────────────────────────────────────

  Widget _titleBlock(BuildContext context, S s, {required bool onDark}) {
    final titleColor = onDark ? Colors.white : AppColors.primaryText;
    final subColor = onDark
        ? Colors.white.withValues(alpha: 0.82)
        : AppColors.secondaryText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          s.login_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.responsive(24, tablet: 26, desktop: 30),
            fontWeight: FontWeight.bold,
            color: titleColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.login_subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.responsive(14, tablet: 15, desktop: 16),
            color: subColor,
          ),
        ),
      ],
    );
  }

  Widget _quote(BuildContext context, S s, {required bool onDark}) {
    return Text(
      s.tawakkul_quote,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: context.responsive(12, tablet: 13, desktop: 14),
        height: 1.7,
        color: onDark
            ? Colors.white.withValues(alpha: 0.78)
            : AppColors.secondaryText.withValues(alpha: 0.85),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _formCard(BuildContext context, S s, bool loading) {
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
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              nextFocusNode: _passwordFocusNode,
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
              onChanged: (v) =>
                  context.read<LoginBloc>().add(UpdateEmail(v)),
              validator: (v) => _validateEmail(v, s),
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
                color: AppColors.primaryDark.withValues(alpha: 0.85),
                size: context.adaptiveIcon(22),
              ),
            ),
            const SizedBox(height: 18),
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
              onChanged: (v) =>
                  context.read<LoginBloc>().add(UpdatePassword(v)),
              validator: (v) => _validatePassword(v, s),
              onFieldSubmitted: (_) => _submit(),
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
              onPressed: _submit,
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

/// Two-pane split used on wide screens: branding on the leading side, the
/// form on the trailing side.
class _SplitLayout extends StatelessWidget {
  final Widget brandPanel;
  final Widget formPanel;

  const _SplitLayout({required this.brandPanel, required this.formPanel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: brandPanel),
        Expanded(flex: 4, child: formPanel),
      ],
    );
  }
}
