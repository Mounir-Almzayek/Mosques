import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/focus/focus_widgets.dart';
import '../bloc/login/login_bloc.dart';
import '../widgets/login_brand_panel.dart';
import '../widgets/login_compact_layout.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_form_panel.dart';
import '../widgets/login_split_layout.dart';

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
              final formCard = LoginFormCard(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                emailFocusNode: _emailFocusNode,
                passwordFocusNode: _passwordFocusNode,
                loading: loading,
                onSubmit: _submit,
                validateEmail: (value) => _validateEmail(value, s),
                validatePassword: (value) => _validatePassword(value, s),
              );

              return _useSplitLayout(context)
                  ? LoginSplitLayout(
                      brandPanel: const LoginBrandPanel(),
                      formPanel: LoginFormPanel(formCard: formCard),
                    )
                  : LoginCompactLayout(formCard: formCard);
            },
          ),
        ),
      ),
    );
  }
}
